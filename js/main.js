var page = require('page');
var riot = require('riotjs');
require('semantic-ui/semantic.min.css');
require('semantic-ui/semantic.min.js');

var bus = require('riot-bus');

var projectTypeStore = require('./stores/project-type.js');
var projectStore = require('./stores/project.js');
var tagStore = require('./stores/tag.js');
var authStore = require('./stores/auth.js');
var assetsStore = require('./stores/assets.js');
var userStore = require('./stores/user.js');
var todoStore = require('./stores/todo.js');

var workflowStore = require('./stores/workflow.js');
var principal = require('principal');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');

require('./tags/project-list-app.tag');
require('./tags/project-app.tag');
require('./tags/login.tag');
require('./tags/nav-bar.tag');
require('./tags/profile.tag');
require('./tags/todo-list.tag');

$.ajaxSetup({
    cache: false,
});

var workspace = {
    currentApp: null,
    currentStores: [],
};

riot.observable(workspace);
bus.register(workspace);

workspace.on('loginRequired logout.done', function () {
    page('auth/login');
});

require('./setup-principal.js');

var loginRequired = function (ctx, next) {
    if (authStore.authenticated()) {
        ctx.user = authStore.currentUser();
        bus.register(authStore);
        principal.resetIdentity(ctx);
        next();
    } else {
        bus.trigger('loginRequired', ctx);
    }
};


var switchApp = function () {
    return function (tagName, stores, opts) {
        if (!workspace.currentApp || !_.isEqual(workspace.currentApp[opts], opts)) {
            workspace.currentApp = riot.mount('#main', tagName, opts || {})[0];
            workspace.currentStores.forEach(function (store) {
                bus.unregister(store);
            });
            !_.isEmpty(stores) && stores.forEach(function (store) {
                workspace.currentStores.push(store);
                bus.register(store);
            });
        }
        return workspace.currentApp;
    };
}();

var projectList = function (ctx, next) {
    switchApp('project-list-app', [projectStore], {
        ctx: ctx,
    });
    bus.trigger('projectList.fetch', {
        published: ctx.path === '/project/progressing-list'? 1: 0,
    });
    next();
};

var project = function (ctx, next) {
    switchApp('project-app', [ projectTypeStore, projectStore, tagStore, assetsStore, workflowStore, userStore ], {
        ctx: ctx,
    });
    (function (cb) {
        if (ctx.params.id) {
            projectStore.fetch(ctx.params.id).done(cb);
        } else {
            cb();
        }
    })(function () {
        projectTypeStore.fetchAll();
        tagStore.fetchAll();
    });
    next();
};

var navBar = function (ctx, next) {
    riot.mount('#nav-bar', 'nav-bar', {
        ctx: ctx
    });
    next();
};

var login = function (ctx, next) {
    switchApp('login', [authStore]);
    next();
};


var profile = function (ctx, next) {
    switchApp('profile', [userStore], {
        ctx: ctx
    });
    next();
};

var todoList = function (ctx, next) {
    switchApp('todo-list', null, {
        ctx: ctx
    });
    next();
};

var setupTodoStore = function (ctx, next) {
    bus.register(todoStore);
    todoStore.fetchList().then(function (data) {
        sessionStorage.setItem('todos', JSON.stringify(data.data.map(function (todo) {
            return todo.id;
        })));

        workspace.on('todos.fetched', function (data) {
            var haystack = JSON.parse(sessionStorage.getItem('todos'));
            var todos = data.data.filter(function (todo) {
                return haystack.indexOf(todo.id) === -1;
            });
            if (todos.length) {
                toastr.info(todos[0].summary, '新的待办事项!', {
                    positionClass: 'toast-bottom-center',
                    timeOut: 3000,
                });
                sessionStorage.setItem('todos', JSON.stringify(haystack.concat(todos.map(function (todo) {
                    return todo.id;
                }))));
            }
        });
    });
    setInterval(function () {
        bus.trigger('todos.fetch');
    }, 15000);
    next();
};

page(function (ctx, next) {
    var qs = ctx.querystring;
    ctx.query = {};

    if (qs) {
        qs.split('&').forEach(function(v) {
            var c = v.split('=');
            ctx.query[c[0]] = Array.prototype.concat.apply([], c.slice(1)).join('=');
        });
    }
    next();
});


page('/project/progressing-list', loginRequired, navBar, projectList, setupTodoStore);
page('/project/unpublished-list', loginRequired, navBar, projectList, setupTodoStore);
page('/project/object', loginRequired, navBar, project, setupTodoStore);
page('/project/object/:id', loginRequired, navBar, project, setupTodoStore);
page('/profile', loginRequired, navBar, profile, setupTodoStore);
page('/auth/login', navBar, login);
page('/todo/list', loginRequired, navBar, todoList, setupTodoStore);
page('/', 'project/progressing-list');

page();
