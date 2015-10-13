var riot = require('riot');
var principal = require('principal');
var bus = require('riot-bus');
require('./basic-task-form.tag');

<publish-button>
  <button class="ui blue button" if={ can } onclick={ handler }>发布</button>
  <basic-task-form if={can} project={ opts.project } event="project.publish" header="您确认要发布项目?" task="START" on-approve={ onApprove }></basic-task-form>
  <script>
    var self = this;

    self.on('update', function () {
      if (self.opts.ctx.user && self.opts.project) {
        principal.permit('project.publish', self.opts.project).done(function () {
          self.can = (!self.opts.project.workflow
            || self.opts.project.workflow.nextTasks.some(function (task) {
              return task.name === 'START';
            }));
        });
      }
    }).on('mount', function () {
      self.formTag = self.tags['basic-task-form'];
    });

    self.handler = function (e) {
      self.formTag.activate();
    };

    self.onApprove = function () {
      var formEl = $(this.root).find('.ui.form')[0];
      if (!self.opts.project.workflow) {
        bus.trigger('project.publish', self.opts.project, self.formTag.bundle());
      } else {
        bus.trigger('task.pass', self.opts.project.workflow.id, 'START', self.formTag.bundle());
      }
    }
  </script>
</publish-button>

