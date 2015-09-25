var riot = require('riot');
var bus = require('riot-bus');
require('./loader.tag');
require('./paginator.tag');
var Pagination = require('pagination');
var url = require('wurl');
var moment = require('moment');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var page = require('page');

<project-list-app>
  <a class="new ui green icon button" href='/project/object'>
    <i class="icon plus"></i>
    新建
  </a>
  <loader if={ loading }></loader>
  <div class="ui six column grid">
    <div class="ui column" each={ projects }>
      <a class="ui card" data-id={ id } onclick={ cardClickHandler } >
        <div class="ui bottom right corner label">
          <i class="delete icon" onclick={ deleteHandler } data-project-id={ id }></i>
        </div>
        <div class="content">
          <i class="right floated big blue icon { \{ '文教卫': 'university', '交通': 'road', '政法': 'legal', '水利': 'fork', '市政基础设施建设': 'building' \}[projectType.name] }"></i>
          <div class="header">
            { name }
          </div>
          <div class="meta">
            { projectType.name }
            <span>-</span>
            { moment(createdAt).format('l') }
          </div>
          <div class="tags">
            <div class="ui yellow icon label">
              <i class="ui tiny icon yen"></i>
              { parseInt(budget / 10000) } 万元
            </div>
          </div>
          <div class="description">
            { description.length > 64? description.substr(0, 64) + '...': description }
          </div>
        </div>
        <div class="extra content">
          <span class="ui red label" each={ tags }>{ value }</span>
        </div>
      </a>
    </div>
  </div>
  <paginator if={ pagination } pagination={ pagination }></paginator>
  <style scoped>
    .card {
      min-height: 16rem;
      width: 100%;
    }
    .card .ui.label {
      margin-left: 0;
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
      self.pagination.urlFor = function (pageNo) {
        var query = url('?') || {};
        query.page = pageNo;
        return '/project/list?' + _.pairs(query).map(function (pair) {
          return pair.join('=');
        }).join('&');

      };
      self.moment = moment; // otherwise, tag can't access moment
      self.update();
    }).on('project.deleting', function () {
      self.loading = true;
      self.update();
    }).on('project.deleted', function (id) {
      self.loading = false;
      self.projects = self.projects.filter(function (p) {
        return p.id != id;
      })
      self.update();
    });

    this.cardClickHandler = function (e) {
      page('project/object/' + $(e.currentTarget).data('id'));
    };

    this.deleteHandler = function (e) {
      e.stopPropagation();

      swal({
        type: 'warning',
        title: '您确认要删除该项目?',
        showCancelButton: true,
      }, function (confirmed) {
        confirmed && bus.trigger('project.delete', $(e.target).data('project-id'));
      });
    };
  </script>
</project-list-app>
