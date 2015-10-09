var riot = require('riot');
var page = require('page');
var bus = require('riot-bus');
require('./loader.tag');
var makeBlurWhenPress = require('make-blur-when-press');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');

<profile>
  <div class="ui page grid">
    <div class="row">
      <div class="column">
      <div class="ui basic segment">
        <loader if={ loading }></loader>
        <div class="ui top attached blue message">用户信息</div>
        <div class="ui attached segment">
          <form class="ui form" action="">
            <div class="inline field">
              <label for="用户名">用户名(敲击回车修改)</label>
              <input type="text" name="name" value={ opts.ctx.user.name }  autofocus placeholder="请输入用户名..." onblur={ updateName }
              onkeypress={ makeBlurWhenPress('enter') }
              >
            </div>
            <div class="inline field">
              <label for="">用户邮箱</label>
              <input type="text" name="email" value={ opts.ctx.user.email } disabled>
            </div>
            <div class="inline field">
              <label for="">用户角色</label>
              <input type="text" name="role" value={ opts.ctx.user.role.name }  disabled/>
            </div>
            <div class="inline field" if={ opts.ctx.user.department }>
              <label for="">所属部门</label>
              <input type="text" name="department" value={ opts.ctx.user.department.name } disabled/>
            </div>
            <hr>
            <button class="ui button" onclick={ back }>返回首页</button>
          </form>
        </div>
      </div>
      </div>
    </div>
  </div>
  <style scoped>
    .ui.form .inline.field > label {
      width: 10rem;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.back = function () {
      page('/');
    };
    self.updateName = function (e) {
      if (self.name.value != opts.ctx.user.name) {
        bus.trigger('user.update', opts.ctx.user.id, {
          name: self.name.value
        });
      }
    };
    self.on('mount', function () {
      opts.ctx.user.name = opts.ctx.user.name || ''; // convert null to ''
    }).on('user.updating', function () {
      self.loading = true;
      self.update();
    }).on('user.updated', function (user) {
      opts.ctx.user.name = user.name;
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('user.update.end', function () {
      self.loading = false;
      self.update();
    });
    self.makeBlurWhenPress = makeBlurWhenPress;
  </script>
</profile>
