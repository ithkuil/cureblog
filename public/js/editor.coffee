editor = undefined
editorhtml = undefined
editorbrowser = undefined
editornodejs = undefined
editorcss = undefined
window.saveFilters = []

nowediting = ''
  
initialized = false

thing = () ->

editWidget = (widget) ->
  $('#widgetname').data 'mode', 'update'
  $('#widgetname').val widget.name
  nowediting = widget.name
  window.createCookie 'lastScreen', widget.name
  $('.demo').dialog 'option', 'title', widget.name
  editorbrowser.setValue widget.browser
  editornodejs.setValue widget.nodejs
  editorhtml.setValue widget.html
  editorcss.setValue widget.css
  $('#stylelist').text widget.styles
  $('#scriptlist').text widget.scripts
  $('#package').text widget.pckg

initeditortabs =  ->
  if initialized then return
  initialized = true
  editorhtml = CodeMirror.fromTextArea $("#html")[0],
    mode: "text/html"
    lineNumbers: true
  editorbrowser = CodeMirror.fromTextArea $("#browser")[0],
    mode: "coffeescript"
    lineNumbers: true
  editornodejs = CodeMirror.fromTextArea $("#nodejs")[0],
    mode: "coffeescript"
    lineNumbers: true
  editorcss = CodeMirror.fromTextArea $("#css")[0],
    mode: "text/css"
    lineNumbers: true
  lastScreen = window.readCookie 'lastScreen'
  if lastScreen?
    now.getWidgetData lastScreen, (widgetdata, err) ->
      if err?
        alert 'Error loading widget data: ' + err.message
      else
        editWidget widgetdata

  
makeEditable = ->
  $.contextMenu
    selector: '.compmenu'
    trigger: 'hover'
    autoHide: false
    callback: (key, options, e) ->
      el = window.lastMenuEvent.currentTarget
      name = $(el).parent().find('.compname').text()
      
      switch key
        when 'delete'
          if window.confirm "Delete #{name}? (Can't be undone!)"
            now.deleteComponent name, (success, err) ->
              if err?
                alert 'Failed: ' + err.message
              else
                $('.demo').html 'Component was deleted.  Reloading application..'
                window.delay 2000, -> window.location.reload()
                now.restartServer()
          
          else
            console.log "Not deleting"
          
        when 'copy'
          now.copyComponent name, (success, err) ->
            if not err?
              $('.demo').html "#{name} copied successfully. Reloading application."
              window.delay 2000, -> window.location.reload()
            else
              alert 'Error copying component: ' + err.message
            
        when 'edit'
          now.getWidgetData name, (widgetdata, err) ->
            if err?
              alert 'Error loading widget data: ' + err.message
            else
              editWidget widgetdata
              
        when 'rename'
        	$(el).parent().find('.compname').attr('contenteditable', true).focus().select().blur ->
              now.renameComponent name, $(el).parent().find('.compname').text()

      true

    items:
      "edit": {name: "Edit Code", icon: "edit"}
      "rename": {name: "Rename", icon: "edit"}
      "copy": {name: "Make a Copy", icon: "copy"}
      "delete": {name: "Delete", icon: "delete"}
      
window.savePage = ->
  if window.alreadyEditing
    noty
      text: "Can't save while editing"
      type: 'alert'
    return

  unfiltered = $('#page').html()

  $('body').append('<div id="tofilter"></div>')
  $('#tofilter').html(unfiltered).hide()
        
  for filter in window.saveFilters
    filter '#tofilter'

  window.delay 500, ->
    now.savePage $('#tofilter').html(), (success) ->
      if success
        noty
          text: 'Page saved.'
          type: 'success'
          timeout: 1000
  
          
loadwidgets = ->
  $('#page').droppable
    drop: (ev, ui) ->
      name = ui.draggable.data 'name'
      $('#page').trigger 'drop', [ev, ui, @]

  now.listComponents (components) ->
    str = ''
    for component in components
      checked = ''
      if component.active then checked = 'checked="checked"'
      check = '<input type="checkbox" ' + checked + '/>'
      str += "<li>#{check}&nbsp;<span class=\"compname\">#{component.name}</span><span class=\"compmenu\">▼</span></li>"
    $('#components').html str
    $('.compname').click ->
      $('#gitrepo').val ''
      
      now.getWidgetData $(@).text(), (widgetdata, err) ->
        if err?
          alert 'Error loading widget data: ' + err.message
        else
          editWidget widgetdata
  
  makeEditable()


