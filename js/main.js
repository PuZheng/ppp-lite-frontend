var page = require('page');
var riot = require('riotjs');
require('semantic-ui/semantic.min.css');
require('semantic-ui/semantic.min.js');

var bus = require('riot-bus');

var projectTypeStore = require('./stores/project-type.js');
var projectStore = require('./stores/project.js');
var tagStore = require('./stores/tag.js');
var authStore = require('./stores/auth.js');

require('./tags/project-list-app.tag');
require('./tags/project.tag');
require('./tags/login.tag');
require('./tags/nav-bar.tag');
require('./tags/profile.tag');

var workspace = {
    currentApp: null,
    currentStores: [],
};
riot.observable(workspace);
bus.register(workspace);

workspace.on('loginRequired logout.done', function () {
    page('auth/login');
});

var loginRequired = function (ctx, next) {
    if (authStore.authenticated()) {
        ctx.user = authStore.currentUser();
        bus.register(authStore);
        next();
    } else {
        bus.trigger('loginRequired');
    }
};


var switchApp = function () {
    return function (tagName, stores, opts) {
        if (!workspace.currentApp || workspace.currentApp.opts['riot-tag'] != tagName) {
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
        page: parseInt(ctx.query.page) || 1,
        per_page: 18
    });
};

var project = function (ctx, next) {
    switchApp('project-app', [ projectTypeStore, projectStore, tagStore ], {
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

};

var navBar = function (ctx, next) {
    riot.mount('#nav-bar', 'nav-bar', {
        ctx: ctx
    });
    next();
};

var login = function (ctx) {
    switchApp('login', [authStore]);
};

var profile = function (ctx) {
    switchApp('profile', null, {
        ctx: ctx
    });
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


page('/project/list', loginRequired, navBar, projectList);
page('/project/object', loginRequired, navBar, project);
page('/project/object/:id', loginRequired, navBar, project);
page('/profile', loginRequired, navBar, profile);
page('/auth/login', navBar, login);
page('/', 'project/list');

page();
