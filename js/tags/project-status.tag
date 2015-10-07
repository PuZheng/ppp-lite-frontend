var riot = require('riot');
<project-status>
  <div class="ui teal message">
    <div class="ui tiny header">
      本项目正在等待<i>{ nextTasks }</i>
    </div>
  </div>
  <style scoped>
    .ui.teal.message {
      margin-bottom: 2.5rem;
    }
    .tiny.header > i {
      display: inline-block;
      margin: 0 0.2rem;
    }
  </style>
  <script>
    var self = this;
    self.on('update', function () {
      if (self.opts.workflow) {
        self.nextTasks = self.opts.workflow.nextTasks.map(function (task) {
          return task.name
        }).join('|');
      }
    })
  </script>
</project-status>
