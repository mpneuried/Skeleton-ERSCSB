_ = require( "lodash" )
crypto = require( "crypto" )

class RedisHash extends require( "../lib/redisconnector" )

	@groupname: null

	initialize:=>
		if not @groupname?.length
			@_handleError( false, "ENOGROUPNAME" )
			return

		# wrappers to wait until redis is ready
		@get = @_waitUntil( @_get, "connected" )
		@list = @_waitUntil( @_list, "connected" )
		@insert = @_waitUntil( @_insert, "connected" )
		@update = @_waitUntil( @_update, "connected" )
		@delete = @_waitUntil( @_delete, "connected" )

		@connect()
		return

	_get: ( args..., cb )=>
		[ _id, options ] = args
		if not options?
			options = {}
		@redis.hget( @_getKey( @groupname ), _id, @_return( cb, true, options ) )
		return

	_list: ( args..., cb )=>
		[ options ] = args
		if not options?
			options = {}
		@redis.hgetall( @_getKey( @groupname ), @_return( cb, options ) )
		return

	_insert: ( args..., cb )=>
		[ body, options ] = args
		if not options?
			options = {}
		
		_sBody= @_stringifyBody( body, options )
		_id = @_generateID( _sBody )

		@redis.hset( @_getKey( @groupname ), _id, _sBody, @_return( cb, options ) )
		return

	_update: ( args..., cb )=>
		[ _id, body, options ] = args
		if not options?
			options = {}

		@_get _id, options, ( err, current )=>
			if err
				cb( err )
				return

			if options.merge
				_sBody= @_stringifyBody( extend( true, {}, current, body ), options )
			else
				_sBody= @_stringifyBody( body, options )
			
			@redis.hset( @_getKey( @groupname ), _id, _sBody, @_return( cb, options ) )
			return
		return

	_delete: ( args..., cb )=>
		[ _id, options ] = args
		if not options?
			options = {}

		@_get _id, options, ( err, current )=>
			if err
				cb( err )
				return
			@redis.hdel( @_getKey( @groupname ), _id, @_return( cb, options ) )
			return
		return

	_return: ( cb, args... , options )=>
		[ errorOnEmpty ] = args
		return ( err, data )=>
			if err
				cb( err )
				return

			if errorOnEmpty and not current?
				@_handleError( cb, "ENOTFOUND" )
				return

			cb( null, @_postProcess( data, options ) )
			return

	_postProcess: ( data, options )=>
		if _.isArray( data )
			_ret = []
			for el in data
				_ret.push @_postProcess( el, options )
			return _ret

		return @_postProcessElement( data, options )

	_postProcessElement: ( data, options )=>
		return JSON.parse( data )

	_stringifyBody: ( body, options )=>
		if _.isString( body )
			return body
		else
			return JSON.stringify( body )

	_generateID: ( sBody )=>
		ts = Date.now()
		ts
			
	ERRORS: =>
		return @extend {}, super, 
			"ENOGROUPNAME": [ 500, "A `this.groupname` key as string is required" ]
			"ENOTFOUND": [ 404, "Element of `#{ @groupname }` not found" ]

moduel.exports = RedisHash
