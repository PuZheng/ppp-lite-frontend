var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');

function ProjectStore() {
    riot.observable(this);

    this.on('project.fetch', function (id) {
        this.fetch(id);
    }).on('project.update', function (id, data, bundle) {
        this.update(id, data, bundle);
    }).on('project.save', function (data) {
        this.save(data);
    }).on('project.delete', function (id) {
        this.delete(id);
    }).on('projectList.fetch', function (params) {
        this.fetchAll(params);
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

ProjectStore.prototype.update = function (id, patch, bundle) {
    var d = $.Deferred();
    bus.trigger('project.updating');
    $.ajax({
        url: config.backend + '/project/project-object/' + id,
        type: 'PUT',
        data: JSON.stringify(patch),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
    }).done(function (data) {
        bus.trigger('project.updated', data, patch, bundle);
        d.resolve(data);
    }).fail(function (data) {
        console.log('failed to update project', id, data, patch);
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
    }).fail(function () {
        console.log('failed to save project ', data);
    });
    return d;
};

ProjectStore.prototype.delete = function (id) {
    var d = $.Deferred();
    bus.trigger('project.deleting', id);
    $.ajax({
        url: config.backend + '/project/project-object/' + id,
        method: 'delete',
    }).done(function (data) {
        bus.trigger('project.deleted', id);
        d.resolve(data);
    }).fail(function () {
        console.log('failed to delete project ' + id);
    });
    return d;
};

ProjectStore.prototype.fetchAll = function (params) {
    var self = this;
    self.currentPage = params.page;
    self.perPage = params.per_page;
    bus.trigger('projectList.fetching');
    params = params || {};
    $.getJSON(config.backend + '/project/project-list.json?' + _.pairs(params).map(function (p) {
        return p[0] + '=' + p[1];
    }).join('&')).done(function (data) {
        self.data = data.data;
        self.data.forEach(function (row) {
            row.createdAt = new Date(row.createdAt);
        });
        self.totalCount = data.totalCount;
        bus.trigger('projectList.fetched', self);
    });
};

module.exports = new ProjectStore();

