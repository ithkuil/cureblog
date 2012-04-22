express = require 'express'
config = require './config'
childproc = require 'child_process'

app = express.createServer()
app.get '/', (req, res) ->
  childproc.exec './restart.sh'

app.listen config.restarterport


