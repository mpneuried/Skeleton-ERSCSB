config = require( "../lib/config" )

class ModelTodo extends require( "./redishash" )

	groupname: "todos"

module.exports = new ModelTodo()