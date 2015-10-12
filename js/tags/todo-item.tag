var riot = require('riot');
var page = require('page');

<todo-item>
  <div class="content" if={ opts.todo.type === 'pre-audit' } onclick={ clickHandler }>
    <div class="ui small header">
      <div class="ui checkbox" data-content="标记完成" onclick={ completeHandler }>
        <input type="checkbox">
        <label for=""></label>
      </div>
       { opts.todo.summary }</em>
    </div>
    <div class="ui horizontal list">
      <div class="item">备注 - { opts.todo.bundle.comment }</div>
      <div class="item" if={ opts.todo.bundle.attachments && opts.todo.bundle.attachments.length }>附件 - { _.pluck(opts.todo.bundle.attachments, 'filename') }</div>
    </div>
  </div>
  <style scoped>
    .content .ui.checkbox {
      display: inline-block;
    }
    .content .header {
      display: inline-block;
    }
    .content .ui.list {
      color: #666;
    }
  </style>
  <script>
    var self = this;
    self.on('mount', function () {
      $(self.root).find('.ui.checkbox').popup().checkbox();
    });
    _.extend(self, {
      _: _,
      clickHandler: function (e) {
        page('/project/object/' + self.opts.todo.bundle.projectId);
      },
      completeHandler: function (e) {
        e.stopPropagation();
      }
    });

  </script>
</todo-item>
