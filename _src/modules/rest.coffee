Config = require( "../lib/config" )

class RestBase extends require( "../lib/apibase" )

	setModel: ( @model )=>
		return

	createRoutes: ( basepath, express )=>
		
		express.get "#{basepath}/:id", @_checkAuth, @get
		express.put "#{basepath}/:id", @_checkAuth, @update
		express.del "#{basepath}/:id", @_checkAuth, @del
		express.post "#{basepath}", @_checkAuth, @create
		express.get "#{basepath}", @_checkAuth, @list

		super

		return


module.exports = RestBase