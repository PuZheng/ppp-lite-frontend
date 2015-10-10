var principal = require('principal');
var policies = require('./principal-policies.js');


principal.onIdentityChanged(function (provides, ctx) {
    var rolePolicies = policies[ctx.user.role.name] || {};
    for (var k in  rolePolicies) {
        provides.append(k, rolePolicies[k] || undefined);
    }
});
