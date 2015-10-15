var riot = require('riot');
var principal = require('principal');
require('./basic-task-form.tag');

<deny-internal-audit-button>
  <button class="ui red button" if={ can } onclick={ handler }>驳回实施方案</button>
  <basic-task-form if={can} project={ opts.project } event="task.deny" task="实施方案内部审核" header="您确认要通过设计方案内部审核？"></basic-task-form>
  <script>
    var self = this;
    self.on('update', function () {
      if (opts.ctx.user && opts.project && opts.project.workflow) {
        principal.permit('project.internalAudit', opts.project).done(function () {
          self.can = true;
        });
      }
    }).on('mount', function () {
      self.formTag = self.tags['basic-task-form'];
    });
    self.handler = function (e) {
      self.formTag.activate();
    };
  </script>
</deny-internal-audit-button>

