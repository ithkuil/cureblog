(function() {
  var editWidget, editor, editorbrowser, editorcss, editorhtml, editornodejs, initeditortabs, initialized, loadwidgets, makeEditable, thing;

  editor = void 0;

  editorhtml = void 0;

  editorbrowser = void 0;

  editornodejs = void 0;

  editorcss = void 0;

  initialized = false;

  thing = function() {};

  editWidget = function(widget) {
    $('#widgetname').data('mode', 'update');
    $('#widgetname').val(widget.name);
    window.createCookie('lastScreen', widget.name);
    $('.demo').dialog('option', 'title', widget.name);
    editorbrowser.setValue(widget.browser);
    editornodejs.setValue(widget.nodejs);
    editorhtml.setValue(widget.html);
    return editorcss.setValue(widget.css);
  };

  initeditortabs = function() {
    var lastScreen;
    if (initialized) return;
    initialized = true;
    editorhtml = CodeMirror.fromTextArea($("#html")[0], {
      mode: "text/html",
      lineNumbers: true
    });
    editorbrowser = CodeMirror.fromTextArea($("#browser")[0], {
      mode: "coffeescript",
      lineNumbers: true
    });
    editornodejs = CodeMirror.fromTextArea($("#nodejs")[0], {
      mode: "coffeescript",
      lineNumbers: true
    });
    editorcss = CodeMirror.fromTextArea($("#css")[0], {
      mode: "text/css",
      lineNumbers: true
    });
    lastScreen = window.readCookie('lastScreen');
    if (lastScreen != null) {
      return now.getWidgetData(lastScreen, function(widgetdata, err) {
        if (err != null) {
          return alert('Error loading widget data: ' + err.message);
        } else {
          return editWidget(widgetdata);
        }
      });
    }
  };

  makeEditable = function() {
    return $.contextMenu({
      selector: '.compmenu',
      trigger: 'hover',
      autoHide: false,
      callback: function(key, options, e) {
        var el, name;
        el = window.lastMenuEvent.currentTarget;
        name = $(el).parent().find('.compname').text();
        switch (key) {
          case 'delete':
            if (window.confirm("Delete " + name + "? (Can't be undone!)")) {
              now.deleteComponent(name, function(success, err) {
                if (err != null) {
                  return alert('Failed: ' + err.message);
                } else {
                  $('.demo').html('Component was deleted.  Reloading application..');
                  window.delay(2000, function() {
                    return window.location.reload();
                  });
                  return now.restartServer();
                }
              });
            } else {
              console.log("Not deleting");
            }
            break;
          case 'copy':
            now.copyComponent(name, function(success, err) {
              if (!(err != null)) {
                $('.demo').html("" + name + " copied successfully. Reloading application.");
                return window.delay(2000, function() {
                  return window.location.reload();
                });
              } else {
                return alert('Error copying component: ' + err.message);
              }
            });
            break;
          case 'edit':
            now.getWidgetData(name, function(widgetdata, err) {
              if (err != null) {
                return alert('Error loading widget data: ' + err.message);
              } else {
                return editWidget(widgetdata);
              }
            });
        }
        return true;
      },
      items: {
        "edit": {
          name: "Edit Code",
          icon: "edit"
        },
        "copy": {
          name: "Make a Copy",
          icon: "copy"
        },
        "delete": {
          name: "Delete",
          icon: "delete"
        }
      }
    });
  };

  window.savePage = function() {
    console.log('saving html: ' + $('#page').html());
    return now.saveStatic('page', $('#page').html());
  };

  loadwidgets = function() {
    $('#page').droppable({
      drop: function(ev, ui) {
        var name;
        name = ui.draggable.data('name');
        return $('#page').trigger('drop', [ev, ui, this]);
      }
    });
    now.listComponents(function(components) {
      var component, str, _i, _len;
      str = '';
      for (_i = 0, _len = components.length; _i < _len; _i++) {
        component = components[_i];
        str += "<li><span class=\"compname\">" + component + "</span><span class=\"compmenu\">▼</span></li>";
      }
      $('#components').html(str);
      return $('.compname').click(function() {
        return now.getWidgetData($(this).text(), function(widgetdata, err) {
          if (err != null) {
            return alert('Error loading widget data: ' + err.message);
          } else {
            return editWidget(widgetdata);
          }
        });
      });
    });
    return makeEditable();
  };

  $(function() {
    $('body').prepend($('#editorui'));
    $('#objs').height($(window).height());
    $('#tabs').tabs({
      show: function(event, ui) {
        if (editorhtml != null) editorhtml.refresh();
        if (editorbrowser != null) editorbrowser.refresh();
        if (editorcss != null) editorcss.refresh();
        if (editornodejs != null) return editornodejs.refresh();
      }
    });
    $('#savewidget').click(function() {
      var data;
      data = {
        name: $('#widgetname').val(),
        browser: editorbrowser.getValue(),
        html: editorhtml.getValue(),
        css: editorcss.getValue(),
        nodejs: editornodejs.getValue()
      };
      now.saveWidgetData(data, function() {
        $('.demo').html('Your edits have been saved.  Reloading application..');
        return setTimeout((function() {
          return window.location.reload();
        }), 2000);
      });
      return now.restartServer();
    });
    return now.ready(function() {
      var btn;
      loadwidgets();
      btn = $('#objs').prepend('<button class="button white">Code Editor</button>');
      return btn.click(function() {
        $('.demo').dialog({
          title: name + ' component - Code Editor',
          position: 'top',
          height: $(window).height() * .9,
          width: $(window).width() * .7
        });
        window.delay(500, function() {
          $(".ui-tabs-panel").height($(window).height() * .7);
          $(".CodeMirror").height($(window).height() * .65);
          return window.delay(500, function() {
            return $(".CodeMirror-scroll").height($(window).height() * .7);
          });
        });
        return initeditortabs();
      });
    });
  });

}).call(this);
