# Swoosh #

Swoosh is a quick declarative way to speed up basic persistent-layer stuff.

## The yaml part ##
>>>>>>> b3d636c8b548508dca8dcd71d9e040522e63a69c

To use swoosh, one simple create a yaml file, for example named swoosh.yml
```yaml
# The database url.
database: mongodb://<user>:<pass>@host.com:port
# Here we define all objects.
collections:
	# Defining the users object.
    users:
    	# The objects field.
        fields:
            name: String
            pass: String
        # What kind of restful request should the object handle?
        methods:
            - get
            - put
            - post
        # Optionally you can specify what fields you want to respond with
        # This for example would make a get-request only deliver the name of the user.
        public:
        	- name
```

## The node part ##

```javascript
path = require('path');
swoosh = require('swoosh');

swoosh(path.join(__dirname, "swoosh.yml"), function(err, collections){
	if(err) console.log("Err :(", err);
	else {
		// automatic routing only works with express.
		this.route(app);

		/*
		Swoosh it not only useable when you need to route, but provide
		neat ways to send requests from node aswell.

		For example to create a new user we simply write.
		*/
		collections["users"].post({
			name: "Bob",
			pass: "superSecret"
			}, function(bob) {
				console.log(bob.name);
			});
	}
});
```

This package is still in a very early stage, but if people find it interesting I would love to improve it further.


## API ##

### Yaml ###

#### database ####
Required if swoosh is to automatically connect to a database.
If you wish to connect to a database manually skip this field.

#### log ####
Logging is by default set to true, so this field must only be specified if you want
to stop loggging.

#### path ####
The path is the root from wich the persistent routes are available. This is by default set to persistent
which means that for example a get request to a users collection would have the url: "/persistent/users/"

#### collections ####
It's here you define all the collections, a collection in turn consists of a few fields

##### fields #####
This field contains all the fields of the collection,
for example: `name: String`, for further information on supported types, 
please refere to http://mongoosejs.com/docs/schematypes.html

##### methods #####
This field describes what RESTful methods should be supported by the generated routes, 
left empty the collection will only be accessable by the nodejs API.

##### public #####
The public field is a type of a filter that will be applied when respondining to requests.
For example if the public field was defined as such:
```yaml
public:
  - name
```
a get request would only send the name field.

If no public field is defined all fields will be sent.

### Node ###

As previously described to access the api first run

```javascript
var path = require('path'),
    swoosh = require('swoosh');
    
swoosh(path.join(__dirname, "swoosh.yml"), function(err, collections){
	
	//Do something greate
});
```

#### Collection ####

The collections object provides a simple way to handle the specified collections from nodejs.

##### pub #####

` pub(entity) -> public entity `

This method is only available if you specified public fields for you collection.
It takes but one argument, a single entity from the collection and from it creates a public version
of the object.

##### get #####

` get(id, callback) where callback(err, response)`

This is the server-side equivelent of a get request and will
deliver a specific entity if a id is specified, if the id field is null
the whole collection is delivered.

##### post #####

` post(data, callback) where callback(err, response)`

The server-side equivelent of a post request, given the data for creation it
will create a new entity in the database and return it as response to the callback.

##### put #####

` put(id, data, callback) where callback(err, response)`

The server-side equivelent of a put request, provide a id and some data and this method will update
the specified entity in the database and the return the entity with the updates in place.

##### delete #####

` delete(id, callback) were callback(err)`

The server-side equivelent of a delete request, given a id this method will remove the matching entity from the database.

##### route #####

` route(app) where app is an express application`

The route function require an express application to operate and will register the routes for the collection.

#### Swoosh ####

This api is accessed from the swoosh function.
``` javascript
swoosh.route(app) // Like this
swoosh(.., function(err, collection) {

	this.route(app) // Or this
});
```

##### route #####

` route(app) where app is an express application`

This function will generate all specified routes for all the collections.
