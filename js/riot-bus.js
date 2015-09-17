function RiotBus() {

    this._observables = [];


}

RiotBus.prototype.register = function (observable) {
    console.log(observable + ' is registered');
    this._observables.push(observable);
};

RiotBus.prototype.unregister = function (observable) {
    console.log(observable + ' is unregistered');
    this._observables = this._observables.filter(function (o) {
        return o != observable;
    });
};

RiotBus.prototype.trigger = function (event) {

    var args = Array.prototype.slice.apply(arguments);
    this._observables.forEach(function (o) {
        o.trigger.apply(o, args);
    });
};

var riotBus = new RiotBus();
