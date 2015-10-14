var riot = require('riot');
var bus = require('riot-bus');

<basic-task-form>
  <div class="ui modal basic">
    <i class="icon close"></i>
    <div class="header">{ opts.header }</div>
    <div class="content">
      <form class="ui form">
        <div class="field">
          <textarea name="comment" cols="30" rows="10" placeholder="填写补充说明(可选)..."></textarea>
        </div>
        <div class="field">
          <div class="ui fluid multiple search selection dropdown { opts.disabled? 'disabled': '' }">
            <input type="hidden" name="attachments">
            <i class="dropdown icon"></i>
            <div class="default text">添加附件</div>
            <div class="menu">
              <div class="item" each={ opts.project.assets } data-value={ id }>{ filename.split('/')[1] }</div>
            </div>
          </div>
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
    self.on('mount', function () {
      $(self.root).find('.ui.dropdown').dropdown();
      self.onApprove = opts['on-approve'] || self.onApprove;
    });
    self.bundle = function () {
      var formEl = this.$modal.find('.ui.form')[0];
      return {
        projectId: opts.project.id,
        project: opts.project,
        comment: formEl.comment.value,
        attachments: formEl.attachments.value? formEl.attachments.value.split(',').map(function (id) {
          var asset = opts.project.assets.filter(function (asset) {
            return asset.id == id;
          });
          return asset.length && asset[0];
        }): [],
      };
    };
    self.onApprove =  function () {
      bus.trigger(opts.event, self.opts.project.workflowId, opts.task, self.bundle());
    };
    self.activate = function () {
      self.$modal = self.$modal || $(self.root).find('.modal').modal({
        onApprove: self.onApprove.bind(self),
        closable: false,
      });
      self.$modal.modal('show');
    };
  </script>
</basic-task-form>
