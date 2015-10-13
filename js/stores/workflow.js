var riot = require('riot');
var config = require('config');
var request = require('request');
var bus = require('riot-bus');

var WorkflowStore = function () {
    riot.observable(this);
    this.on('task.deny', function (id, taskName, bundle) {
        this.denyTask(id, taskName, bundle);
    }).on('task.pass', function (id, taskName, bundle) {
        this.passTask(id, taskName, bundle);
    });
};

WorkflowStore.prototype.denyTask = function (id, taskName, bundle) {
    var ret = $.Deferred();
    bus.trigger('task.denying');
    request.put(config.backend + '/workflow/' + id + '/' + taskName, {
        action: 'deny',
        bundle: bundle
    })
    .done(function (res) {
        bus.trigger('task.denied', res.body);
        ret.resolve(res.body);
    }).fail(function (err) {
        bus.trigger('task.deny.failed', err);
        ret.reject(err);
    });
    return ret;
};

WorkflowStore.prototype.passTask = function (id, taskName, bundle) {
    var ret = $.Deferred();
    bus.trigger('task.passing');
    request.put(config.backend + '/workflow/' + id + '/' + taskName, {
        action: 'pass',
        bundle: bundle,
    })
    .done(function (res) {
        bus.trigger('task.passed', res.body);
    }).fail(function (err) {
        bus.trigger('task.pass.failed', err);
    });
};



module.exports = new WorkflowStore();
