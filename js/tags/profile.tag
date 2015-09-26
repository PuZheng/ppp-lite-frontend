var riot = require('riot');

<profile>
  <div class="ui page grid">
    <div class="row">
      <div class="column">
      <div class="ui basic segment">
        <div class="ui top attached blue message">用户信息</div>
        <div class="ui attached segment">
          <form class="ui form" action="">
            <div class="ui inline field">
              <label for="">用户邮箱</label>
              <input type="text" name="email" value={ opts.ctx.user.email } disabled>
            </div>
            <div class="ui inline field">
              <label for="">用户角色</label>
              <input type="text" name="role" value={ opts.ctx.user.role.name }  disabled/>
            </div>
            <div class="ui inline field" if={ opts.ctx.user.department }>
              <label for="">所属部门</label>
              <input type="text" name="department" value={ opts.ctx.user.department.name } disabled/>
            </div>
            <hr>
            <button class="ui button" onclick={ back }>返回</button>
          </form>
        </div>
      </div>
      </div>
    </div>
  </div>
  <script>
    console.log(opts.ctx.user);
    self.back = function () {
      history.back();
    }
  </script>
</profile>
