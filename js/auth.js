var bus = require('riot-bus');

function Auth() {
}

Auth.prototype.loginRequired = function () {
    bus.trigger('loginRequired');
};

module.exports = new Auth();