publish = ->
  $('.pubmsg').html 'Publishing..'
  user= $('#gituser').val()
  repo = $('#gitrepo').val()
  name = nowediting
  if not (user? and repo? and name?)
    alert 'Please fill in all of the publish fields'
  else
    now.publishComponent name, user, repo, (res) ->
      console.log res
      if res?
        if res.message?
          $('.pubmsg').html res.message
        else
          $('.pubmsg').html 'Success!'

logmsgcnt = 0          
          
loghandle = (text) ->
  if not debugWinVis
    $('#debugloghandle').css 'right', '0px'  
  $('#debugloghandle').html text

          
debugWinVis = false
          
debugWin = ->          
  $('#debugloghandle').click ->
    
    if not debugWinVis
      $('#debugloghandle').animate {right: '+450'}
      $('#debuglog').animate {width: '+450'}, 70, ->
        pre = $("#debuglog")
        pre.scrollTop pre.prop("scrollHeight")    
      logmsgcnt = 0
      loghandle 'log'
      debugWinVis = true
    else
      $('#debugloghandle').animate {right: '-450'}, ->
        loghandle 'log'
      $('#debuglog').animate {width: '-450'}, 70
      debugWinVis = false


writelog = (s) ->
  if typeof s is 'object'
    s = JSON.stringify s 
  lines = s.split "\n"
  n = lines.length
  logmsgcnt += Math.floor n/2
  if logmsgcnt is 0 then logmsgcnt = 1
  if not debugWinVis
    loghandle "log (#{logmsgcnt})"
  else
    loghandle 'log'    
  if s.lastIndexOf("\n") isnt s.length-1 then s+= "\n"
  $('#logmsgs').append s
  pre = $("#debuglog");
  pre.scrollTop pre.prop("scrollHeight")   
    

#window.console.log = (s) ->
#  writelog s

  
      
$ ->
  $('#advtoggle').on 'change', ->    
    if $('#advtoggle').is(':checked')
      $('#advanced').show()
    else
      $('#advanced').hide()
    
  $('body').prepend '<div id="debugloghandle">log</div>'
  $('#debugloghandle').show()
  $('#editorui').hide()
  $('body').prepend $('#editorui')
  $('#objs').height $(window).height()

  $('#advobjs').prepend '<button id="editcode" title="Code editor" class="button white"><img src="/images/codegray.png"/></button>'
  $('#objs').prepend '<button id="savepage" title="Save page" class="button white smallbtn"><img src="images/save2.png"/></button><br/>'

  $('#tabs').tabs
    show: (event, ui) ->
      if editorhtml? then editorhtml.refresh()
      if editorbrowser? then editorbrowser.refresh()
      if editorcss? then editorcss.refresh()
      if editornodejs? then editornodejs.refresh()

  $('#savewidget').click ->
    data =
      name: $('#widgetname').val()
      browser: editorbrowser.getValue()
      html: editorhtml.getValue()
      css:  editorcss.getValue()
      nodejs:  editornodejs.getValue()
      styles: $('#stylelist').val()
      scripts: $('#scriptlist').val()
      pckg: $('#package').val()

    now.saveWidgetData data, (compileout) ->
      if compileout? and compileout.length > 8
        alert compileout
        return
      else
        $('.demo').html 'Your edits have been saved.  Reloading application..'
        now.restartServer()
        setTimeout ( -> window.location.reload() ), 3000

    active = []
    $('#components li').each ->
      if $(@).find('input').is(':checked')
        active.push $(@).find('.compname').text()
    now.setActiveComponents active

  $('#editcode').click ->
    $('.demo').dialog
      closeOnEscape: false
      title: name + ' component - Code Editor'
      position: 'top'
      height: $(window).height() * .93
      width: $(window).width() * .9
    
    window.delay 150, ->
      $(".ui-tabs-panel").height $(window).height() * .7
      $(".CodeMirror").height $(window).height() * .69
      $('#components').height $(window).height() * .62
      window.delay 150, ->
        $(".CodeMirror-scroll").height $(window).height() * .68
        $('.transparent').css 'backgroundColor', '#f2f2f2'
        
    initeditortabs()

  $('#publish').click publish
  
  debugWin()
  
  $('#savepage').click ->
    window.savePage()

  $(document).bind 'nowInit', ->
    loadwidgets()
    
  now.consolelog = (msg) ->
    if typeof(msg) is 'object'
      writelog '[server]:'
      writelog msg
    else
      writelog '[server]: ' + msg
      
