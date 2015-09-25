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

var workspace = {};
riot.observable(workspace);
bus.register(workspace);

workspace.on('loginRequired', function () {
    riot.route('auth/login?backref=' + window.location.hash);
});

var loginRequired = function () {
    var d = $.Deferred();
    if (authStore.authenticated()) {
        d.resolve();
    } else {
        bus.trigger('loginRequired');
        d.reject();
    }
    return d;
};


var switchApp = function () {
    var currentApp;
    var currentStores = [];
    var currentToken;
    return function (tagName, stores, opts, token) {
        if (!currentApp || currentApp.opts['riot-tag'] != tagName || token != currentToken) {
            currentApp = riot.mount('#main', tagName, opts || {})[0];
            currentStores.forEach(function (store) {
                bus.unregister(store);
            });
            stores.forEach(function (store) {
                currentStores.push(store);
                bus.register(store);
            });
        }
        return currentApp;
    };
}();


var router = function (app, view) {

    var params;
    switch (app) {
        case 'project': {
            if (view === 'project-list') {
                params = arguments[2];
                loginRequired().done(function () {
                    switchApp('project-list-app', [projectListStore, projectStore]);
                    bus.trigger('projectList.fetch', {
                        page: parseInt(params.page) || 1,
                        per_page: 18
                    });
                });
            } else if (view === 'project-object') {
                params = {};
                var id;
                switch (arguments.length) {
                    case 3: {
                        params = arguments[2];
                        break;
                    }
                    case 4: {
                        id = arguments[2];
                        params = arguments[3];
                    }
                }
                switchApp('project-app', [ projectTypeStore, projectStore, tagStore ], {
                    backref: params.backref? decodeURIComponent(params.backref): 'project/project-list',
                    id: id,
                }, id);
                (function (cb) {
                    if (id) {
                        projectStore.fetch(id).done(cb);
                    } else {
                        cb();
                    }
                })(function () {
                    projectTypeStore.fetchAll();
                    tagStore.fetchAll();
                });
            }
            break;
        }
        case 'auth': {
            if (view === 'login') {
                params = arguments[2];
                switchApp('login', [authStore], {backref: params.backref});
            }
            break;
        }
        default: {
            riot.route('project/project-list');
            break;
        }
    }
};

riot.route.parser(function(path) {
    path = path.split('?');
    var param = {};
    var page = path[0].split('/');
    var qs = path[1];
    var params = {};

    if (qs) {
        qs.split('&').forEach(function(v) {
            var c = v.split('=');
            params[c[0]] = c[1];
        });
    }

    page.push(params);
    return page;
});

riot.route(router);
riot.route.exec(router);

