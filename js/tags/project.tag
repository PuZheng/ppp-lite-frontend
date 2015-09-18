var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var swal = require('sweetalert/sweetalert.min.js');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
require('sweetalert/sweetalert.css');
require('./project-type-selector.tag');


<project-app>

  <div class="ui basic segment">
    <loader if={ loading }></loader>
    <div class="ui top attached green message">
      <span if={ project }>编辑</span>
      <span if={ !project }>创建</span>
      <span>PPP项目</span>
      <div class="ui red label" if={ project }>{ project.name }</div>
    </div>
    <div class="ui attached segment">
      <form class="ui form" target="#" action="POST">
        <div class="required field">
          <label for="">名称</label>
          <input type="text" name="name" placeholder="请输入名称..." autofocus value={ project && project.name } onblur={ project && doUpdate['name'] }
          onkeypress={ project && makeMeBlurWhen('enter') }
          >
        </div>
        <div class="required field">
          <label for="">初步预算(单位: 元)</label>
          <input type="number" name="budget" placeholder="请输入预算..." step=1 value={ project && project.budget } onblur={ project && doUpdate['budget'] }
          onkeypress={ project && makeMeBlurWhen('enter') }
          >
        </div>
        <div class="required field">
          <label for="">概述(256字)</label>
          <textarea name="description" cols="30" rows="10" placeholder="请输入概述..." onblur={ project && doUpdate['description'] }
            onkeypress={ project && makeMeBlurWhen('c-enter') }
            >
            { project && project.description }
          </textarea>
        </div>
        <div class="field">
          <label for="">项目类型</label>
          <project-type-selector id={ project && project.projectTypeId } project-id={ project && project.id }></project-type-selector>
        </div>
        <hr>
        <button class="ui green button" type="submit" if={ !project }>提交</button>
        <a href="{ opts.backref }" class="ui button">返回</a>
      </form>
    </div>
  </div>

  <script>
    var self = this;
    self.mixin(bus.Mixin);

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

    self.on('project.fetching project.saving project.updating', function () {
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
          riot.route('project/project-object/' + self.project.id + '?backref=' + encodeURIComponent(self.opts.backref));
        } else {
          riot.route(self.opts.backref.replace(/^#/, ''));
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
      $('form.form').form(formOpts).on('submit', function () {
        self.loading = true;
        self.update();
        bus.trigger('project.save', {
            name: self.name.value,
            budget: self.budget.value,
            description: self.description.value,
            projectTypeId: self.tags['project-type-selector'].val(),
        });
        return false;
      });
    });
    self.doUpdate = {};
    ['name', 'budget', 'description'].forEach(function (field) {
      self.doUpdate[field] = function (field) {
        return function (e) {
          var d = {};
          d[field] = self[field].value;
          self.updateModel(d);
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
    self.makeMeBlurWhen = function (test) {
      var test = {
        'enter': function (e) {
          return e.which === 13;
        },
        'c-enter': function (e) {
          return (e.which === 13 || e.which === 10) && e.ctrlKey;
        }
      }[test];
      return function (e) {
        if (test(e)) {
          $(e.target).blur();
          return false;
        }
        return true;
      }
    };
  </script>
</project-app>
