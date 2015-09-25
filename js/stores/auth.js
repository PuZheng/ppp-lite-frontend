var riot = require('riot');
var config = require('config');
var bus = require('riot-bus');

function Auth() {
    var self = this;
    riot.observable(this);
    this.on('login', function (email, password) {
        bus.trigger('loggingIn');
        $.ajax({
            url: config.backend + '/auth/login',
            type: 'POST',
            data: JSON.stringify({
                email: email,
                password: password
            }),
            contentType: 'application/json; charset=UTF-8',
            dataType: 'json',  // if the format of response should be json
        }).done(function (data, textStatus, jqXHR) {
            this._user = data;
            sessionStorage.setItem('user', JSON.stringify(data));
            bus.trigger('login.success', data);
        }).fail(function (data) {
            bus.trigger('login.failed', data.responseJSON.reason);
        });
    });
}

Auth.prototype.authenticated = function () {
    self._user = self._user || JSON.parse(sessionStorage.getItem('user'));
    return !!self._user;
};



module.exports = new Auth();
