var riot = require('riot');
require('MotionCAPTCHA/jquery.motionCaptcha.0.2.css');
require('MotionCAPTCHA/jquery.motionCaptcha.0.2.js');
<login>

  <div class="ui page grid">
    <div class="row">
      <div class="six wide column centered">
        <div class="ui top attached blue message">
          <h3>登录</h3>
        </div>
        <div class="ui attached segment">
          <form class="ui form" action="#" method="POST">
            <div class="ui negative message" if={ error }>
              <div class="header" each={ error }>
                { reason }
              </div>
            </div>
            <div class="required field">
              <label for="inputUserName">用户名</label>
              <input id="inputUserName" type="text" name="username">
            </div>
            <div class="required field">
              <label for="inputPasswd">密码</label>
              <input type="password" name="password" id="inputPasswd">
            </div>
            <input type="hidden" id="mc-action" value="{{ url_for('auth.login_view') }}" />
            <div class="ui divider"></div>
            <div id="mc">
              <p>请移动鼠标模拟如下轨迹以登录:</p>
              <div class="row">
                <div class="center aligned column">
                  <canvas id="mc-canvas"></canvas>
                </div>
              </div>
            </div>
            <div class="ui divider"></div>
            <div class="row">
              <div class="center aligned column">
                <input type="submit" value="登录" disabled="disabled" class="ui button" onclick={ loginHandler }>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
  <script>
    var self = this;
    self.on('mount', function () {
      $('form').motionCaptcha({
        errorMsg: '请重试!',
        successMsg: 'Captcha通过!',
      });
      $('form').form({
        // validate fields
      });
    });

    self.loginHandler = function () {
      // login,
      // set user
      // and route to backref
    }
  </script>
</login>
