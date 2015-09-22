var riot = require('riotjs');
var config = require('config');
var bus = require('riot-bus');

function TagStore() {
    riot.observable(this);

    var self = this;
    this.on('tagList.fetch', function () {
        this.fetchAll();
    });
    this.on('tag.save', function (data, cb) {
        self.save(data, cb);
    });
}

TagStore.prototype.fetchAll = function () {
    var d = $.Deferred();
    var self = this;
    bus.trigger('tagList.fetching');
    $.getJSON(config.backend + '/tag/tag-list.json').done(function (data) {
        bus.trigger('tagList.fetched', data);
        d.resolve(self);
    });
    return d;
};

TagStore.prototype.save = function (data, cb) {
    bus.trigger('tag.saving');
    $.ajax({
        url: config.backend + '/tag/tag-object',
        type: 'POST',
        data: JSON.stringify(data),
        contentType: 'application/json; charset=UTF-8',
        dataType: 'json',  // if the format of response should be json
    }).done(function (data, textStatus, jqXHR) {
        cb(data);
        bus.trigger('tag.saved', data);
    });
};


module.exports = new TagStore();
