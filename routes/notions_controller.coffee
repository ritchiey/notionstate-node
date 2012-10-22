database = require('../database')



exports.list = (req, res) ->
  res.render "notions/index.jade",
    title: "Notions"


exports.create = (req, res) ->
  doc = req.body.notion
  doc.created_at = new Date()
  db = database.connect()
  db.save doc
  res.redirect('back')