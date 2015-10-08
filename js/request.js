var agent = require('superagent');
var auth = require('./stores/auth.js');
var noCache = require('superagent-no-cache');

function request() {
    var args = Array.prototype.slice.call(arguments);
    return request.get.apply(null, args);
}

['put', 'post', 'get', 'delete'].forEach(function (method) {
    request[method] = function (url, data) {
        var ret = $.Deferred();
        method === 'delete' && (method = 'del');
        var a = agent[method](url).use(noCache);
        !!data && (a = a.send(data));
        a.set('Authorization', 'Bearer ' + auth.currentUser().token)
        .type('json').accept('json').end(function (err, res) {
            if (err) {
                console.error(err);
                ret.reject(err, res);
            } else {
                ret.resolve(res);
            }
        });
        return ret;
    };
});


module.exports = request;
