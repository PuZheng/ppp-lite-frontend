var riot = require('riot');
require('perfect-scrollbar/jquery')($);
require('perfect-scrollbar/dist/css/perfect-scrollbar.min.css');
var nprogress = require('nprogress/nprogress.js');
require('nprogress/nprogress.css');
require('./loader.tag');
var config = require('../config.js');
var bus = require('riot-bus');
require('./asset-item.tag');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');

<assets-repo>
  <loader if={ loading }></loader>
  <div class="ui top attached icon grey inverted menu">
    <a class="item">
      <i class="ui icon upload"></i>
      <input type="file" name="file">
    </a>
    <a class="item">
      <i class="ui icon trash"></i>
    </a>
  </div>
  <div class="ui attached segment">
    <div class="assets ui six column grid">
      <asset-item each={ asset in assets } asset={ JSON.stringify(asset) }></asset-item>
    </div>
  </div>

  <style scoped>

    .segment > .assets {
      padding: 1rem;
    }

    .attached.segment {
      height: 48rem;
    }
    .attached.segment .assets {
      overflow: hidden;
    }
  </style>

  <script>
    var self = this;
    self.assets = [];
    self.mixin(bus.Mixin);


    nprogress.configure({ trickle: false });

    self.on('mount', function () {
      _.extend(self, {
        $input: $(self.root).find('input[type=file]'),
      })
      self.$input.change(function (e) {
        var file = e.currentTarget.files[0];
        bus.trigger('upload', file, self.project.name + '/' + file.name);
        $(self.root).find('.attached.segment').perfectScrollbar();
      });
    }).on('before.upload', function () {
      nprogress.start();
      self.loading = true;
      self.update;
    }).on('upload.ended', function () {
      nprogress.done();
      self.$input.val('');
    }).on('upload.progress', function (percent) {
      nprogress.set(percent)
    }).on('upload.failed', function () {
      // TODO handle error
    }).on('upload.done', function (assets) {
      bus.trigger('project.update', self.opts['project-id'], {
        assets: assets.map(function (asset) {
          return {
            'op': 'add',
            'id': asset.id,
          };
        }),
      }, assets);
    }).on('project.updated', function (data, patch, bundle) {
      self.loading = false;
      self.update();
      swal({
        type: 'success',
        title: '上传成功!',
      });
      var $container = $(self.root).find('.assets');
      bundle.forEach(function (asset) {
        asset.filename = _.trimLeft(asset.filename, self.project.name + '/');
      });
      self.assets = self.assets.concat(bundle);
      self.update();
    }).on('project.fetching', function () {
      self.loading = false;
      self.update();
    }).on('project.fetched', function (project) {
      self.loading = false;
      self.project = project;
      self.assets = project.assets;
      self.assets.forEach(function (asset) {
        asset.filename = _.trimLeft(asset.filename, self.project.name + '/');
      });
      self.update();
    });
  </script>
</assets-repo>
