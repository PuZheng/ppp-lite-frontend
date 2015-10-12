var riot = require('riot');
var bus = require('riot-bus');
require('./loader.tag');
var url = require('wurl');
var moment = require('moment');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var page = require('page');
require('perfect-scrollbar/jquery')($);
require('perfect-scrollbar/dist/css/perfect-scrollbar.min.css');
require('./project-list-filter.tag');

<project-list-app>
  <div class="ui top attached tabular menu">
    <a class="new ui green icon button" href='/project/object'>
      <i class="icon plus"></i>
      新建
    </a>
    <a class="{ (opts.ctx.path === '/project/progressing-list')? 'active': '' } item" href="/project/progressing-list">
      进行中
    </a>
    <a class="{ opts.ctx.path == '/project/unpublished-list'? 'active': ''} item" href="/project/unpublished-list" if={ opts.ctx.user.role.name != 'PPP中心' }>
      未发布
    </a>
  </div>
  <div class="ui attached segment" if={ !_.isEmpty(projects) }>
      <project-list-filter></project-list-filter>
  </div>
  <div class="ui bottom grey attached segment">
    <loader if={ loading }></loader>

    <div class="empty ui center aligned basic segment" if={ _.isEmpty(projects) }>
      <h1 class="ui header">列表为空</h1>
    </div>
    <div class="ui six column grid" if={ !_.isEmpty(projects) }>
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
              由<em>{ owner.name || owner.email }</em>创建于
              { moment(createdAt).format('YY/MM/DD') }
            </div>
            <div>
              <div class="ui yellow icon label">
                <i class="ui tiny icon yen"></i>
                { parseInt(budget / 10000) } 万元
              </div>
            </div>
            <div class="description">
              { description.length > 64? description.substr(0, 64) + '...': description }
            </div>
            <div class="ui label" if={ workflow }>
              <div class="ui tiny header">
                等待
                <raw each={ workflow.nextTasks }>
                  { name }
                </raw>
              </div>
            </div>
          </div>
          <div class="extra content">
            <span class="ui red label" each={ tags }>{ value }</span>
          </div>
        </a>
      </div>
    </div>
  </div>
  <style scoped>
    .bottom.attached.segment {
      min-height: 36rem;
    }
    .bottom.attached.segment .empty {
      height: 36rem;
    }
    .bottom.attached.segment .empty .header {
      color: #aaa;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    }
    .card {
      min-height: 16rem;
      width: 100%;
    }
    .card .ui.label {
      margin-left: 0;
    }
    .card .meta em {
      font-weight: bold;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.on('mount', function () {
      (function ($scrollable) {
        $scrollable.css('max-height', window.innerHeight - $scrollable.offset().top).perfectScrollbar();
      })($(self.root).find('.bottom.attached.segment'));
    }).on('projectList.fetching', function () {
      self.loading = true;
      self.update();
    }).on('projectList.fetched projectList.filtered', function (which, projects) {
      self.loading = false;
      self.projects = projects;
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
    _.extend(self, {
      loading: false,
      projects: [],
      _: _,
      cardClickHandler: function (e) {
        page('project/object/' + $(e.currentTarget).data('id'));
      },
      deleteHandler: function (e) {
        e.stopPropagation();

        swal({
          type: 'warning',
          title: '您确认要删除该项目?',
          showCancelButton: true,
        }, function (confirmed) {
          confirmed && bus.trigger('project.delete', $(e.target).data('project-id'));
        });
      }
    });
  </script>
</project-list-app>
