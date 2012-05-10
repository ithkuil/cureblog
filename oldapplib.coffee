fs = require 'fs'
util = require 'util'
path = require 'path'
proc = require 'child_process'
sh = require 'shelljs'

if path.existsSync 'localconfig.coffee'
  config = require './localconfig'
else
  config = require './config'

process.config = config

getorder = (fname) ->
  loadstr = fs.readFileSync fname, 'utf8'
  loadstr.split '\n'
 
head = ''

trim = (string) ->
  string.replace /^\s*|\s*$/g, ''

listfile = (fname) ->
  str = fs.readFileSync fname, 'utf8'
  list = str.split '\n'
  (trim item for item in list when item? and trim(item).length>0)

process.listfile = listfile
  
readstyles = (name) ->
  try
    list = listfile "components/#{name}/styles"
    str = ''
    for fname in list
      str += '<link rel="stylesheet" type="text/css" href="css/' + fname + '"/>\n'
    
    if path.existsSync "components/#{name}/css"
      sh.cp '-Rf', "components/#{name}/css/*", 'public/css'
    str
    
  catch e
    console.log "#{e.message}\n#{e.stack}"

readscripts = (name) ->
  try
    list = listfile "components/#{name}/scripts"
    str = ''
    for fname in list
      if fname.indexOf('/') is 0
        prefix = ''
      else
        prefix = 'js/'
      filepath = prefix + fname
      str += fs.readFileSync filepath, 'utf8'
    
    if path.existsSync "components/#{name}/js"
      sh.cp '-Rf', "components/#{name}/js/*", 'public/js'
    str
    
  catch e
    console.log "#{e.message}\n#{e.stack}"

copyimages = (name) ->
  try
    if path.existsSync "components/#{name}/images"
      sh.cp '-Rf', "components/#{name}/images/*", 'public/images'
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
  fs.writeFile 'public/js', head, 'utf8'
  '<script src="js/combined.js"></script>'
 

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
  for component in toload
    copyimages component

  "<!doctype html><html><head><title>Cure CMS</title>#{css}#{scripts}</head><body>#{body}</body></html>"

writebuild = (source) ->
  fs.writeFileSync "static/index.html", source, 'utf8'

exports.startup = (file) ->
  toload = listfile file
  comps = {}
  for component in toload
    try
      console.log "Building #{component}"
      comps[component] = require "./components/#{component}/#{component}"
      comps[component]?.build?()
    catch e
      console.log util.inspect e

  for component in toload
    try
      console.log "Starting #{component}"
      key = "./components/#{component}/#{component}"
      if key in require.cache then delete require.cache[key]
      comps[component] = require key
      comps[component]?.startup?()
    catch e
      console.log util.inspect e

  html = build toload
  writebuild html

