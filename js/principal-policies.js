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
    },
    'PPP中心': {
        'project.view': '',
        'project.preAudit': ''
    },
    '咨询顾问': {
        'project.view': assignedToMe('project.view'),
        'project.acceptInvitation': assignedToMe('project.acceptInvitation'),
    }
};
