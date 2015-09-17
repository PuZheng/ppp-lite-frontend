var riot = require('riotjs');
var config = require('config');
var bus = require('riot-bus');

function ProjectListStore() {
    riot.observable(this);

    this.on('projectList.fetch', function (params) {
        var self = this;
        bus.trigger('projectList.fetching');
        params = params || {};
        $.getJSON(config.backend + '/project/list.json?' + _.pairs(params).map(function (p) {
            return p[0] + '=' + p[1];
        }).join('&')).done(function (data) {
            self.data = data.data;
            self.totalCount = data.totalCount;
            bus.trigger('projectList.fetched', self);
        });
    });
}


module.exports = ProjectListStore;
