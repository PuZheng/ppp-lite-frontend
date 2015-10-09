var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
require('./project-type-selector.tag');
require('./tag-editor.tag');
require('./assets-repo.tag');
require('./control-panel.tag');
require('./project-status.tag');
var page = require('page');
var makeBlurWhenPress = require('make-blur-when-press');
var moment = require('moment');


<project-app>

  <div class="ui grid">
    <div class="row">
      <div class="column">
        <div class="ui basic segment">
          <div class="ui top attached tabular menu">
            <div class="item">
              <div class="ui large blue header">
                { project? project.name: '创建项目' }
              </div>
            </div>
            <a class="active item" data-tab="basic">基本信息</a>
            <a class="item" data-tab="assets" show={ project }>资源仓库</a>
          </div>
          <div class="ui bottom attached tab active segment" data-tab="basic">
            <div class="ui basic segment">
              <loader if={ loading }></loader>
              <project-status if={ project.workflow } workflow={ project.workflow }></project-status>
              <div class="ui meta teal message">
                <ul class="list">
                  <li>创建人 - <em>{ project.owner.name || project.owner.email }</em></li>
                  <li>部门 - <em>{ project.department.name }</em></li>
                  <li>创建日期 - <em>{ moment(project.createdAt).format('YYYY年MM月DD日') }</em></li>
                </ul>
              </div>
              <form class="ui form" target="#" action="POST">
                <div class="required inline field">
                  <label for="">
                    名称
                    <i class="icon help circle" data-content="{ project && '敲击回车修改内容' }"></i>
                  </label>
                  <input type="text" name="name" placeholder="请输入名称..." autofocus value={ project && project.name } onblur={ project && doUpdate['name'] }
                  onkeypress={ project && makeBlurWhenPress('enter') }
                  >
                </div>
                <div class="required inline field">
                  <label for="">初步预算
                    <i class="icon help circle" data-content="单位: 元, { project && '敲击回车修改内容' }"></i>
                  </label>
                  <input type="number" name="budget" placeholder="请输入预算..." step=1 value={ project && project.budget } onblur={ project && doUpdate['budget'] }
                  onkeypress={ project && makeBlurWhenPress('enter') }
                  >
                </div>
                <div class="required inline field">
                  <label for="">概述
                    <i class="icon help circle" data-content="256字{ project && ', 敲击ctrl+回车修改内容' }"></i>
                  </label>
                  <textarea name="description" cols="30" rows="10" placeholder="请输入概述..." onblur={ project && doUpdate['description'] }
                    onkeypress={ project && makeBlurWhenPress('c-enter') }
                    >
                    { project && project.description }
                  </textarea>
                </div>
                <div class="inline field">
                  <label for="">项目类型</label>
                  <project-type-selector id={ project && project.projectTypeId } project-id={ project && project.id }></project-type-selector>
                </div>
                <div class="inline field">
                  <label for="">标签</label>
                  <tag-editor project-id={ project && project.id } tags="{ project && project.tags }"></tag-editor>
                </div>
                <hr>
                <a href="#" class="ui button" onclick={ back }>返回</a>
                <button class="ui green button" type="submit" if={ !project }>提交</button>
              </form>
              <control-panel if={ project } project={ project } user={ opts.ctx.user }></control-panel>
            </div>
          </div>
          <div class="ui bottom attached tab segment" data-tab="assets" show={ project }>
            <assets-repo project-id={ project.id }></assets-repo>
          </div>
        </div>
      </div>
    </div>
  </div>

  <style scoped>
    .tab[data-tab="assets"] {
      padding: 0;
    }

    input[type=file] {
      position: absolute;
      top: 0;
      right: 0;
      min-width: 100%;
      min-height: 100%;
      opacity: 0;
      display: block;
    }

    .inline.field > label {
      width: 15% !important;
    }

    .inline.field > label + * {
      width: 70% !important;
      display: inline-block;
    }

    .meta em {
      font-weight: bold;
    }

  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.back = function () {
      history.back();
      return false;
    }

    var formOpts = {
      fields: {
        name: {
          identifier: 'name',
          rules: [
            {
              type: 'empty',
              prompt: '名称不能为空'
            }
          ]
        },
        budget: {
          identifier: 'budget',
          rules: [
            {
              type: 'empty',
              prompt: '预算不能为空'
            },
            {
              type: 'integer[1..999999999999999]',
              prompt: '请输入大于0整数'
            }
          ]
        },
        description: {
          identifier: 'description',
          rules: [
            {
              type: 'empty',
              prompt: '描述不能为空'
            },
            {
              type: 'maxLength[256]',
              prompt: '最多256字'
            }
          ]
        },
      },
      inline: true,
      on: 'blur',
      keyboardShortcuts: false,
    };

    self.on('project.fetching project.saving project.updating project.publishing project.task.passing project.task.denying', function () {
      self.loading = true;
      self.update();
    }).on('project.fetched', function (project) {
      self.loading = false;
      self.project = project;
      self.update();
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
    }).on('project.updated', function (data) {
      self.loading = false;
      _.extend(self.project, data);
      self.update();
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('mount', function () {
      $(self.root).find('.menu .item').tab();
      $(self.root).find('form.form').form(formOpts).on('submit', function () {
        self.loading = true;
        self.update();
        bus.trigger('project.save', {
            name: self.name.value,
            budget: self.budget.value,
            description: self.description.value,
            projectTypeId: self.tags['project-type-selector'].val(),
            tags: self.tags['tag-editor'].val()
        });
        return false;
      });
      $(self.root).find('.help.icon').popup();
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

    self.doUpdate = {};
    ['name', 'budget', 'description'].forEach(function (field) {
      self.doUpdate[field] = function (field) {
        return function (e) {
          var d = {};
          d[field] = self[field].value;
          self.updateModel(d);
          return false;
        };
      }(field);
    });
    self.updateModel = function (data) {
      var committedValue = self.committedValue();
      for (var k in data) {
        var val = data[k];
        (val == committedValue[k]) && delete data[k]; // note! use '==' intentionally
      }
      if (!$.isEmptyObject(data)) {
        bus.trigger('project.update', self.project.id, data)
      }
    };
    self.committedValue = function () {
      return {
        name: self.project.name,
        budget: self.project.budget,
        description: self.project.description,
        project_type_id: self.project.projectTypeId,
      };
    }
    self.makeBlurWhenPress = makeBlurWhenPress;

    self.moment = moment;

  </script>
</project-app>
