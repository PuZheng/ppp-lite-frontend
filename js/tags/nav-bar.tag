var riot = require('riot');
var bus = require('riot-bus');
var page = require('page');

<nav-bar>
  <nav class="ui fixed menu inverted navbar">
    <a class="brand item" href="/">PPP-LITE</a>
    <div class="ui dropdown item" if={ opts.ctx.user }>
      <i class="dropdown icon"></i>
      项目管理
      <div class="menu">
        <a class="item { opts.ctx.pathname === '/project/list' && 'active' }" href="/project/list">未发布项目</a>
      </div>
    </div>
    <div class="right menu" if={ opts.ctx.user }>
      <div class="ui dropdown item">
        <div class="fitted item">
          <i class="icon user"></i>
          <span class="ui teal tiny header">
            { opts.ctx.user.email }
          </span>
        </div>
        <i class="dropdown icon"></i>
        <div class="menu">
          <a class="item" href="profile">
            <i class="icon edit"></i>
            用户信息
          </a>
          <a class="item" href="#" onclick={ logout }>
            <i class="icon sign out"></i>
            退出
          </a>
        </div>
      </div>
    </div>
  </nav>
  <style scoped>

    .ui.header {
      margin-top: 0;
    }
  </style>

  <script>
    var self = this;

    self.on('mount', function () {
      $(self.root).find('.ui.dropdown').dropdown({
        transition: 'drop'
      });
    });

    self.logout = function () {
      bus.trigger('logout');
    }
  </script>
</nav-bar>
