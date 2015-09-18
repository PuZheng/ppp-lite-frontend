var riot = require('riotjs');
var config = require('config');
var bus = require('riot-bus');

function ProjectListStore() {
    riot.observable(this);

    this.on('projectList.fetch', function (params) {
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
    });
}


module.exports = new ProjectListStore();
