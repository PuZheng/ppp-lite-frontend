var riot = require('riot');
var bus = require('riot-bus');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var principal = require('principal');
var auth = require('../stores/auth.js');
require('./publish-button.tag');
require('./delete-button.tag');
require('./deny-pre-audit-button.tag');
require('./pass-pre-audit-button.tag');
require('./choose-consultant-button.tag');
require('./accept-invitation-button.tag');
require('./deny-invitation-button.tag');
require('./upload-scheme-button.tag');
require('./pass-internal-audit-button.tag');
require('./deny-internal-audit-button.tag');
require('./pass-audit-button.tag');
require('./deny-audit-button.tag');

<control-panel>
  <div class="ui buttons">
    <delete-button project={ opts.project } ctx={ opts.ctx }></delete-button>
    <publish-button project={ opts.project } ctx={ opts.ctx }></publish-button>
    <deny-pre-audit-button project={ opts.project } ctx={ opts.ctx }></deny-pre-audit-button>
    <pass-pre-audit-button project={ opts.project } ctx={ opts.ctx }></pass-pre-audit-button>
    <choose-consultant-button project={ opts.project } ctx={ opts.ctx }></choose-consultant-button>
    <accept-invitation-button project={ opts.project } ctx={ opts.ctx }></accept-invitation-button>
    <deny-invitation-button project={ opts.project } ctx={ opts.ctx }></deny-invitation-button>
    <upload-scheme-button project={ opts.project } ctx={ opts.ctx }></upload-scheme-button>
    <pass-internal-audit-button project={ opts.project } ctx={ opts.ctx }></pass-internal-audit-button>
    <deny-internal-audit-button project={ opts.project } ctx={ opts.ctx }></deny-internal-audit-button>
    <pass-audit-button project={ opts.project } ctx={ opts.ctx }></pass-audit-button>
    <deny-audit-button project={ opts.project } ctx={ opts.ctx }></deny-audit-button>
  </div>
  <style scope>
    .ui.modal .content textarea {
      width: 100%;
      color: #333;
    }
  </style>
  <script>
    var self = this;
    _.extend(self, {
      can: {},
      _: _,
    });
    self.consultants = [
      { email: 'zx1@gmail.com' },
      { email: 'zx2@gmail.com' }
    ]
    self.on('project.published', function (project) {
      self.opts.project.workflowId = project.workflowId;
      self.opts.project.workflow = project.workflow;
      self.update();
    }).on('update', function () {
      $(self.root).find('.publish.modal .ui.dropdown').dropdown();
    });

    self.denyPreAudit = function (e) {
      self.$denyPreAuditModal = self.$denyPreAuditModal || $(self.root).find('.ui.deny.pre-audit.modal').modal({
        onApprove: function () {
          bus.trigger('project.task.deny', self.project, '预审', {
            reason: self.$denyPreAuditModal.find('textarea').val()
          });
        }
      });
      self.$denyPreAuditModal.modal('show');
    };

    self.passPreAudit = function (e) {
      swal({
        type: 'warning',
        title: '您确认该项目预审通过?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.task.pass', self.project, '预审');
      })
    };

    self.chooseConsultant = function (e) {
      e.stopPropagation();
      self.$chooseConsultantModal = self.$chooseConsultantModal || $(self.root).find('.ui.choose.consultant.modal').modal({
        onApprove: function () {
          bus.trigger('project.task.pass', self.project, '选择咨询公司', self.$chooseConsultantModal.find('input[name=consultant]').val());
        }
      });
      self.$chooseConsultantModal.modal('show');
      return false;
    };

    self.denyInvitation = function () {
      swal({
        type: 'warning',
        title: '您确认拒绝邀请?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.task.deny', self.project, '咨询公司接受邀请');
      });
    };

    self.publishScheme = function () {
      swal({
        type: 'warning',
        title: '您确认提交实施方案?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.task.pass', self.project, '提交实施方案');
      });
    };

    self.denySchemeInternally = function () {

    };

    self.acceptSchemeInternally = function () {
      /*
      swal({
        type: 'warning',
        title: '您确认接受咨询方案?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.task.pass', self.project, '实施方案内部审核');
      });
      */
    };

    self.denyScheme = function () {

    };

    self.acceptScheme = function () {
      swal({
        type: 'warning',
        title: '您确认接受咨询方案?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.task.pass', self.project, '实施方案审核');
      });
    };

  </script>
</control-panel>
