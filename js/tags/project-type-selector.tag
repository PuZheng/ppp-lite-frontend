var riot = require('riot');;
var bus = require('riot-bus');
<project-type-selector>
  <div class="basic ui segment">
    <loader if={ loading }></loader>
    <div class="ui selection dropdown { opts.disabled? 'disabled': '' }" show={ projectTypes && projectTypes.length }>
      <input type="hidden" name="project_type_id" value={ opts.project.projectTypeId }>
      <i class="dropdown icon"></i>
      <div class="default text">选择项目类型</div>
      <div class="menu">
        <div class="item" each={ projectTypes } data-value="{ id }">{ name }</div>
      </div>
    </div>
  </div>

  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.on('projectTypeList.fetching', function () {
      self.loading = true;
      self.update();
    }).on('projectTypeList.fetched', function (data) {
      self.projectTypes = data.data;
      self.loading = false;
      self.update();
      var opts = {};
      self.opts.project && (opts.onChange = function (value, text,
                                                           $choice) {
          bus.trigger('project.update', self.opts.project.id, {
            'projectTypeId': value,
          })
      });
      $(self.root).find('.dropdown').dropdown(opts);
    });
    this.val = function () {
      return parseInt($(self.root).find('.dropdown').dropdown('get value')[0]);
    }
  </script>
</project-type-selector>
