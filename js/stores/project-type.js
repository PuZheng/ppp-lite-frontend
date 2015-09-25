var riot = require('riotjs');
var config = require('config');
var bus = require('riot-bus');

function ProjectTypeStore() {
    riot.observable(this);

    this.on('projectTypeList.fetch', function () {
        this.fetchAll();
    });
}

ProjectTypeStore.prototype.fetchAll = function () {
    var d = $.Deferred();
    var self = this;
    bus.trigger('projectTypeList.fetching');
    $.getJSON(config.backend + '/project/project-type-list.json').done(function (data) {
        self.data = data.data;
        self.data.forEach(function (row) {
            row.createdAt = new Date(row.createdAt);
        });
        self.totalCount = data.totalCount;
        bus.trigger('projectTypeList.fetched', self);
        d.resolve(self);
    });
    return d;
};


module.exports = new ProjectTypeStore();
