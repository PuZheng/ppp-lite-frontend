var riot = require('riot');
var config = require('config');
var joinURL = require('join-url');
var moment = require('moment');
var bus = require('riot-bus');

var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');

<asset-item>
  <div class="ui column">
    <div class="ui card" onclick={ cardClickHandler } >
      <a class="ui bottom left corner label" onclick={ downloadHandler }>
        <i class="download yellow icon"></i>
      </a>
      <div class="ui bottom right corner label">
        <i class="delete icon" onclick={ deleteHandler }></i>
      </div>
      <div class="content">
        <div class="middle aligned item">
          <!--TODO thumbnail-->
          <i class="massive icon file outline"></i>
        </div>
        <div class="meta">
          <div class="type indicator">
            <i class="tiny red icon file image outline"></i>
          </div>
          <div class="filename">
            { asset.filename }
          </div>
          <div class="ui blue tiny header">
            { moment(asset.createdAt).format('l HH时') }
          </div>
        </div>
      </div>
      <!--TODO show tags-->
      <!--<div class="extra content">-->
      <!--</div>-->
    </div>
  </div>

  <style scoped>
    .column {
      padding: 1rem;
    }
    .card {
      max-height: 16rem;
      height: 16rem;
    }
    .content {
      text-align: center;
    }
    .meta .tiny.header {
      margin-top: 0;
    }
    .type.indicator {
      float: left;
    }
    .filename {
      overflow: hidden;
      text-overflow: ellipsis;
    }
  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.on('mount', function () {
      self.asset = JSON.parse(self.opts.asset);
    }).on('asset.delete.done', function (path) {
      if (path === self.asset.path) {
        bus.trigger('project.update', self.opts.projectId, {
          assets: [{
            op: 'delete',
            id: self.asset.id,
          }]
        });
      }
    }).on('project.updated', function (data, patch) {
      if (patch.assets && patch.assets[0].op === 'delete' && patch.assets[0].id === self.asset.id) {
        swal({
          type: 'success',
          title: '删除成功!',
        }, function () {
          self.unmount();
        });
      }
    }).on('asset.delete.failed', function () {
      // TODO handle error
    });;
    _.extend(self, {
      downloadHandler: function () {
        console.log('download');
        window.open(config.assetsBackend + '/' + self.asset.path);
        return false;
      },
      joinURL: joinURL,
      config: config,
      moment: moment,
      deleteHandler: function (e) {
        swal({
          type: 'warning',
          title: '警告',
          text: '您确认要删除该文件?',
          showCancelButton: true,
          closeOnConfirm: false
        }, function (confirmed) {
          confirmed && bus.trigger('asset.delete', self.asset.path);
        })
      }
    });
  </script>
</asset-item>
