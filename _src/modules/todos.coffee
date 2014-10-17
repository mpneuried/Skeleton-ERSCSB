class RestTodo extends require( "./restbase" )

	model: require( "../models/todos" )

module.exports = new RestTodo()