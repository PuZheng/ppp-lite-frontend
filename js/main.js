var riot = require('riotjs');
require('../vendors/semantic/dist/semantic.css');
require('semantic-ui/semantic.js');

var bus = require('riot-bus');
var projectListStore = require('./stores/project-list.js');
var projectTypeListStore = require('./stores/project-type-list.js');

require('./tags/project-list-app.tag');
require('./tags/project.tag');

var switchApp = function () {
    var currentApp;
    var currentStores = [];
    return function (tagName, stores, opts) {
        if (!currentApp || currentApp.opts['riot-tag'] != tagName) {
            currentApp = riot.mount('#main', tagName, opts)[0];
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

    switch (app) {
        case 'project': {
            if (view === 'project-list') {
                var params = arguments[2];
                switchApp('project-list-app', [projectListStore]);
                bus.trigger('projectList.fetch', {
                    page: parseInt(params.page) || 1,
                    per_page: 18
                });
            } else if (view === 'project-object') {
                switchApp('project-app', [projectTypeListStore], {
                    backref: arguments[2].backref? decodeURIComponent(arguments[2].backref): 'project/project-list',
                });
                bus.trigger('projectTypeList.fetch');
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

