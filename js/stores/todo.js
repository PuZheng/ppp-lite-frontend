var riot = require('riot');
var request = require('request');
var config = require('config');
var joinURL = require('join-url');
var bus = require('riot-bus');

var TodoStore = function () {
    riot.observable(this);
    this.on('todos.fetch', function () {
        this.fetchList();
    });
};

TodoStore.prototype.fetchList = function () {
    var ret = $.Deferred();

    bus.trigger('todos.fetching');
    request(joinURL(config.backend, '/todo/list.json')).done(function (res) {
        bus.trigger('todos.fetched', res.body);
        bus.trigger('todos.fetch.end');
        ret.resolve(res.body);
    }).fail(function (err, res) {
        bus.trigger('todos.fetch.failed', err);
        bus.trigger('todos.fetch.end');
        ret.reject(err);
    });
    return ret;
};

module.exports = new TodoStore();
