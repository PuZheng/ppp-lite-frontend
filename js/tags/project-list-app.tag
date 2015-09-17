var riot = require('riot');
var bus = require('riot-bus');
require('./loader.tag');
require('./paginator.tag');
var Pagination = require('pagination');
var url = require('wurl');

<project-list-app>
  <loader if={ loading }></loader>
  <div class="ui six column grid">
    <div class="ui column" each={ projects }>
      <div class="ui card">
        <div class="content">
          <i class="right floated big blue icon { \{ '文教卫': 'university', '交通': 'road', '政法': 'legal', '水利': 'fork', '市政基础设施建设': 'building' \}[projectType.name] }"></i>
          <div class="header">
            { name }
          </div>
          <div class="meta">
            { projectType.name }
          </div>
          <div class="tags">
            <div class="ui yellow icon label">
              <i class="ui icon yen"></i>
              { parseInt(budget / 10000) } 万元
            </div>
          </div>
          <div class="description">
            { description }
          </div>
        </div>
        <div class="extra content">
          <div class="ui two buttons">
            <div class="ui basic green button">详情</div>
            <div class="ui basic red button">删除</div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <paginator if={ pagination } pagination={ pagination }></paginator>
  <style scoped>
    .card {
      height: 16rem;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.loading = false;
    self.projects = [];
    self.pagination = null;
    self.on('projectList.fetching', function () {
      self.loading = true;
      self.update();
    }).on('projectList.fetched', function (store) {
      self.loading = false;
      self.projects = store.data;
      self.pagination = new Pagination({
        currentPage: store.currentPage,
        totalCount: store.totalCount,
        perPage: store.perPage,
        leftEdge: 2,
        leftCurrent: 2,
        rightCurrent: 3,
        rightEdge: 2,
      }).toJSON();
      self.pagination.urlFor = function (page) {
        var query = url('?', url('hash')) || {};
        query.page = page;
        return '#project/list?' + _.pairs(query).map(function (pair) {
          return pair.join('=');
        }).join('&');
      };
      self.update();
    });
  </script>
</project-list-app>
