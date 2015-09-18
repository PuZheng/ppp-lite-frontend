var riot = require('riot');;
<project-type-selector>
  <div class="basic ui segment">
    <loader if={ !projectTypes.length }></loader>
  </div>
  <div class="ui selection dropdown" show={ projectTypes.length }>
    <input type="hidden" name="gender" value={ id }>
    <i class="dropdown icon"></i>
    <div class="default text">选择项目类型</div>
    <div class="menu">
      <div class="item" each={ projectTypes } data-value="{ id }">{ name }</div>
    </div>
  </div>

  <script>
    var self = this;
    self.projectTypes = [];
    self.on('update', function () {
      self.id = self.opts['id'];
      if (!_.isEmpty(this.opts['project-types'])) {
        self.projectTypes = this.opts['project-types'];
        $(self.root).find('.dropdown').dropdown({
        });
      }
    });
    this.val = function () {
      return parseInt($(self.root).find('.dropdown').dropdown('get value')[0]);
    }
  </script>
</project-type-selector>
