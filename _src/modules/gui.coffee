config = require( "../lib/config" )

class GUI extends require( "../lib/apibase" )

	createRoutes: ( basepath, express )=>

		express.get "#{basepath}index.html", @_checkAuth, @index
		express.get "#{basepath}index", @_checkAuth, @index
		express.get "#{basepath}", @_checkAuth, @index
		
		#express.all "#{basepath}*", ( req, res )->res.redirect( "/index.html" )

		super
		
		return

	index: (req, res)=>
		_tmpl = 
			title: config.get( "server" ).title
		
		res.render('index', _tmpl )
		return

module.exports = new GUI()