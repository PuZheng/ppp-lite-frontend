
var riot = require('riot');
var principal = require('principal');
require('./basic-task-form.tag');

<pass-internal-audit-button>
  <button class="ui green button" if={ can } onclick={ handler }>通过实施方案</button>
  <basic-task-form if={can} project={ opts.project } event="task.pass" task="实施方案审核" header="您确认要通过设计方案内部审核？"></basic-task-form>
  <script>
    var self = this;
    self.on('update', function () {
      if (opts.ctx.user && opts.project && opts.project.workflow) {
        principal.permit('project.audit', opts.project).done(function () {
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
</pass-internal-audit-button>

