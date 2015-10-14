var riot = require('riot');
var bus = require('riot-bus');
var request = require('request');
var config = require('config');
var joinURL = require('join-url');

var UserStore = function () {
    riot.observable(this);
    this.on('user.update', function (id, data) {
        this.update(id, data);
    }).on('userList.fetch', function (params) {
        this.fetchList(params);
    });
};

UserStore.prototype.update = function (id, data) {
    bus.trigger('user.updating');
    request.put(joinURL(config.backend, '/user/user-object/', id), data).done(function (res) {
        bus.trigger('user.updated', res.body);
    }).fail(function (err, res) {
        bus.trigger('user.update.failed', err, res);
    }).always(function () {
        bus.trigger('user.update.end');
    });
};

UserStore.prototype.fetchList = function (params) {
    var ret = $.Deferred();
    bus.trigger('userList.fetching');
    var url = joinURL(config.backend + '/user/list.json');
    if (params) {
        url += '?' + _.pairs(params).map(function (p) {
            return p.join('=');
        }).join('&');
    }
    request(url).done(function (res) {
        bus.trigger('userList.fetched', res.body.data);
        ret.resolve(res.body.data);
    }).fail(function (err, res) {
        bus.trigger('userList.fetch.failed', err);
        ret.reject(err);
    }).always(function () {
        bus.trigger('userList.fetch.end');
    });
    return ret;
};

module.exports = new UserStore();
