var riot = require('riot');
var bus = require('riot-bus');
require('./loader.tag');
require('./paginator.tag');
var Pagination = require('pagination');
var url = require('wurl');
var moment = require('moment');

<project-list-app>
  <button class="new ui green icon button" onclick={ newButtonClickHandler }>
    <i class="icon plus"></i>
    新建
  </button>
  <loader if={ loading }></loader>
  <div class="ui six column grid">
    <div class="ui column" each={ projects }>
      <a class="ui card" data-id={ id } onclick={ cardClickHandler }>
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
        <!--<div class="extra content">-->
          <!--<div class="ui two buttons">-->
            <!--<div class="ui basic green button">详情</div>-->
            <!--<div class="ui basic red button">删除</div>-->
          <!--</div>-->
        <!--</div>-->
      </a>
    </div>
  </div>
  <paginator if={ pagination } pagination={ pagination }></paginator>
  <style scoped>
    .card {
      min-height: 16rem;
      width: 100%;
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
        return '#project/project-list?' + _.pairs(query).map(function (pair) {
          return pair.join('=');
        }).join('&');
      };
      self.moment = moment; // otherwise, tag can't access moment
      self.update();
    });

    this.newButtonClickHandler = function (e) {
      riot.route('project/project-object?backref=' + encodeURIComponent('#' + url('hash')));
    }

    this.cardClickHandler = function (e) {
      riot.route('project/project-object/' + $(e.currentTarget).data('id') + '?backref=' + encodeURIComponent('#' + url('hash')));
    }
  </script>
</project-list-app>
