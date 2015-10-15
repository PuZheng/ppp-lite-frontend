var riot = require('riot');
var page = require('page');
var bus = require('riot-bus');

<todo-item>
  <div class="content" if={ ~['pre-audit', 'publish', 'choose-consultant', 'accept-invitation', 'upload-scheme', 'internal-audit', 'audit'].indexOf(opts.todo.type) } onclick={ clickHandler }>
    <div class="ui small header">
      <div class="ui checkbox" data-content="标记完成" onclick={ completeHandler }>
        <input type="checkbox">
        <label for=""></label>
      </div>
       { opts.todo.summary }</em>
    </div>
    <div class="ui horizontal list">
      <div class="item" if={ opts.todo.bundle.comment }>备注 - { opts.todo.bundle.comment }</div>
      <div class="item" if={ filenames }>附件 - { filenames.join('; ') }</div>
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
      $(self.root).find('.ui.checkbox').popup().checkbox({
        onChecked: function () {
          bus.trigger('todo.update', opts.todo.id, {
            completed: true,
          })
        },
      });
      if (opts.todo.bundle.attachments) {
        self.filenames = _.pluck(opts.todo.bundle.attachments, 'filename').map(function (fname) {
          return fname.split('/')[1];
        });
        self.update();
      }
    });
    _.extend(self, {
      _: _,
      clickHandler: function (e) {
        page('/project/object/' + self.opts.todo.bundle.project.id);
      },
      completeHandler: function (e) {
        e.stopPropagation();
      }
    });
  </script>
</todo-item>
