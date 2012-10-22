
###
Module dependencies.
###
express = require("express")
routes = require("./routes")
usersController = require("./routes/user")
notionsController = require("./routes/notions_controller")
User = require("./models/user")
Notion = require("./models/notion")
http = require("http")
path = require("path")
rack = require('asset-rack')
ioreq = require("socket.io")
database = require('./database')

assets = new rack.AssetRack [
  new rack.JadeAsset
    url: '/templates.js'
    dirname: __dirname + '/views'
    clientVariable: 'Templates'
  new rack.BrowserifyAsset
    url: '/client.js'
    filename: __dirname + '/public/javascripts/client.coffee'
  new rack.LessAsset
    url: '/style.css'
    filename: __dirname + '/public/stylesheets/style.less'
  ]

assets.on 'complete', ->
  app = express()
  app.configure ->
    app.set "port", process.env.PORT or 3000
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use assets
    app.use express.favicon()
    app.use express.logger("dev")
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser("3984ukjhfkshfeiuhn")
    app.use express.session()
    app.use app.router
    app.use require('less-middleware') src: __dirname + '/public'
    app.use express.static(path.join(__dirname, "public"))

  app.configure "development", ->
    app.use express.errorHandler()

  app.get "/", routes.index
  app.get "/users", usersController.list
  app.post "/notions", notionsController.create
  app.get "/notions", notionsController.list
  server = http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")


  io = ioreq.listen(server)
  io.sockets.on 'connection', (socket) ->
    db = database.connect()

    db.query { method: 'GET', path: '_changes', query: {descending: true, limit: 1} }, (err, res) ->
      lastSeq = res.last_seq
      feed = db.changes include_docs: true, since: lastSeq

      feed.filter = (doc, req) ->
        true

      sendOutstanding = (options, callback) ->
        options ||= {}
        db.view 'notions/outstanding', options, (err, docs) ->
          if err
            console.log err
          else
            docs.forEach (doc) ->
              socket.emit 'update', doc

      sendOutstanding()
      feed.on 'change', (change) ->
        console.log JSON.stringify(change)
        socket.emit 'update', change.doc
        # sendOutstanding {key: change.id}
