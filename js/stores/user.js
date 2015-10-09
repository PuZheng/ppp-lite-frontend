var riot = require('riot');
var bus = require('riot-bus');
var request = require('request');
var config = require('config');

var UserStore = function () {
    riot.observable(this);
    this.on('user.update', function (id, data) {
        this.update(id, data);
    });
};

UserStore.prototype.update = function (id, data) {
    bus.trigger('user.updating');
    request.put(config.backend + '/user/user-object/' + id, data).done(function (res) {
        bus.trigger('user.updated', res.body);
    }).fail(function (err, res) {
        bus.trigger('user.update.failed', err, res);
    }).always(function () {
        bus.trigger('user.update.end');
    });
};

module.exports = new UserStore();
