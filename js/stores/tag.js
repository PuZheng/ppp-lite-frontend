var riot = require('riotjs');
var config = require('config');
var bus = require('riot-bus');
var request = require('request');

function TagStore() {
    riot.observable(this);

    var self = this;
    this.on('tagList.fetch', function () {
        this.fetchAll();
    });
    this.on('tag.save', function (data, cb) {
        self.save(data).done(function (args) {
            cb(args);
        });
    });
}

TagStore.prototype.fetchAll = function () {
    var d = $.Deferred();
    var self = this;
    bus.trigger('tagList.fetching');
    request(config.backend + '/tag/tag-list.json').done(function (res) {
        bus.trigger('tagList.fetched', res.body);
        d.resolve(self);
    });
    return d;
};

TagStore.prototype.save = function (data, cb) {
    var d = $.Deferred();
    bus.trigger('tag.saving');
    request.post(config.backend + '/tag/tag-object', data)
    .done(function (res) {
        d.resolve(res.body);
        bus.trigger('tag.saved', res.body);
    });
    return d;
};


module.exports = new TagStore();
