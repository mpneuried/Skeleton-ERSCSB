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
		@create = @_waitUntil( @_create, "connected" )
		@update = @_waitUntil( @_update, "connected" )
		@delete = @_waitUntil( @_delete, "connected" )

		@connect()
		return

	_get: ( args..., cb )=>
		[ _id, options ] = args
		if not options?
			options = {}
		@redis.hget( @_getKey( @groupname ), _id, @_return( "get", cb, _id, true, options ) )
		return

	_list: ( args..., cb )=>
		[ options ] = args
		if not options?
			options = {}
		@debug "list", @_getKey( @groupname )
		@redis.hgetall( @_getKey( @groupname ), @_return( "list", cb, options ) )
		return

	_create: ( args..., cb )=>
		[ body, options ] = args
		if not options?
			options = {}
		
		_sBody= @_stringifyBody( body, options )
		_id = @_generateID( _sBody )

		rM = []
		rM.push [ "HSET",  @_getKey( @groupname ), _id, _sBody ]
		rM.push [ "HGET",  @_getKey( @groupname ), _id ]
		@redis.multi( rM ).exec( @_return( "create", cb, _id, options ) )
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
			
			rM = []
			rM.push [ "HSET",  @_getKey( @groupname ), _id, _sBody ]
			rM.push [ "HGET",  @_getKey( @groupname ), _id ]
			@redis.multi( rM ).exec( @_return( "update", cb, _id, options ) )
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
			
			rM = []
			rM.push [ "HGET",  @_getKey( @groupname ), _id ]
			rM.push [ "HDEL",  @_getKey( @groupname ), _id ]
			@redis.multi( rM ).exec( @_return( "delete", cb, _id, options ) )
			return
		return

	_return: ( type, cb, args... , options )=>
		[ _id, errorOnEmpty ] = args
		return ( err, results )=>
			if err
				cb( err )
				return

			if _.isArray( results )
				[ pre..., data ] = results
				if type is "delete"
					data = pre[ 0 ]
			else
				data = results

			if errorOnEmpty and not data?
				@_handleError( cb, "ENOTFOUND" )
				return
			else if not data?
				data = []


			cb( null, @_postProcess( data, _id, options ) )
			return

	_postProcess: ( args..., options )=>
		[ data, key ] = args
		@debug "_postProcess", data, options
		if _.isObject( data )
			_ret = []
			for key, el of data
				_ret.push @_postProcess( el, key, options )
			return _ret

		return @_postProcessElement( data, key, options )

	_postProcessElement: ( data, key, options )=>
		_data = JSON.parse( data )
		_data._id = key
		return _data

	_stringifyBody: ( body, options )=>
		if _.isString( body )
			return body
		else
			return JSON.stringify( body )

	_generateID: ( sBody )=>
		ts = Date.now()
		# TODO add hash
		return ts
			
	ERRORS: =>
		return @extend {}, super, 
			"ENOGROUPNAME": [ 500, "A `this.groupname` key as string is required" ]
			"ENOTFOUND": [ 404, "Element of `#{ @groupname }` not found" ]

module.exports = RedisHash
