express = require 'express'
jade = require 'jade'
MongolianDeadBeef = require 'mongolian'
server = new MongolianDeadBeef
nowjs = require 'now'
fs = require 'fs'
util = require 'util'
request = require 'request'
childproc = require 'child_process'
connect = require 'connect'
cachefiles = require '../../cachefiles'

ObjectId = MongolianDeadBeef.ObjectId
ObjectId.prototype.toJSON = ->
  return @toString()

db = server.db 'app'

app = express.createServer()

process.app = app

app.use express.cookieParser()
app.use express.session { secret: 'burrito13' }
oneYear = 31557600000
#app.use express.static 'public', { maxAge: oneYear }
#app.enable 'view cache'
#app.use connect.compress()

app.set 'view options', { layout: false }
#app.register('.html', require('jade'));

#app.use cachefiles


#app.get '*', (req, res) ->
#  #console.log 'all'
#  #console.log req.url
#  res.end 'ok'

cache = {}

app.get '/', (request, response) ->
  response.end 'ok'

  #if cache['/']?
  #  response.end cache['/']
  #else
  #  index = fs.readFile 'static/index.html', 'utf8', (err, data) ->
  #    response.end data
  #    cache['/'] = data

  #page = fs.readFileSync 'static/page', 'utf8'
  #index = index.replace '{{page}}', page

  #response.send index


nowjs = require 'now'
everyone = nowjs.initialize app

process.everyone = everyone

everyone.now.restartServer = ->
  request 'http://127.0.0.1:' + process.config.restarterport + '/'

everyone.now.saveStatic = (name, html, callback) ->
  fs.writeFile "static/#{name}", html, (err) ->
    if err
      console.log err
      if callback? then callback false
    else
      if callback? then callback true

everyone.now.dbinsert = (col, data) ->
  db.collection(col).insert data

everyone.now.dbrestore = (criteria) ->
  db.collection('backups').findOne criteria: criteria, (err, backups) ->
    for backup in backups
      console.log backup

everyone.now.dbupdate = (col, criteria, data) ->
  db.collection(col).find(criteria).toArray (err, doc) ->
    if (err)
      console.log err
    db.collection('backups').insert
      status: 'saved'
      col: col
      modified: new Date()
      criteria: criteria
      data : doc
    db.collection(col).update criteria, data

everyone.now.dbfind = (col, callback) ->
  db.collection(col).find().toArray (err, data) ->
    callback data

everyone.now.saveFile = (filename, filedata, callback) ->
  fs.writeFile filename, filedata, 'utf8', (err) ->
    callback err
    
console.log "OIC listening on port #{process.config.port}"
app.listen process.config.port


