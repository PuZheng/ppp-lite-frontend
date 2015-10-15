var riot = require('riot');
var principal = require('principal');
var bus = require('riot-bus');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');

<deny-invitation-button>
  <button class="ui red button" if={ can } onclick={ handler }>拒绝接受邀请</button>

  <script>
    var self = this;

    self.on('update', function () {
      if (opts.ctx.user && opts.project && opts.project.workflow) {
        principal.permit('project.invited', opts.project).done(function () {
          self.can = opts.project.workflow.nextTasks.some(function (task) {
            return task.name === '接受邀请';
          });
        });
      }
    });

    self.handler = function (e) {
      swal({
        type: 'warning',
        title: '确认拒绝接受邀请？',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('task.deny', self.opts.project.workflowId, '接受邀请', {
          project: opts.project,
        });
      });
    };
  </script>

</deny-invitation-button>
