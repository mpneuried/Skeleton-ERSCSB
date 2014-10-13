Config = require( "../lib/config" )

class Rest extends require( "../lib/apibase" )

	createRoutes: ( basepath, express )=>
		
		express.options	"#{basepath}/*", @_allowCORS
		
		super

		return

module.exports = new Rest()