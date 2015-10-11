var riot = require('riot');
require('./project-primary.tag');
require('./assets-repo.tag');
var bus = require('riot-bus');
var principal = require('principal');
var page = require('page');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');

<project-app>
  <div class="ui grid">
    <div class="row">
      <div class="column">
        <div class="ui basic main segment">
          <loader if={ loading }></loader>
          <div class="ui top attached tabular menu" if={ !loading }>
            <div class="item">
              <div class="ui large blue header">
                { project? project.name: '创建项目' }
              </div>
            </div>
            <a class="active item" data-tab="basic">基本信息</a>
            <a class="item" data-tab="assets" show={ project }>资源仓库</a>
          </div>
          <div class="ui bottom attached tab active segment" data-tab="basic" if={ !loading }>
            <project-primary project={ project } if={ project }></project-primary>
          </div>
          <div class="ui bottom attached tab segment" data-tab="assets" show={ project }>
            <assets-repo project={ project } if={ project }></assets-repo>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.on('mount', function () {
      $(self.root).find('.menu .item').tab();
    }).on('project.fetching project.saving project.updating project.publishing project.task.passing project.task.denying', function () {
      self.loading = true;
      self.update();
    }).on('project.fetched', function (project) {
      principal.permit('project.view', project).done(function () {
        self.project = project;
        self.loading = false;
        self.update();
      }).fail(function (need) {
        swal({
          type: 'error',
          title: '非法操作',
          text: '您无权查看本项目',
        }, function () {
          page('/');
        });
      });
    }).on('project.saved', function (project) {
      self.loading = false;
      self.project = project;
      self.update();
      swal({
        type: 'success',
        title: '成功创建',
        cancelButtonText: '返回上级',
        showConfirmButton: true,
        showCancelButton: true,
        confirmButtonText: '继续编辑',
      }, function (confirmed) {
        if (confirmed) {
          page.redirect('project/object/' + self.project.id);
        } else {
          history.back();
        }
      });
    }).on('project.updated', function (project, patch, bundle) {
      self.loading = false;
      self.update();
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('project.deleting', function () {
      self.loading = true;
      self.update();
    }).on('project.deleted', function () {
      self.loading = false;
      self.update();
      swal({
        type: 'success',
        title: '该项目已删除!',
      }, function () {
        page('/'); // TODO should return to a back ref
      });
    }).on('project.published', function (workflow) {
      self.loading = false;
      swal({
        type: 'success',
        title: '该项目已经发布!'
      }, function () {
        self.project.workflow = workflow;
        self.update();
      });
    }).on('project.task.passed project.task.denied', function (which, workflow) {
      self.loading = false;
      swal({
        type: 'success',
        title: '操作成功!'
      }, function () {
        self.project.workflow = workflow;
        self.update();
      })
    });
  </script>
</project-app>
