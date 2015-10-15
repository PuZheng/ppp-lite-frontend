var auth = require('./stores/auth.js');

var ofSameDepartment = function (need) {
    return function (project) {
        var ret = $.Deferred();
        if (project.department.id != auth.user().department.id) {
            ret.reject(need);
        } else {
            ret.resolve(need);
        }
        return ret;
    };
};

var ofSameOwner = function (need) {
    return function (project) {
        var ret = $.Deferred();
        if (project.ownerId != auth.user().id) {
            ret.reject(need);
        } else {
            ret.resolve(need);
        }
        return ret;
    };
};

var assignedToMe = function (need) {
    return function (project) {
        var ret = $.Deferred();
        if (project.consultantId == auth.user().id) {
            ret.resolve(need);
        } else {
            ret.reject(need);
        }
        return ret;
    };
};

module.exports = {
    '业主': {
        'project.view': ofSameDepartment('project.view'),
        'project.edit': ofSameOwner('project.edit'),
        'project.delete': ofSameOwner('project.delete'),
        'project.publish': ofSameOwner('project.publish'),
        'project.create': '',
        'project.chooseConsultant': ofSameOwner('project.chooseConsultant'),
        'project.upload': ofSameOwner('project.upload'),
        'project.deleteAssets': ofSameOwner('project.deleteAssets'),
    },
    'PPP中心': {
        'project.view': '',
        'project.preAudit': '',
        'project.upload': function (project) {
            var ret = $.Deferred();
            if (project.workflow && project.workflow.nextTasks.some(function (task) {
                return ~['预审', '实施方案审核'].indexOf(task.name);
            })) {
                ret.resolve('project.upload');
            } else {
                ret.reject('project.upload');
            }
            return ret;
        }
    },
    '咨询顾问': {
        'project.view': assignedToMe('project.view'),
        'project.invited': assignedToMe('project.invited'),
        'project.upload': function (project) {
            var ret = $.Deferred();
            assignedToMe('project.upload')(project).done(function () {
                if (project.workflow && project.workflow.nextTasks.some(function (task) {
                    return task.name === '提交实施方案';
                })) {
                    ret.resolve('project.upload');
                } else {
                    ret.reject('project.upload');
                }
            }).fail(function () {
                ret.reject('project.upload');
            });
            return ret;
        },
        'project.uploadScheme': function (project) {
            var ret = $.Deferred();
            assignedToMe('project.uploadScheme')(project).done(function () {
                if (project.workflow && project.workflow.nextTasks.some(
                    function (task) {
                        return task.name === '提交实施方案';
                    })
                ) {
                    ret.resolve('project.uploadScheme');
                } else {
                    ret.reject('project.uploadScheme');
                }
            }).fail(function () {
                ret.reject('project.uploadScheme');
            });
            return ret;
        }
    }
};
