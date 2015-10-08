var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var request = require('request');

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
    }).on('project.publish', function (project) {
        this.publish(project);
    }).on('project.task.pass', function (project, taskName, bundle) {
        this.passTask(project, taskName, bundle);
    }).on('project.task.deny', function (project, taskName) {
        this.denyTask(project, taskName, bundle);
    });
}

ProjectStore.prototype.fetch = function (id) {
    var d = $.Deferred();
    bus.trigger('project.fetching');
    request(config.backend + '/project/project-object/' + id)
    .done(function (res) {
        bus.trigger('project.fetched', res.body);
        d.resolve(res.body);
    });
    return d;
};

ProjectStore.prototype.update = function (id, patch, bundle) {
    var d = $.Deferred();
    bus.trigger('project.updating');
    request.put(config.backend + '/project/project-object/' + id, patch)
    .done(function (data) {
        bus.trigger('project.updated', data, patch, bundle);
        d.resolve(data);
    }).fail(function (data) {
        console.error('failed to update project', id, data, patch);
    });
    return d;
};

ProjectStore.prototype.save = function (data) {
    var d = $.Deferred();
    bus.trigger('project.saving');
    request.post(config.backend + '/project/project-object/', data)
    .done(function (res) {
        bus.trigger('project.saved', res.body);
        d.resolve(res.body);
    }).fail(function () {
        console.error('failed to save project');
        bus.trigger('project.save.failed');
    });
    return d;
};

ProjectStore.prototype.delete = function (id) {
    var d = $.Deferred();
    bus.trigger('project.deleting', id);
    request.delete(config.backend + '/project/project-object/' + id)
    .done(function (res) {
        bus.trigger('project.deleted', id);
        d.resolve(res.body);
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
    var url = config.backend + '/project/project-list.json?' + _.pairs(params).map(function (p) {
        return p[0] + '=' + p[1];
    }).join('&');
    request(url).done(function (res) {
        self.data = res.body.data;
        self.data.forEach(function (row) {
            row.createdAt = new Date(row.createdAt);
        });
        self.totalCount = res.body.totalCount;
        bus.trigger('projectList.fetched', self);
    }).fail(function (err, res) {
        bus.trigger('projectList.fetch.failed');
    });
};

ProjectStore.prototype.publish = function (project) {
    bus.trigger('project.publishing', project);
    if (!project.workflowId) {
        request.post(config.backend + '/workflow/main-project-workflow')
        .done(function (res) {
            var workflow = res.body;
            request.put(config.backend + '/project/project-object/' + project.id, {
                    workflowId: workflow.id,
            }).done(function () {
                bus.trigger('project.published', workflow);
            }).fail(function () {
                bus.trigger('project.publish.failed', id);
            });
        }).fail(function () {
            bus.trigger('project.publish.failed', id);
        });
    } else {
        // 如果已经关联到了工作流
        this.passTask('START', project, 'START');
    }
};

ProjectStore.prototype.passTask = function (project, taskName, bundle) {
    bus.trigger('project.task.passing');
    request.put(config.backend + '/workflow/' + project.workflowId + '/' + taskName, bundle)
    .done(function (res) {
        bus.trigger('project.task.passed', res.body);
    }).fail(function () {
        bus.trigger('project.task.pass.failed', project);
    });
};

ProjectStore.prototype.denyTask = function (project, taskName, bundle) {
    bus.trigger('project.task.denying');
    request.delete(config.backend + '/workflow/' + project.workflowId + '/' + taskName, bundle)
    .done(function (res) {
        bus.trigger('project.task.denied', res.body);
    }).fail(function () {
        bus.trigger('project.task.pass.failed', project);
    });
};

module.exports = new ProjectStore();
