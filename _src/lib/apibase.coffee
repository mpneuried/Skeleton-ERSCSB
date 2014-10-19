_ = require('lodash')

config = require( "./config" )

module.exports = class APIBase extends require( "mpbasic" )( config )
	
	defaults: =>
		return @extend {}, super, 
			logHttpErrors: false

	createRoutes: ( basepath, express )=>
		express.all	"#{basepath}*", @send404
		return

	_checkAuth: ( req, res, next )=>
		# this is just a placeholder
		next()
		return

	send404: ( req, res )=>
		@_error( res, @_handleError( true, "EINVALIDURL" ) )
		return

	# a standard retun handling
	_return: ( res, next )=> 
		# request has been already send or aborted
		if res.headersSent
			return
		return ( err, result )=>
			# request has been already send or aborted
			if res.headersSent
				return
			if err
				@_error( res, err )
				next() if next?
				return
			@_send( res, result )
			next() if next?
			return

	###
	## _send
	
	`apibase._send( req, data )`
	
	Generic send method to send the results as text or JSON string
	
	@param { Response } res Express Response 
	@param { Any } data Any simple data to send to the client
	
	@api private
	###
	_send: ( res, data, statusCode = 200 )=>
		# request has been already send or aborted
		if res.headersSent
			return

		if not res.get( "Cache-Control" )?
			res.set( "Cache-Control", "no-cache" )

		if _.isString( data )
			res.status( statusCode ).send( data )
		else
			# convert to the silly media api v1 format format
			res.status( statusCode ).json( data )
		return

	###
	## _error
	
	`apibase._error( req, err [, statusCode] )`
	
	Generic error method to anser the client with an error. This method also tries to optimize the error with some details out of the **Errors detail helper**
	
	@param { Response } res Express Response 
	@param { Error|Object|String } err The error name or Object
	@param { Number } [statusCode=500] The http status code. This could also be defined via the **Errors detail helper**
	
	@api private
	###
	_error: ( res, err, statusCode = 500 )=>
		# request has been already send or aborted
		if res.headersSent
			return

		res.set( "Cache-Control", "max-age=0" )

		#if @_checkLogging( "debug" )
		if @config.logHttpErrors
			@error "HTTP ERROR", JSON.stringify( err ), "\n"

		if _.isString( err )
			if @_ERRORS[ err ]? and ( [ statusCode, msg ] = @_ERRORS[ err ] )
				_err = 
					errorcode: err
					message: msg( err )
				_err.data = err.data if err.data?
				res.status( statusCode ).json( _err )
			else
				res.send( err, statusCode )
		else
			if err instanceof Error
				res.status( err.statusCode or statusCode ).json( _.pick( err, [ "name", "message", "data" ] ) )
			else
				res.status( err.statusCode or statusCode ).json( _.pick( err, [ "name", "message", "data" ] ) )
		return

	###
	## _allowCORS
	
	`apibase._allowCORS( req, res, next )`
	
	Express middleware to allow CORS requests for a route
	
	@param { Request } req Express Request 
	@param { Response } res Express Response 
	@param { Function } next Express middleware success function 
	
	@api private
	###
	_allowCORS: ( req, res, next )=>
		if req.method is "OPTIONS"
			headers =
				"content-length": 0
				'Access-Control-Allow-Origin': "*"
				'Access-Control-Allow-Methods': 'GET,DELETE,POST,OPTIONS'
				'Access-Control-Allow-Headers': 'Content-Type,Accept,X-Requested-With'
				"access-control-max-age": 1000000000
			for _k, _v of headers
				res.set( _k, _v )
			res.send( "OK", 204 )
		return

	_addCORS: ( req, res, next )=>
		res.set( "Content-Type", "application/json" )
		res.set( "Access-Control-Allow-Origin", "*" )
		next()
		return


	ERRORS: =>
		return @extend {}, super, 
			"EINVALIDURL": [ 404, "Page not found" ]