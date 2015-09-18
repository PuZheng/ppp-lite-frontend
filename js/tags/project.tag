var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
require('./project-type-selector.tag');


<project-app>

  <loader if={ loading }></loader>
  <div class="ui basic segment">
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
          <input type="text" name="name" placeholder="请输入名称..." autofocus>
        </div>
        <div class="required field">
          <label for="">初步预算(单位: 元)</label>
          <input type="number" name="budget" placeholder="请输入预算..." step=1>
        </div>
        <div class="required field">
          <label for="">概述(256字)</label>
          <textarea name="description" cols="30" rows="10" placeholder="请输入概述..."></textarea>
        </div>
        <div class="field">
          <label for="">项目类型</label>
          <project-type-selector project-types={ projectTypes }></project-type-selector>
        </div>
        <hr>
        <button class="ui green button" type="submit">提交</button>
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
    };

    self.on('projectTypeList.fetched', function (data) {
      self.projectTypes = data.data;
      self.update();
    });

    self.on('mount', function () {
      $('form.form').form(formOpts).on('submit', function () {
        self.loading = true;
        self.update();

        var data = {
            name: this.name.value,
            budget: this.budget.value,
            description: this.description.value,
            project_type_id: self.tags['project-type-selector'].val(),
        };
        $.ajax({
          url: config.backend + '/project/project-object',
          type: 'POST',
          data: JSON.stringify(data),
          contentType: 'application/json; charset=UTF-8',
          dastaType: 'json',
        }).done(function (data) {
          swal({
            type: 'success',
            title: '成功创建',
            cancelButtonText: '返回上级',
            showConfirmButton: true,
            showCancelButton: true,
            confirmButtonText: '继续编辑该项目',
          }, function (confirmed) {
            if (confirmed) {
              riot.route('project/project-object/' + data.id + '?backref=' + encodeURIComponent(self.opts.backref));
            } else {
              riot.route(self.opts.backref.replace(/^#/, ''));
            }
          });
        }).fail(function () {
          swal({
            type: 'error',
            title: '出错了',
          });
        }).always(function () {
          self.loading = false;
          self.update();
        });
        return false;
      });
    });
  </script>
</project-app>
