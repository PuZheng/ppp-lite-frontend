
module.exports = function (test) {
    test = {
        'enter': function (e) {
            return e.which === 13;
        },
        'c-enter': function (e) {
            return (e.which === 13 || e.which === 10) && e.ctrlKey;
        }
    }[test];
    return function (e) {
        if (test(e)) {
            $(e.target).blur();
            return false;
        }
        return true;
    };
};
