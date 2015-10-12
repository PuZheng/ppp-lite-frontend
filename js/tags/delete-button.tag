var riot = require('riot');
var principal = require('principal');
var bus = require('riot-bus');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');

<delete-button>
  <button class="delete ui red button" onclick={ handler } if={ can }>删除</button>

  <script>
    var self = this;
    self.on('update', function () {
      if (self.opts.ctx.user && self.opts.project) {
        principal.permit('project.delete', self.opts.project).done(function () {
          self.can = !self.opts.project.workflow;
        });
      }
    });

    self.handler = function (e) {
        e.stopPropagation();
        swal({
          type: 'warning',
          title: '您确认要删除该项目?',
          showCancelButton: true,
          closeOnConfirm: false,
        }, function (confirmed) {
          confirmed && bus.trigger('project.delete', self.opts.project.id);
        });
    };
  </script>
</delete-button>
