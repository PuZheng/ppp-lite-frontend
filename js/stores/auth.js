function Auth() {


}

Auth.prototype.authenticated = function () {
    return false;
};

module.exports = new Auth();
