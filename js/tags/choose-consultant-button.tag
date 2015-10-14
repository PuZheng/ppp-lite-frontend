var riot = require('riot');
var principal = require('principal');
require('./choose-consultant-form.tag');

<choose-consultant-button>
  <button class="delete ui blue button" if={ can } onclick={ handler }>选择咨询公司</button>
  <choose-consultant-form if={ can } project={ opts.project } task="选择咨询公司"></choose-consultant-form>
  <script>
    var self = this;

    self.on('update', function () {
      if (opts.ctx.user && opts.project && opts.project.workflow) {
        principal.permit('project.chooseConsultant', opts.project).done(function () {
          self.can = opts.project.workflow.nextTasks.some(function (task) {
            return task.name === '选择咨询公司';
          })
        })
      }
    });

    self.handler = function () {
      self.tags['choose-consultant-form'].activate();
    };
  </script>

</choose-consultant-button>
