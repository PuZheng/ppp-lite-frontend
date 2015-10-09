var riot = require('riot');
var bus = require('riot-bus');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var principal = require('principal');

<control-panel>
  <div class="ui buttons">
    <button class="delete ui red button" onclick={ deleteHandler } if={ can.delete }>删除</button>
    <button class="delete ui blue button" if={ !project.workflow && can.publish } onclick={ publishHandler }>发布</button>
    <raw each={ project.workflow.nextTasks }>
      <button class="delete ui blue button" if={ name === 'START' && role === '业主' } onclick={ publishHandler }>发布</button>

      <button class="delete ui red button" if={ name === '预审' && parent.role === 'PPP中心' } onclick={ denyPreAudit }>驳回预审</button>
      <button class="delete ui green button" if={ name === '预审' && parent.role === 'PPP中心' } onclick={ passPreAudit }>通过预审</button>
      <div class="ui small modal deny pre-audit" if={ name == '预审' && parent.role === 'PPP中心' }>
        <i class="close icon"></i>
        <div class="header">
          请填写驳回意见
        </div>
        <div class="content">
          <textarea cols="80" rows="10"></textarea>
        </div>
        <div class="actions">
          <div class="ui black deny button">
            取消
          </div>
          <div class="ui red positive button">
            确认驳回
          </div>
        </div>
      </div>

      <button class="delete ui blue button" if={ name === '选择咨询公司' && parent.role === '业主' } onclick={ chooseConsultant }>选择咨询公司</button>

      <div class="ui small choose consultant modal" if={ name == '选择咨询公司' && parent.role === '业主' }>
        <i class="close icon"></i>
        <div class="header">
          请选择咨询公司
        </div>
        <div class="content">
          <div class="grouped fields">
            <raw each={ consultant, i in consultants }>
              <div class="field">
                <div class="ui radio checkbox">
                  <input type="radio" name="consultant">
                  <label>{ consultant.email }</label>
                </div>
              </div>
            </raw>
          </div>
        </div>
        <div class="actions">
          <div class="ui black deny button">
            取消
          </div>
          <div class="ui red positive button">
            确认
          </div>
        </div>
      </div>

      <button class="delete ui red button" if={ name === '咨询公司接受邀请' && parent.role === '咨询顾问' } onclick={ denyInvitation  }>拒绝邀请</button>
      <button class="delete ui blue button" if={ name === '咨询公司接受邀请' && parent.role === '咨询顾问' } onclick={ acceptInvitaion }>接受邀请</button>

      <button class="delete ui blue button" if={ name === '提交实施方案' && parent.role === '咨询顾问' } onclick={ publishScheme }>提交实施方案</button>

      <button class="delete ui red button" if={ name === '实施方案内部审核' && parent.role === '业主' } onclick={ denySchemeInternally  }>驳回实施方案</button>
      <button class="delete ui blue button" if={ name === '实施方案内部审核' && parent.role === '业主' } onclick={ acceptSchemeInternally }>通过实施方案</button>

      <button class="delete ui red button" if={ name === '实施方案审核' && parent.role === 'PPP中心' } onclick={ denyScheme }>驳回实施方案</button>
      <button class="delete ui blue button" if={ name === '实施方案审核' && parent.role === 'PPP中心' } onclick={ acceptScheme }>通过实施方案</button>

    </row>
  </div>
  <script>
    var self = this;
    self.can = {};
    self.consultants = [
      { email: 'zx1@gmail.com' },
      { email: 'zx2@gmail.com' }
    ]
    self.on('mount', function () {
      ['delete', 'publish'].forEach(function (op) {
        principal.permit('project.' + op, self.opts.project).done(function () {
          self.can[op] = true;
          self.update();
        });
      })
    }).on('update', function () {
      if (self.opts.project) {
        self.project = self.opts.project;
        console.log(self.project);
      }
      if (self.opts.user) {
        self.user = self.opts.user;
        self.role = self.user.role.name;
      }
    });
    self.deleteHandler = function (e) {
      e.stopPropagation();
      swal({
        type: 'warning',
        title: '您确认要删除该项目?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.delete', self.project.id);
      });
    };

    self.publishHandler = function (e) {
      e.stopPropagation();
      swal({
        type: 'warning',
        title: '您确认要发布该项目?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.publish', self.project);
      });
    };

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

    self.acceptInvitaion = function () {
      swal({
        type: 'warning',
        title: '您确认接受邀请?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.task.pass', self.project, '咨询公司接受邀请');
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
      swal({
        type: 'warning',
        title: '您确认接受咨询方案?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        confirmed && bus.trigger('project.task.pass', self.project, '实施方案内部审核');
      });

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
