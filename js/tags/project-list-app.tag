var riot = require('riot');
var bus = require('riot-bus');
require('./loader.tag')

<project-list-app>
  <loader if={ loading }></loader>
  <div class="ui four column grid">
    <div class="ui column" each={ projects }>{ name }</div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.loading = false;
    self.projects = [];
    self.on('projectList.fetching', function () {
      self.loading = true;
      self.update();
    }).on('projectList.fetched', function (store) {
      self.loading = false;
      self.projects = store.data;
      self.totalCount = store.totalCount;
      self.update();
    });
  </script>
</project-list-app>
