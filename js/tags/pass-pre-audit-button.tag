var riot = require('riot');
var principal = require('principal');
require('./basic-task-form.tag');

<pass-pre-audit-button>
  <button class="ui green button" if={ can } onclick={ handler }>通过预审</button>
  <basic-task-form if={can} project={ opts.project } event="task.pass" task="预审" header="您确认要通过预审？"></basic-task-form>
  <script>
    var self = this;
    self.on('update', function () {
      if (opts.ctx.user && opts.project && opts.project.workflow) {
        principal.permit('project.preAudit').done(function () {
          // TODO move to policies
          self.can = self.opts.project.workflow.nextTasks.some(
            function (task) {
              return task.name === '预审';
            });
        });
      }
    }).on('mount', function () {
      self.formTag = self.tags['basic-task-form'];
    });
    self.handler = function (e) {
      self.formTag.activate();
    };
  </script>
</pass-pre-audit-button>
