riot = require('riotjs');
require('./riot-bus.js');

var router = function (app) {

    switch (app) {
        case 'list': {
            console.log('list hit');
            break;
        }
        default: {
            riot.route('list');
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

