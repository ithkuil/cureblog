S4 = ->  (((1+Math.random())*0x10000)|0).toString(16).substring(1)

window.nowAlready = false

window.delay = (ms, func) ->
  setTimeout func, ms

window.guid = -> S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4()

window.createCookie = (name, value, days) ->
  if days
    date = new Date()
    date.setTime date.getTime() + (days * 24 * 60 * 60 * 1000)
    expires = "; expires=" + date.toGMTString()
  else
    expires = ""
  document.cookie = name + "=" + value + expires + "; path=/"
  
window.readCookie = (name) ->
  nameEQ = name + "="
  ca = document.cookie.split(";")
  i = 0

  while i < ca.length
    c = ca[i]
    c = c.substring(1, c.length)  while c.charAt(0) is " "
    return c.substring(nameEQ.length, c.length)  if c.indexOf(nameEQ) is 0
    i++
  null
  
window.eraseCookie = (name) ->
  createCookie name, "", -1

$ ->
  $(document).bind 'nowInit', ->
    sessionid = window.readCookie 'myid'
    console.log 'sessionid is ' + sessionid
    if not sessionid?
      window.loggedIn = false
      console.log "Logged in is " + window.loggedIn
      $(document).trigger 'sessionState', undefined
    else
      now.getAccountInfo sessionid, (user) ->
        if not user?
          window.loggedIn = false
          console.log "Logged in is " + window.loggedIn
          $(document).trigger 'sessionState', undefined
        else
          window.loggedIn = true
          window.user = user
          console.log "Logged in is " + window.loggedIn
          console.log "user is " + window.user
          $('#editorui').show()
          $(document).trigger 'sessionState', window.user


now.ready ->
  if not window.nowAlready
    window.nowAlready = true
    $(document).trigger 'nowInit'      

  