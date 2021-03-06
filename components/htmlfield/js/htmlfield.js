(function() {
  var HtmlFieldTool, HtmlFieldWidget,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  HtmlFieldWidget = (function() {

    function HtmlFieldWidget(parent, position, exists, widget) {
      this.blank = __bind(this.blank, this);
      var htmlfieldhtml,
        _this = this;
      if (!exists) {
        htmlfieldhtml = $('#htmlfieldwidgettemplate').html();
        this.htmlfield = $(htmlfieldhtml);
        this.htmlfield.css('position', 'absolute');
        this.htmlfield.css('top', position.top + 'px');
        this.htmlfield.css('left', position.left + 'px');
        parent.append(this.htmlfield);
      } else {
        this.htmlfield = widget;
      }
      try {
        this.htmlfield.resizable();
        this.htmlfield.draggable();
      } catch (e) {

      }
      this.obj = this.htmlfield;
      this.htmlfield.data('widget', this);
      this.htmlfield[0].widget = this;
      this.htmlfield.widget = this;
      if (window.loggedIn) {
        this.htmlfield.find('.rename').off('click');
        this.htmlfield.find('.rename').on('click', function() {
          var name;
          name = prompt('Enter field name');
          _this.htmlfield.attr('data-fieldname', name);
          return _this.showname();
        });
        this.showname();
      } else {
        this.displaymode();
      }
      console.log('htmlfield constructor done');
    }

    HtmlFieldWidget.prototype.blank = function() {
      return 'New';
    };

    HtmlFieldWidget.prototype.showname = function() {
      return this.obj.find('.fieldname').html(this.obj.attr('data-fieldname'));
    };

    HtmlFieldWidget.prototype.designmode = function(record) {
      this.htmlfield.find('.htmleditarea').html('Rich Text Field');
      return this.htmlfield.find('.htmleditarea').editable('disable');
    };

    HtmlFieldWidget.prototype.display = function(record) {
      var name;
      name = this.obj.attr('data-fieldname');
      return this.htmlfield.find('.htmleditarea').html(record[name]);
    };

    HtmlFieldWidget.prototype.displaymode = function() {
      this.htmlfield.find('.rename,.fieldname').hide();
      return this.htmlfield.css('border', 'none');
    };

    HtmlFieldWidget.prototype.edit = function(record) {
      var name, oFCKeditor;
      name = this.obj.attr('data-fieldname');
      this.htmlfield.find('.htmleditarea').html(record[name]);
      oFCKeditor = new FCKeditor('editor1');
      oFCKeditor.ToolbarSet = 'Simple';
      oFCKeditor.BasePath = "/js/";
      return this.htmlfield.find('.htmleditarea').editable({
        type: 'wysiwyg',
        editor: oFCKeditor,
        submit: 'save',
        cancel: 'cancel',
        onEdit: function(content) {
          return window.alreadyEditing = true;
        },
        onSubmit: function(content) {
          record[name] = content.current;
          return window.alreadyEditing = false;
        },
        onCancel: function(content) {
          return window.alreadyEditing = false;
        }
      });
    };

    return HtmlFieldWidget;

  })();

  HtmlFieldTool = (function() {

    function HtmlFieldTool() {
      var btn, data, widget, widgethtml;
      widgethtml = $('#htmlfieldtemplate').html();
      widget = $(widgethtml);
      btn = widget.find('.designwidget');
      btn.data('name', 'htmlfieldcollector');
      data = {
        name: 'htmlfieldcollector'
      };
      btn.data('widget', data);
      $('#advobjlist').append(widget);
      widget.draggable({
        helper: 'clone',
        stop: function(ev, ui) {
          var p;
          p = {};
          if (ev.offsetX != null) {
            p.left = ev.offsetX;
            p.top = ev.offsetY;
          } else {
            p.left = ev.pageX - $(ev.target).offsetLeft;
            p.top = ev.pageY - $(ev.target).offsetTop;
          }
          return new HtmlFieldWidget($('.activewidget'), p, false);
        }
      });
    }

    return HtmlFieldTool;

  })();

  $(function() {
    return $(document).bind('sessionState', function(user) {
      if (window.loggedIn) window.HtmlFieldTool = new HtmlFieldTool();
      return $('.htmlfieldall').each(function() {
        var text, x, y;
        if ($(this) != null) {
          x = $(this).position().left;
          y = $(this).position().top;
          return text = new HtmlFieldWidget($(this).parent(), $(this).position(), true, $(this));
        }
      });
    });
  });

}).call(this);
