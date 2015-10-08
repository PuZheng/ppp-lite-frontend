var riot = require('riot');
var config = require('config');
var bus = require('riot-bus');
var request = require('superagent');
var noCache = require('superagent-no-cache');

function Auth() {
    riot.observable(this);
    this.on('login', function (email, password) {
        this.login(email, password);
    });
    this.on('logout', function () {
        this.logout();
    });
}

Auth.prototype.login = function (email, password) {
    var self = this;
    bus.trigger('loggingIn');
    request.post(config.backend + '/auth/login')
    .use(noCache)
    .type('json')
    .accept('json')
    .send({
        email: email,
        password: password
    })
    .end(function (err, res) {
        if (err) {
            bus.trigger('login.failed', res.body.reason);
        } else {
            self._user = res.body;
            sessionStorage.setItem('user', res.text);
            bus.trigger('login.success', res.body);
        }
    });
};

Auth.prototype.logout = function (email, password) {
    self._user = null;
    sessionStorage.removeItem('user');
    bus.trigger('logout.done');
};

Auth.prototype.authenticated = function () {
    this._user = this._user || JSON.parse(sessionStorage.getItem('user'));
    return !!this._user;
};

Auth.prototype.currentUser = function () {
    return this._user;
};

module.exports = new Auth();
