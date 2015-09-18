var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');

function ProjectStore() {
    riot.observable(this);

    this.on('project.fetch', function (id) {
        bus.trigger('project.fetching');
        $.getJSON(config.backend + '/project/project-object/' + id).done(function (data) {
            bus.trigger('project.fetched', data);
        });
    });
}


module.exports = new ProjectStore();
