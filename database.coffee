cradle = require("cradle")

cradle.setup
  host: "localhost"
  cache: true
  raw: false

createDesignDocuments = (db) ->
  console.log "Creating design documents"
  db.save '_design/notions',

    # Notions requiring the user's attention
    outstanding:
      map: (doc) ->
        emit [doc.user, doc.id], doc

exports.connect = connect = -> new (cradle.Connection)().database("notionstate")
db = connect()

db.exists (err, exists) ->
  if err
    console.log "Error connecting to the database", err
  else if exists
    console.log "Using existing notionstate database"
  else
    console.log "Creating the notionstate database"
    db.create()
    createDesignDocuments(db)


    
    # populate seed documents 
    # User.add
    #   name: "Ritchie Young"
    #   login: "ritchiey"
    #   email: "ritchiey@gmail.com"
    #   password: "secret"

