var riot = require('riot');
var config = require('../config.js');
var bus = require('riot-bus');
var joinURL = require('join-url');
var auth = require('./auth.js');
var request = require('request');


var Assets = function () {
    var self = this;
    riot.observable(this);

    this.on('asset.upload', function (file, filename) {
        self.upload(file, filename);
    });
    this.on('asset.delete', function (path) {
        self.delete(path);
    });
};

Assets.prototype.upload = function (file, filename) {
    var fd = new FormData();
    fd.append('x-filenames', JSON.stringify([filename]));
    fd.append('files', file);
    $.ajax({
        url: config.uploadTo,
        type: 'POST',
        data: fd,
        processData: false,
        contentType: false,
        cache: false,
        headers: {
            Authorization: 'Bearer ' + auth.currentUser().token,
        },
        xhr: function() {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload){ // Check if upload property exists
                myXhr.upload.addEventListener(
                    'progress',
                    function (e) {
                        if(e.lengthComputable) {
                            bus.trigger('asset.upload.progress', e.loaded / e.total);
                        }
                    },
                    false); // For handling the progress of the upload
            }
            return myXhr;
        },
        beforeSend: function () {
            bus.trigger('before.asset.upload');
        },
    }).done(function (data) {
        bus.trigger('asset.upload.done', data.data);
    }).fail(function () {
        console.error('failed to upload');
        bus.trigger('asset.upload.failed');
    }).always(function () {
        bus.trigger('asset.upload.ended');
    });
};

Assets.prototype.delete = function (path) {
    bus.trigger('before.asset.delete');
    request.delete(joinURL(config.assetsBackend, path))
    .done(function (res) {
        bus.trigger('asset.delete.done', path);
    }).fail(function () {
        bus.trigger('asset.delete.failed');
    }).always(function () {
        bus.trigger('asset.delete.ended');
    });
};

module.exports = new Assets();
