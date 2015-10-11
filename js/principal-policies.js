var auth = require('./stores/auth.js');

var ofSameDepartment = function (project) {
    var ret = $.Deferred();
    if (project.department.id != auth.user().department.id) {
        ret.reject('project.view');
    } else {
        ret.resolve();
    }
    return ret;
};

var ofSameOwner = function (project) {
    var ret = $.Deferred();
    if (project.ownerId != auth.user().id) {
        ret.reject('project.edit');
    } else {
        ret.resolve();
    }
    return ret;
};

module.exports = {
    '业主': {
        'project.view': ofSameDepartment,
        'project.edit': ofSameOwner,
        'project.delete': ofSameOwner,
        'project.publish': ofSameOwner,
    },
    'PPP中心': {
        'project.view': '',
    }
};
