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

var workspace = {
    currentApp: null,
    currentStores: [],
};
riot.observable(workspace);
bus.register(workspace);

workspace.on('loginRequired', function () {
    riot.route('auth/login?backref=' + window.location.hash);
});

var loginRequired = function (ctx, next) {
    if (authStore.authenticated()) {
        ctx.user = authStore.currentUser();
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
            stores.forEach(function (store) {
                workspace.currentStores.push(store);
                bus.register(store);
            });
        }
        return workspace.currentApp;
    };
}();

var projectList = function (ctx, next) {
    switchApp('project-list-app', [projectStore]);
    bus.trigger('projectList.fetch', {
        page: parseInt(ctx.query.page) || 1,
        per_page: 18
    });
};

var project = function (ctx, next) {
    switchApp('project-app', [ projectTypeStore, projectStore, tagStore ], {
        backref: decodeURIComponent(ctx.query.backref) || '',
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

var login = function (ctx) {
    switchApp('login', [authStore]);
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


page('/project/list', loginRequired, projectList);
page('/project/object', loginRequired, project);
page('/project/object/:id', loginRequired, project);
page('/auth/login', login);
page('/', 'project/list');

page();
