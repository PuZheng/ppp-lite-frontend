var riot = require('riot');
var page = require('page');

<todo-item>
  <div class="item">
    <div class="ui left floated compact segment">
      <div class="ui slider checkbox fitted">
        <input type="checkbox">
        <label for=""></label>
      </div>
    </div>
    <div class="content" if={ opts.todo.type === 'pre-audit' } onclick={ clickHandler }>
      <div class="ui header">
        请预审项目<em>{ opts.todo.bundle.project.name }</em>
      </div>
      <div class="description">
        <ul class="ui list">
          <li>备注 - { opts.todo.bundle.comment }</li>
          <li if={ opts.todo.bundle.attachments && opts.todo.bundle.attachments.length }>附件 - { _.pluck(opts.todo.bundle.attachments, 'filename') }</li>
        </ul>
      </div>
    </div>
  </div>
  <style scoped>
    .content {
      margin-left: 10rem;
    }
  </style>
  <script>
    var self = this;
    _.extend(self, {
      _: _,
      clickHandler: function (e) {
        page('/project/object/' + self.opts.todo.bundle.projectId);
      }
    });
  </script>
</todo-item>
