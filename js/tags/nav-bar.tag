var riot = require('riot');
var bus = require('riot-bus');
var page = require('page');

<nav-bar>
  <nav class="ui fixed menu inverted navbar">
    <a class="brand item" href="/">PPP-LITE</a>
    <div class="ui dropdown item" if={ opts.ctx.user && opts.ctx.user.role.name === '业主' }>
      <i class="dropdown icon"></i>
      项目管理
      <div class="menu">
        <a class="item { opts.ctx.pathname === '/project/unpublished-list' && 'active' }" href="/project/unpublished-list">未发布项目</a>
        <a class="item { opts.ctx.pathname === '/project/progressing-list' && 'active' }" href="/project/progressing-list">进行中项目</a>
      </div>
    </div>
    <a class="ui item { opts.ctx.pathname === '/project/progressing-list' && 'active' }" if={ opts.ctx.user && opts.ctx.user.role.name === 'PPP中心' } href="/project/progressing-list">
      项目管理
    </a>
    <a class="ui item { opts.ctx.pathname === '/todo/list' && 'active' }" href="/todo/list">
      待办事项
      <span class="ui circular label" if={ todoCount }>{ todoCount }</span>
    </a>
    <div class="right menu" if={ opts.ctx.user }>
      <div class="ui dropdown item">
        <div class="fitted item">
          <i class="icon user"></i>
          <span class="ui teal tiny header">
            { opts.ctx.user.name || opts.ctx.user.email }
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
    self.mixin(bus.Mixin);

    self.on('mount', function () {
      $(self.root).find('.ui.dropdown').dropdown({
        transition: 'drop'
      });
    }).on('user.updated', function (user) {
      _.assign(self.opts.ctx.user, user);
      self.update();
    }).on('todos.fetched', function (data) {
      self.todoCount = data.data.length;
      self.update();
    }).on('todo.updated', function (todo) {
      if (todo.completed) {
        --self.todoCount;
        self.update();
      }
    });

    self.logout = function () {
      bus.trigger('logout');
    }
  </script>
</nav-bar>
