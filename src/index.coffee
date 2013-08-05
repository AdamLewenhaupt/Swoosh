require 'js-yaml'
mongoose = require 'mongoose'
factory = require './factory'

parseType = (mbyString) ->
	if typeof mbyString == "string"
		eval mbyString
	else
		mbyString.map parseType

loadData = (path, fn) ->
	try
		doc = require(path)
	catch e
		err = e
	if doc
		fn null, doc
	else
		fn err

initialize = (doc) ->
	runLogs = doc.log ? true
	url = doc.database
	root = doc.path ? "persistent"
	retval = {}

	mLog = (str) ->
		if runLogs 
			console.log str

	for collection of doc.collections
		fields = {}
		for field of doc.collections[collection].fields
			data = parseType doc.collections[collection].fields[field]

		methods = doc.collections[collection].methods
		if typeof methods == "string" && methods == "all"
			methods = ["get", "put", "post", "delete"]

		retval[collection] = factory collection, fields, methods, doc.collections[collection].public, root

	if url
		mLog "Establishing database connection"
		mongoose.connect url, doc["db-options"], (err) ->
			unless err
				mLog "Successfully connected to database"
			else
				mLog err

	mongoose.connection.on 'error', (err) ->
		mLog err
	
	retval

module.exports = (path, fn) ->

	self = this
	self.route = (app) ->
		for attr of self.collections
			self.collections[attr].route(app)

	loadData path, (err, doc) ->
		if err
			fn err
		else
			self.collections = initialize doc
			fn.call self, null, self.collections