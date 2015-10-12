var riot = require('riot');
require('./project-type-selector.tag');
require('./tag-editor.tag');
require('./control-panel.tag');
require('./project-status.tag');
var principal = require('principal');
var makeBlurWhenPress = require('make-blur-when-press');
var moment = require('moment');
var bus = require('riot-bus');

<project-primary>
  <div class="ui basic segment">
    <div class="ui meta teal message" if={ opts.project }>
      <ul class="list">
        <li><project-status if={ opts.project.workflow } workflow={ opts.project.workflow }></project-status></li>
        <li>创建人 - <em>{ opts.project.owner.name || opts.project.owner.email }</em></li>
        <li>部门 - <em>{ opts.project.department.name }</em></li>
        <li>创建日期 - <em>{ moment(opts.project.createdAt).format('YYYY年MM月DD日') }</em></li>
      </ul>
    </div>
    <form class="ui form" target="#" action="POST">
      <div class="required inline field">
        <label for="">
          名称
          <i class="icon help circle" data-content="{ opts.project && '敲击回车修改内容' }"></i>
        </label>
        <input type="text" name="name" placeholder="请输入名称..." autofocus value={ opts.project && opts.project.name } onblur={ opts.project && doUpdate['name'] }
        onkeypress={ opts.project && makeBlurWhenPress('enter') }
        disabled={ uneditable }
        >
      </div>
      <div class="required inline field">
        <label for="">初步预算
          <i class="icon help circle" data-content="单位: 元, { opts.project && '敲击回车修改内容' }"></i>
        </label>
        <input type="number" name="budget" placeholder="请输入预算..." step=1 value={ opts.project && opts.project.budget } onblur={ opts.project && doUpdate['budget'] }
        onkeypress={ opts.project && makeBlurWhenPress('enter') }
        disabled={ uneditable }
        >
      </div>
      <div class="required inline field">
        <label for="">概述
          <i class="icon help circle" data-content="256字{ opts.project && ', 敲击ctrl+回车修改内容' }"></i>
        </label>
        <textarea name="description" cols="30" rows="10" placeholder="请输入概述..." onblur={ opts.project && doUpdate['description'] }
          onkeypress={ opts.project && makeBlurWhenPress('c-enter') }
          disabled={ uneditable }
          >
          { opts.project && opts.project.description }
        </textarea>
      </div>
      <div class="inline field">
        <label for="">项目类型</label>
        <project-type-selector project={ opts.project } disabled={ uneditable }></project-type-selector>
      </div>
      <div class="inline field">
        <label for="">标签</label>
        <tag-editor project-id={ opts.project && opts.project.id } tags="{ opts.project && opts.project.tags }" disabled={ uneditable }></tag-editor>
      </div>
      <hr>
      <a href="#" class="ui button" onclick={ back }>返回</a>
      <button class="ui green button" type="submit" if={ !opts.project }>提交</button>
    </form>
    <control-panel if={ opts.project } project={ opts.project } ctx={ opts.ctx } disabled={ uneditable }></control-panel>
  </div>
  <style scope>
    .basic.main.segment {
      min-height: 32rem;
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
    self.on('mount', function () {
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
    }).on('update', function () {
      if (self.opts.project) {
        principal.permit('project.edit', self.opts.project).done(function () {
        }).fail(function (need) {
          self.uneditable = true;
          self.update();
        });
      }
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
        bus.trigger('project.update', self.opts.project.id, data)
      }
    };
    self.committedValue = function () {
      return {
        name: self.opts.project.name,
        budget: self.opts.project.budget,
        description: self.opts.project.description,
        project_type_id: self.opts.project.projectTypeId,
      };
    }
    self.makeBlurWhenPress = makeBlurWhenPress;

    self.moment = moment;
  </script>
</project-primary>
