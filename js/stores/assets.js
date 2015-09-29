var riot = require('riot');
var config = require('../config.js');
var bus = require('riot-bus');

var Assets = function () {
    var self = this;
    riot.observable(this);

    this.on('upload', function (file, filename) {
        self.upload(file, filename);
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
        xhr: function() {  // Custom XMLHttpRequest
            var myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload){ // Check if upload property exists
                myXhr.upload.addEventListener(
                    'progress',
                    function (e) {
                        if(e.lengthComputable) {
                            bus.trigger('upload.progress', e.loaded / e.total);
                        }
                    },
                    false); // For handling the progress of the upload
            }
            return myXhr;
        },
        beforeSend: function () {
            bus.trigger('before.upload');
        },
    }).done(function (data) {
        bus.trigger('upload.done', data.data);
    }).fail(function () {
        console.error('failed to upload');
    }).always(function () {
        bus.trigger('upload.ended');
    });
};

module.exports = new Assets();
