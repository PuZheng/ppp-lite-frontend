var riot = require('riot');
var bus = require('riot-bus');

<project-list-filter>
  <div class="ui only myself checkbox">
    <input type="checkbox" name="onlyMyself">
    <label>仅展示本人项目</label>
  </div>
  <script>
    var self = this;
    self.on('mount', function () {
      $(self.root).find('.only.myself.checkbox').checkbox({
        onChange: function () {
          bus.trigger('projectList.filter', {
            onlyMyself: $(this).is(':checked'),
          });
        }
      });
    });

  </script>
</project-list-filter>
