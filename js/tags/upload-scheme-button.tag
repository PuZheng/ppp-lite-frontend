var riot = require('riot');
var principal = require('principal');
require('./basic-task-form.tag');

<upload-scheme-button>
  <button class="delete ui blue button" if={ can } onclick={ handler }>提交实施方案</button>
  <basic-task-form if={ can } project={ opts.project } event="task.pass" task="提交实施方案" header="您确认要提交实施方案？"></basic-task-form>
  <script>
    var self = this;
    self.on('update', function () {
      if (opts.ctx.user && opts.project && opts.project.workflow) {
        principal.permit('project.uploadScheme', opts.project).done(function () {
          self.can = true;
        })
      }
    }).on('mount', function () {
      self.formTag = self.tags['basic-task-form'];
    });
    self.handler = function (e) {
      self.formTag.activate();
    };
  </script>
</upload-scheme-button>
