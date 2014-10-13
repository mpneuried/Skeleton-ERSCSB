path = require( "path" )
http = require( "http" )

# external modules
_ = require('lodash')
express = require( "express" )

# express 4 modules
compression = require('compression')
serveStatic = require('serve-static')
morgan = require('morgan')
bodyParser = require('body-parser')
swig = require('swig')

# internal modules
Config = require( "./lib/config" )

class Server extends require( "mpbasic" )( Config )

	defaults: =>
		@extend super,
			port: 8001,
			host: "localhost"
			listenHost: null
			basepath: "/"
			title: "Webmart GUI V3"
			templateCache: false


	constructor: ->
		super
		@express = express()
		
		@on "configured", @load
		@on "loaded", @start

		@rest = {}

		@configure()

		return

	configure: =>
		@debug "configue express"
		expressConf = Config.get( "express" )

		@express.set( "title", @config.title )
		@express.use( morgan( expressConf.logger ) )
		@express.use( compression() )
		@express.use( bodyParser.json() )
		
		@express.use( serveStatic( path.resolve( __dirname, "./static" ), maxAge: expressConf.staticCacheTime ) )

		@express.engine('html', swig.renderFile)
		@express.set('views', path.resolve( __dirname, './views' ))
		@express.set('view engine', 'html')
		@express.set('view cache', @config.templateCache )

		@emit "configured"
		return

	load: =>
		@debug "load"

		# load rest modules 
		
		@rest = require( "./modules/rest" )
		@gui = require( "./modules/gui" )
	
		@express.get "/ping", @ping
		@express.get "/ping.html", @ping

		@rest.createRoutes( "/api/", @express )
		@gui.createRoutes( "/", @express )

		# init 404 route
		@express.all "*", @send404

		@express.use ( err, req, res, next )=>
			@fatal "unkown-error", err
			res.send( err )
			return

		process.on "uncaughtException", ( err )=>
			@fatal "unkown-error", err
			return

		@emit "loaded"

		return

	ping: ( req, res )=>
		res.send( "OK - #{Config.get( "version" )}" )
		return

	start: =>
		# we instantiate the app using express 2.x style in order to use socket.io
		server = http.createServer( @express )
		server.listen( @config.port, @config.listenHost )

		@info "start: listen to port #{@config.listenHost}:#{ @config.port }"
		return

	send404: ( req, res )=>
		res.status( 404 )
		res.send( "Page not found!" )

		return

	defaults: =>
		@extend super,
			port: 8400,
			host: "localhost"
			listenHost: null
			basepath: "/"
			title: "RSMQ Monitor"
	
module.exports = new Server()

	