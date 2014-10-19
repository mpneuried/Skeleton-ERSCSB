Config = require( "../lib/config" )

class RestBase extends require( "../lib/apibase" )

	model: null

	createRoutes: ( basepath, router )=>
		
		router.get "#{basepath}/:id", @_checkAuth, @get
		router.put "#{basepath}/:id", @_checkAuth, @update
		router.delete "#{basepath}/:id", @_checkAuth, @delete
		router.post "#{basepath}", @_checkAuth, @create
		router.get "#{basepath}", @_checkAuth, @list

		super
		return

	get: ( req, res )=>
		return if @_checkModel( res )

		_id = req.params.id
		@model.get( _id, @_return( res ) )
		return

	update: ( req, res )=>
		return if @_checkModel( res )

		_id = req.params.id
		_body = req.body
		@model.update( _id, _body, @_return( res ) )
		return

	delete: ( req, res )=>
		return if @_checkModel( res )

		_id = req.params.id
		@model.delete( _id, @_return( res ) )
		return

	create: ( req, res )=>
		return if @_checkModel( res )

		_body = req.body
		@debug "create", _body, req.headers
		@model.create( _body, @_return( res ) )
		return

	list: ( req, res )=>
		return if @_checkModel( res )

		@model.list( @_return( res ) )
		return

	_return: ( res )=>
		return ( err, result )=>
			if err
				@_error( res, err )
				return
			@_send( res, result )
			return

	_checkModel: ( res )=>
		if not @model?
			@_handleError( res, "ENOMODEL" )
			return true
		return false

	ERRORS: =>
		return @extend {}, super, 
			"ENOMODEL": [ 500, "No model defined" ]


module.exports = RestBase