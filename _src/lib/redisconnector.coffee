redis = require( "redis" )

config = require( "../lib/config" )

globalclient = null

class RedisConnector extends require( "mpbasic" )( config )

	defaults: =>
		return @extend super, 
			seperateClient: false

	constructor: ->
		super
		# just a simulation to globaly handle server powered stores
		@connected = false
		return

	connect: =>
		@configRedis = config.get( "redis" )
		if @configRedis.client?.constructor?.name is "RedisClient"
			@redis = @configRedis.client
		else if globalclient and not @configRedis.seperateClient
			@redis = globalclient?.constructor?.name is "RedisClient"
		else
			try
				redis = require("redis")
			catch _err
				@error( "you have to load redis via `npm install redis hiredis`" )
				return
			@redis = redis.createClient( @configRedis.port or 6379, @configRedis.host or "127.0.0.1", @configRedis.options or {} )

			if not @config.seperateClient
				globalclient = @redis

		@connected = @redis.connected or false

		@redis.on "connect", =>
			@connected = true
			@debug "connected"
			@emit( "connected" )
			return

		@redis.on "error", ( err )=>
			if err.message.indexOf( "ECONNREFUSED" )
				@connected = false
				@emit( "disconnect" )
			else
				@error( "Redis ERROR", err )
				@emit( "error" )
			return
		return

	_getKey: ( id, name = @name )=>
		_key = @configRedis.prefix
		if name?
			_key += ":#{name}"
		if id?
			_key += ":#{id}"
		return _key

module.exports = RedisConnector