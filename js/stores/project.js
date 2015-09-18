var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');

function ProjectStore() {
    riot.observable(this);

    this.on('project.fetch', function (id) {
        this.fetch(id);
    }).on('project.update', function (id, data) {
        this.update(id, data);
    }).on('project.save', function (data) {
        this.save(data);
    });
}

ProjectStore.prototype.fetch = function (id) {
    var d = $.Deferred();
    bus.trigger('project.fetching');
    $.getJSON(config.backend + '/project/project-object/' + id).done(function (data) {
        bus.trigger('project.fetched', data);
        d.resolve(data);
    });
    return d;
};

ProjectStore.prototype.update = function (id, data) {
    var d = $.Deferred();
    bus.trigger('project.updating');
    $.ajax({
        url: config.backend + '/project/project-object/' + id,
        type: 'PUT',
        data: JSON.stringify(data),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
    }).done(function (data) {
        bus.trigger('project.updated', data);
        d.resolve(data);
    });
    return d;
};

ProjectStore.prototype.save = function (data) {
    var d = $.Deferred();
    bus.trigger('project.saving');
    $.ajax({
        url: config.backend + '/project/project-object/',
        type: 'POST',
        data: JSON.stringify(data),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
    }).done(function (data) {
        bus.trigger('project.saved', data);
        d.resolve(data);
    });
    return d;
};

module.exports = new ProjectStore();
