var riot = require('riot');
require('MotionCAPTCHA/jquery.motionCaptcha.0.2.css');
require('MotionCAPTCHA/jquery.motionCaptcha.0.2.js');
var bus = require('riot-bus');

<login>

  <div class="ui page grid">
    <loader if={ loading }></loader>
    <div class="row">
      <div class="six wide column centered">
        <div class="ui top attached blue message">
          <h3>登录</h3>
        </div>
        <div class="ui attached segment">
          <form class="ui form" action="#" method="POST">
            <div class="ui error message">
            </div>
            <div class="required field">
              <label for="">邮箱</label>
              <input type="text" name="email">
            </div>
            <div class="required field">
              <label>密码</label>
              <input type="password" name="password">
            </div>
            <div class="ui divider"></div>
            <div id="mc" class="ui basic center aligned segment">
              <p>请移动鼠标模拟如下轨迹以登录:</p>
              <canvas id="mc-canvas"></canvas>
              <input type="hidden" id="mc-action" />
            </div>
            <div class="ui divider"></div>
            <div class="row">
              <div class="center aligned column">
                <input type="submit" value="登录" disabled="disabled" class="ui button">
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.on('mount', function () {
      $('form').form({
        fields: {
          email: {
            identifier: 'email',
            rules: [
              {
                type: 'empty',
                prompt: '请输入邮箱',
              }
            ],
          },
          password: {
            identifier: 'password',
            rules: [
              {
                type: 'empty',
                prompt: '请输入密码'
              }
            ],
          }
        },
        trigger: 'blur',
        onSuccess: function () {
          bus.trigger('login', self.email.value, self.password.value);
        }
      }).on('submit', function () {
        return false;
      });
      setTimeout(function () {
        $('form').motionCaptcha({
          errorMsg: '请重试!',
          successMsg: 'Captcha通过!',
        });
      }, 10)
    }).on('loggingIn', function () {
      self.loading = true;
      self.update();
    }).on('login.failed', function (reason) {
      self.loading = false;
      self.update();
      $(self.root).find('form').form('add errors', reason);
    }).on('login.success', function (user) {
      history.back();
    });
  </script>
</login>
