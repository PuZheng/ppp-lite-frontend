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
    }).on('todo.updated', function (todo) {
      if (todo.completed) {
        self.todos = self.todos.filter(function (todo_) {
          return todo_.id != todo.id;
        });
        self.update();
        var toastr = require('toastr/toastr.min.js');
        require('toastr/toastr.min.css');
        toastr.info('待办事项已经完成！', '', {
          positionClass: 'toast-bottom-center',
          timeOut: 1000,
        });
      }
    });

  </script>
</todo-list>
