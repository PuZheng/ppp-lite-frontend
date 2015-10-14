var riot = require('riot');
require('./loader.tag');
var bus = require('riot-bus');

<choose-consultant-form>
  <div class="ui basic modal">
    <i class="icon close"></i>
    <div class="header">请选择咨询顾问</div>
    <div class="content">
      <loader if={ self.loading }></loader>
      <div class="ui error message" if={ error }>{ error }</div>
      <form class="ui form">
        <div class="inline field">
          <div class="ui search selection consulting firm dropdown">
            <input type="hidden" name="consultant-firm">
            <i class="dropdown icon"></i>
            <div class="default text">选择咨询公司</div>
            <div class="menu">
              <div each={ _.values(firms) } class="item" data-value={ id }>{ name }</div>
            </div>
          </div>
          <div class="ui selection consultant dropdown">
            <input type="hidden" name="consultant">
            <i class="dropdown icon"></i>
            <div class="default text">选择咨询顾问</div>
            <div class="menu">
              <div each={ consultants } class="item" data-value={ id }>{ name || email }</div>
            </div>
          </div>
        </div>
        <div class="field">
          <textarea name="comment" cols="30" rows="10" placeholder="填写补充说明(可选)..."></textarea>
        </div>
      </form>
    </div>
    <div class="actions">
      <div class="ui black deny button">
        取消
      </div>
      <div class="ui positive button">
        确认
      </div>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.firms = {};

    self.on('mount', function () {
      self.$modal = $(self.root).find('.ui.modal').modal({
        onApprove: function () {
          var formEl = $(this).find('.ui.form')[0];
          if (!formEl.consultant.value) {
            self.error = '请选择咨询顾问';
            self.update();
            return false;
          }
          bus.trigger('task.pass', opts.project.workflowId, opts.task, {
            project: opts.project,
            comment: formEl.comment.value,
            consultant: formEl.consultant.value
          });
        },
        closable: false
      });
      self.$modal.find('.consulting.firm.dropdown').dropdown({
        onChange: function (value, text, $choice) {
          self.consultants = self.firms[value].consultants;
          self.update();
        }
      });
      self.$consultantDropdown = self.$modal.find('.consultant.dropdown').dropdown({
        onChange: function () {

        }
      });
      bus.trigger('userList.fetch', { role: '咨询顾问' });
    }).on('userList.fetching', function () {
      self.loading = true;
      self.update();
    }).on('userList.fetched', function (users) {
      users.forEach(function (user) {
        self.firms[user.firm.id] = self.firms[user.firm.id] || _.extend({
          consultants: []
        }, user.firm);
        self.firms[user.firm.id].consultants.push(user);
      });
      self.update();
    });

    self.activate = function () {
      self.$modal.modal('show');
    };
    self._ = _;
  </script>
</choose-consultant-form>

