fs = require 'fs'
util = require 'util'
path = require 'path'
proc = require 'child_process'
sh = require 'shelljs'

console.log "Hello from thing"

getorder = (fname) -> 
  loadstr = fs.readFileSync fname, 'utf8' 
  loadstr.split '\n' 
 
head = ''

trim = (string) ->
  string.replace /^\s*|\s*$/g, ''

listfile = (fname) ->
  str = fs.readFileSync fname, 'utf8'
  console.log "Loaded #{str}"
  list = str.split '\n'
  (trim item for item in list when item? and trim(item).length>0)
  
readstyles = (name) ->
  try
    list = listfile "components/#{name}/styles"
    str = ''
    for fname in list
      str += '<link type="text/css" href="css/' + fname + '"/>\n'
    
    if path.existsSync "components/#{name}/css" 
      console.log "Copying files from components/#{name}/css to public/css" 
      sh.cp '-Rf', "components/#{name}/css/*", 'public/css'
    str 
    
  catch e
    console.log "#{e.message}\n#{e.stack}"

readscripts = (name) ->
  try
    list = listfile "components/#{name}/scripts"
    str = ''
    for fname in list
      str += '<script type="text/javascript" src="js/' + fname + '"></script>\n'
    
    if path.existsSync "components/#{name}/js" 
      console.log "Copying files from components/#{name}/js to public/js" 
      sh.cp '-Rf', "components/#{name}/js/*", 'public/js'
    str 
    
  catch e
    console.log "#{e.message}\n#{e.stack}"

readbody = (name) ->
  try     
    if path.existsSync "components/#{name}/#{name}.html" 
      return fs.readFileSync "components/#{name}/#{name}.html", 'utf8' 
    else
      return ''
  catch e
    console.log "#{e.message}\n#{e.stack}"

headcss = (toload) ->
  head = ''
  for component in toload 
    if component? and component.length > 0
      head += readstyles component
  head

headjs = (toload) ->  
  head = ''
  for component in toload 
    if component? and component.length > 0
      head += readscripts component
  head

loadbody = (toload) ->
  body = ''
  for component in toload 
    if component? and component.length > 0
      body += readbody component
  body

build = (toload) ->
  css = headcss toload
  scripts = headjs toload
  body = loadbody toload
  "<!doctype html><head><title>Cure CMS</title>#{css}#{scripts}</head><body>#{body}</body></html>"

writebuild = (source) ->
  fs.writeFileSync "public/index.html", source, 'utf8'

exports.startup = (file) ->
  toload = listfile file
  html = build toload
  writebuild html
  comps = {}
  for component in toload
    console.log "Starting #{component}"
    comps[component] = require "./components/#{component}/#{component}"
    comps[component]?.startup?()

vows = require 'vows'
assert = require 'assert'

vows
  .describe('CureBlog main app')
  .addBatch
    'listfile for list1':
      topic: -> (listfile 'datatest/list1')                

      'returns two items': (topic) ->
        console.log util.inspect topic
        assert.equal topic.length, 2
        
      'they are apples and orange': (topic) ->
        assert.equal topic[0], 'apples'
        assert.equal topic[1], 'oranges'

      'read test styles':
        topic: -> readstyles 'test'

        'returns a link element to the test.css': (topic) ->
          console.log util.inspect topic
          assert.equal topic, '<link type="text/css" href="public/css/test.css"/>\n'

      'read test scripts':
        topic: -> readscripts 'test'
        
        'returns a link element to the test.js': (topic) ->
          console.log util.inspect topic
          assert.equal topic, '<link type="text/javascript" href="public/js/test.js"/>\n'
        
        'build html from test data':
          topic: -> build 'testload'
    

  .export module