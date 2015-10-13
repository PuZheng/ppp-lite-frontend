var riot = require('riot');
var bus = require('riot-bus');
var principal = require('principal');
require('./basic-task-form.tag');

<deny-pre-audit-button>
  <button class="ui red button" if={ can } onclick={ handler }>驳回预审</button>
  <basic-task-form if={ can } project={ opts.project } event="task.deny" task="预审" header="您确认拒绝通过预审?"></basic-task-form>
  <script>
    var self = this;
    self.on('update', function () {
      if (self.opts.ctx.user && self.opts.project && self.opts.project.workflow) {
        principal.permit('project.preAudit').done(function () {
          self.can = self.opts.project.workflow.nextTasks.some(
            function (task) {
              return task.name === '预审';
            });
        })
      }
    }).on('mount', function () {
      self.formTag = self.tags['basic-task-form'];
    });
    self.handler = function (e) {
      self.formTag.activate();
    };
  </script>
</deny-pre-audit-button>
