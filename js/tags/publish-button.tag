var riot = require('riot');
var principal = require('principal');
var bus = require('riot-bus');

<publish-button>
  <button class="ui blue button" if={ can } onclick={ handler }>发布</button>
  <div class="ui modal basic publish" if={ can }>
    <i class="icon close"></i>
    <div class="header">您确认要发布该项目？</div>
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
      <div class="ui red positive button">
        确认发布
      </div>
    </div>
  </div>
  <script>
    var self = this;

    self.on('mount', function () {
      principal.permit('project.publish', self.opts.project).done(function () {
        self.can = (!self.opts.project.workflow
          || self.opts.project.workflow.nextTasks.some(function (task) {
            return task.name === 'START';
          }));
        self.update();
      });
    }).on('update', function () {
      if (self.opts.ctx.user && self.opts.prject) {
        principal.permit('project.publish', self.opts.project).done(function () {
          self.can = (!self.opts.project.workflow
            || self.opts.project.workflow.nextTasks.some(function (task) {
              return task.name === 'START';
            }));
        });
      }
    });

    self.handler = function (e) {
        self.$publishModal = self.$publishModal || $(self.root).find('.publish.modal').modal({
          onApprove: function () {
            var formEl = $(this).find('.ui.form')[0];
            bus.trigger('project.publish', self.opts.project, {
              projectId: self.opts.project.id,
              project: self.opts.project,
              requestor: self.opts.ctx.user.id,
              comment: formEl.comment.value,
              attachments: formEl.attachments.value? formEl.attachments.value.split(',').map(function (id) {
                var asset = self.opts.project.assets.filter(function (asset) {
                  return asset.id == id;
                });
                return asset.length && asset[0];
              }): [],
            });
          },
          closable: false,
        });
        self.$publishModal.modal('show');
    };
  </script>
</publish-button>

