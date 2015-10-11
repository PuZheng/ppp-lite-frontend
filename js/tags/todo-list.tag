var riot = require('riot');
var bus = require('riot-bus');
require('./todo-item.tag');

<todo-list>
  <div class="ui segment">
    <div class="ui divided items">
      <todo-item each={ todo in todos } todo={ todo }></todo-item>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    this.on('todos.fetched', function (data) {
      self.todos = data.data;
      self.update();
    });

  </script>
</todo-list>
