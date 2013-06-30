require 'js-yaml'
mongoose = require 'mongoose'
factory = require './factory'

loadData = (path, fn) ->
	try
		doc = require(path)
	catch e
		err = e
	if doc
		fn null, doc
	else
		fn err

initialize = (doc, log) ->
	runLogs = log ? true
	retval = {}

	mLog = (str) ->
		if runLogs 
			console.log str

	for obj of doc.objects
		fields = {}
		for field of doc.objects[obj].fields
			fields[field] = eval(doc.objects[obj].fields[field]) 
		retval[obj] = factory obj, fields, doc.objects[obj].methods, doc.objects[obj].public

	mLog "Establishing database connection"
	mongoose.connect doc.database, doc["db-options"], (err) ->
		unless err
			mLog "Successfully connected to database"
		else
			mLog err

	mongoose.connection.on 'error', (err) ->
		mLog err
	
	retval

module.exports = (path, log, fn) ->

	self = this
	self.route = (app) ->
		for attr of self.objects
			self.objects[attr].route(app)

	if arguments.length == 2
		fn = log
		log = false

	loadData path, (err, doc) ->
		if err
			fn err
		else
			self.objects = initialize(doc, log)
			fn.call self, null, self.objects