var riot = require('riot');
<project-status>
  <div>
    本项目正在等待<span class="ui tiny header">{ nextTasks }</span>
  </div>
  <style scoped>
    span.tiny.header {
      display: inline-block !important;
      margin: 0 0.2rem !important;
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
