var riot = require('riotjs');
require('../vendors/semantic/dist/semantic.css');
require('semantic-ui/semantic.min.js');

var bus = require('riot-bus');
var ProjectListStore = require('./stores/project-list.js');

require('./tags/project-list-app.tag');

bus.register(new ProjectListStore());

var projectListApp;

var router = function (app, view, params) {

    switch (app) {
        case 'project': {
            if (view === 'list') {
                projectListApp = projectListApp || riot.mount('#main', 'project-list-app');
                bus.trigger('projectList.fetch', {
                    page: parseInt(params.page) || 1,
                    per_page: 18
                });
            }
            break;
        }
        default: {
            riot.route('project/list');
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

