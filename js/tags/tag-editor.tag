var riot = require('riot');
var bus = require('riot-bus');

<tag-editor>
  <div class="basic ui segment">
    <loader if={ loading }></loader>
    <div class="ui fluid multiple search selection dropdown">
      <input type="hidden" name="tags" value={ tags? _.pluck(tagList, 'id').join(','): '' }>
      <i class="dropdown icon"></i>
      <div class="default text">选择标签</div>
      <div class="menu">
        <div class="item" each={ allTags } data-value="{ id }">{ value }</div>

      </div>
    </div>
  </div>

  <script>
    var self = this;
    self._ = _;
    self.tagList = [];
    self.mixin(bus.Mixin);

    self.on('update', function () {
      if (opts.tags) {
        self.tagList = opts.tags || [];
        self.update();
      }
    }).on('tagList.fetching, tag.saving', function () {
      self.loading = true;
      self.update();
    }).on('tagList.fetched', function (tags) {
      self.loading = false;
      self.allTags = tags;
      self.update();
      $(self.root).find('.ui.dropdown').dropdown({
        allowAdditions: true,
        onAdd: function (addedValue, addedText, $addedChoice) {
          if ($addedChoice.hasClass('addition')) {
            bus.trigger('tag.save', {
              value: addedValue,
            }, function (tag) {
              $addedChoice.data('value', tag.id);
            });
          } else {
            self.tagList.push({
              id: addedValue,
              value: addedText,
            });
            self.opts['project-id'] && bus.trigger('project.update', self.opts['project-id'], {
              'tags': [
                {
                  op: 'add',
                  id: addedValue,
                }
              ]
            });
          }
        },
        onRemove: function (removedValue, removedText, $removedChoice) {
          var tagId = $removedChoice.data('value') || removedValue;
          _(self.tagList).remove(function (tag) {
            return tag.id === tagId;
          });
          self.opts['project-id'] && bus.trigger('project.update', self.opts['project-id'], {
            'tags': [
              {
                op: 'delete',
                id: removedValue,
              }
            ]
          });
        },
      });
    }).on('tag.saved', function (tag) {
      self.loading = false;
      self.update();
      self.tagList.push(tag);
      self.opts['project-id'] && bus.trigger('project.update', self.opts['project-id'], {
        'tags': [
          {
            op: 'add',
            id: tag.id,
          }
        ]
      });
    });

    self.val = function () {
      return _.pluck(self.tagList, 'id');
    }
  </script>

</tag-editor>
