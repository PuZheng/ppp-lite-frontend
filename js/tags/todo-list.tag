var riot = require('riot');
var bus = require('riot-bus');
require('./todo-item.tag');

<todo-list>
  <div class="ui basic segment">
    <div class="ui celled list">
      <div riot-tag="todo-item" class="item" each={ todo in todos } todo={ todo }></div>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    this.on('mount', function () {
      riot.mount('todo-item');
    }).on('todos.fetched', function (data) {
      self.todos = data.data;
      self.update();
    });

  </script>
</todo-list>
