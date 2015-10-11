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
      <div class="ui column" each={ asset in opts.project.assets }>
        <asset-item  asset={ asset } project={ parent.opts.project }></asset-item>
      </div>
    </div>
  </div>

  <style scoped>

    .segment > .assets {
      padding: 1rem;
    }

    .attached.segment {
      min-height: 48rem;
    }
    .attached.segment .assets {
      overflow: hidden;
    }

    .attached.segment .column {
      padding: 0;
    }

    input[type=file] {
      position: absolute;
      top: 0;
      right: 0;
      min-width: 100%;
      min-height: 100%;
      opacity: 0;
      display: block;
    }
  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);

    nprogress.configure({ trickle: false });

    self.on('mount', function () {
      _.extend(self, {
        $input: $(self.root).find('input[type=file]'),
      })
      self.$input.change(function (e) {
        var file = e.currentTarget.files[0];
        bus.trigger('asset.upload', file, self.opts.project.name + '/' + file.name);
        $(self.root).find('.attached.segment').perfectScrollbar();
      });
    }).on('before.asset.upload', function () {
      nprogress.start();
      self.loading = true;
      self.update;
    }).on('before.asset.delete', function () {
      self.loading = true;
      self.update;
    }).on('asset.upload.ended', function () {
      nprogress.done();
      self.$input.val('');
    }).on('asset.upload.progress', function (percent) {
      nprogress.set(percent)
    }).on('asset.upload.failed', function () {
      // TODO handle error
    }).on('asset.upload.done', function (assets) {
      bus.trigger('project.update', self.opts.project.id, {
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
      if (patch.assets) {
        if (patch.assets[0].op === 'add') {
          swal({
            type: 'success',
            title: '上传成功!',
          }, function () {
            self.opts.project.assets = self.opts.project.assets.concat(bundle);
            self.update();
          });
        } else if (patch.assets[0].op === 'delete') {
          swal({
            type: 'success',
            title: '删除成功!',
          }, function () {
            self.opts.project.assets = self.opts.project.assets.filter(function (asset) {
              return asset.id != patch.assets[0].id;
            });
            self.update();
          });
        }
      }
    }).on('asset.delete.done', function (path) {
      var asset = self.opts.project.assets.filter(function (asset) {
        return path === asset.path;
      });
      asset = asset && asset[0];
      if (asset) {
        bus.trigger('project.update', self.opts.project.id, {
          assets: [{
            op: 'delete',
            id: asset.id,
          }]
        });
      }
    });
  </script>
</assets-repo>
