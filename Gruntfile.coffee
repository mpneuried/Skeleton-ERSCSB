request = require( "request" )
module.exports = (grunt) ->
	try
		deploy = grunt.file.readJSON( "deploy.json" )
		if deploy?.configfile?
			_deployConfig = require( "./" + deploy.configfile )
	catch _err
		deploy = {}

	# Project configuration.
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		deploy: deploy
		regarde:
			serverjs:
				files: ["_src/**/*.coffee"]
				tasks: [ "coffee:serverchanged" ]
			frontendjs:
				files: ["_src_static/js/**/*.coffee"]
				tasks: [ "build_staticjs" ]
			frontendvendorjs:
				files: ["_src_static/js/vendor/**/*.js"]
				tasks: [ "build_staticjs" ]
			frontendcss:
				files: ["_src_static/css/**/*.styl"]
				tasks: [ "stylus" ]
			static:
				files: ["_src_static/static/**/*.*"]
				tasks: [ "build_staticfiles" ]
			#cson:
			#	files: ["_src/i18n/**/*.cson"]
			#	tasks: [ "cson:locals" ]
		coffee:
			serverchanged:
				expand: true
				cwd: '_src'
				src:	[ '<% print( _.first( ((typeof grunt !== "undefined" && grunt !== null ? (_ref = grunt.regarde) != null ? _ref.changed : void 0 : void 0) || ["_src/nothing"]) ).slice( "_src/".length ) ) %>' ]
				# template to cut off `_src/` and throw on error on non-regrade call
				# CF: `_.first( grunt?.regarde?.changed or [ "_src/nothing" ] ).slice( "_src/".length )
				dest: ''
				ext: '.js'

			frontendchanged:
				expand: true
				cwd: '_src_static/js'
				src:	[ '<% print( _.first( ((typeof grunt !== "undefined" && grunt !== null ? (_ref = grunt.regarde) != null ? _ref.changed : void 0 : void 0) || ["_src_static/js/nothing"]) ).slice( "_src_static/js/".length ) ) %>' ]
				# template to cut off `_src_static/js/` and throw on error on non-regrade call
				# CF: `_.first( grunt?.regarde?.changed or [ "_src_static/js/nothing" ] ).slice( "_src_static/js/".length )
				dest: 'static/js'
				ext: '.js'

			backend_base:
				expand: true
				cwd: '_src',
				src: ["**/*.coffee"]
				dest: ''
				ext: '.js'

			frontend_base:
				expand: true
				cwd: '_src_static/js',
				src: ["**/*.coffee"]
				dest: 'static/js'
				ext: '.js'


		clean:
			compiled:
				src: [ "lib", "modules", "static", "*.js" ]
			mimified: 
				src: [ "static/js/*.js", "!static/js/scripts.js" ]

		stylus:
			standard:
				options:
					"include css": true
				files:
					"static/css/style.css": ["_src_static/css/style.styl"]

		copy:
			static:
				expand: true
				cwd: '_src_static/static',
				src: [ "**" ]
				dest: "static/"

		concat: 
			js:
				files:
					"static/js/scripts.js": [ '_src_static/js/vendor/jquery.js', '_src_static/js/vendor/jquery.syncheight.min.js', '_src_static/js/vendor/easyzoom.js', '_src_static/js/vendor/bootstrap.js', "static/js/plugins.js" ]

		uglify:
			options:
				banner: '/*!<%= pkg.name %> - v<%= pkg.version %>\n*/\n'
			staticjs:
				files:
					"static/js/scripts.js": [ "static/js/scripts.js" ]

		cssmin:
			options:
				banner: '/*! <%= pkg.name %> - v<%= pkg.version %>*/\n'
			staticcss:
				files:
					"static/css/external.css": [ "_src_static/css/*.css" ]

		compress:
			main:
				options: 
					archive: "release/<%= pkg.name %>_deploy_<%= pkg.version.replace( '.', '_' ) %>.zip"
				files: [
						{ src: [ "package.json", "main.js", "server.js", "modules/**", "static/**", "lib/**", "views/**", "_src_static/css/**/*.styl" ], dest: "./" }
				]

		sftp:	
			upload:
				files:
					"./":  [ "release/<%= pkg.name %>_deploy_<%= pkg.version.replace( '.', '_' ) %>.zip" ]
				options:
					path: "<%= deploy.targetServerPath %>"
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
					createDirectories: true
	
			configfile:
				files:
					"./":  [ "<%= deploy.configfile %>" ]
				options:
					path: "<%= deploy.targetServerPath %>"
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
					createDirectories: true

		sshexec:
			cleanup:
				command: "rm -rf <%= deploy.targetServerPath %>*"
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
			cleanup_nonpm:
				command: "cd <%= deploy.targetServerPath %> && rm -rf $(ls | grep -v node_modules)"
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
			cleanrelease:
				command: "rm -rf <%= deploy.targetServerPath %>release/"
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
			unzip:
				command: [ "cd <%= deploy.targetServerPath %> && unzip -u -q -o release/<%= pkg.name %>_deploy_<%= pkg.version.replace( '.', '_' ) %>.zip", "ls" ]
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
					createDirectories: true
			doinstall:
				command: [ "cd <%= deploy.targetServerPath %> && npm install --production " ]
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
					createDirectories: true
			renameconfig:
				command: [ "cd <%= deploy.targetServerPath %> && mv <%= deploy.configfile %> config.json" ]
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"
					createDirectories: true

			stop:
				command: [ "echo <%= deploy.password %>|sudo -S stop <%= deploy.servicename %>" ]
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"

			start:
				command: [ "echo <%= deploy.password %>|sudo -S start <%= deploy.servicename %>" ]
				options:
					host: "<%= deploy.host %>"
					username: "<%= deploy.username %>"
					password: "<%= deploy.password %>"

	grunt.registerTask "ping-test", ->
		done = this.async()
		_url = "http://" + deploy.host + ":#{_deployConfig?.server?.port or 8001 }/ping"
		grunt.log.writeln( _url )
		setTimeout( ->
			request.get _url, ( err, res, body )->
				if err
					grunt.log.error(err)
					done()
					return
				grunt.log.writeln( body )
				done()
				return
		, 2000 )
		return

	# Load npm modules
	grunt.loadNpmTasks "grunt-regarde"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-stylus"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-compress"
	grunt.loadNpmTasks "grunt-contrib-concat"
	grunt.loadNpmTasks "grunt-contrib-uglify"
	grunt.loadNpmTasks "grunt-contrib-cssmin"
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-ssh"


	# just a hack until this issue has been fixed: https://github.com/yeoman/grunt-regarde/issues/3
	grunt.option('force', not grunt.option('force'))
	
	# ALIAS TASKS
	grunt.registerTask "watch", "regarde"
	grunt.registerTask "default", "build"
	grunt.registerTask "clear", [ "clean:compiled" ]

	# build the project
	grunt.registerTask "build", [ "build_server", "build_frontend" ]

	grunt.registerTask "build_server", [ "coffee:backend_base" ]

	grunt.registerTask "build_frontend", [ "build_staticjs", "build_vendorcss", "stylus", "build_staticfiles" ]
	grunt.registerTask "build_staticjs", [ "coffee:frontend_base", "concat:js", "clean:mimified" ]
	grunt.registerTask "build_vendorcss", [ "cssmin:staticcss" ]
	grunt.registerTask "build_staticfiles", [ "copy:static" ]

	grunt.registerTask "release", [ "build", "uglify:staticjs", "compress" ]	

	grunt.registerTask "sshdeploy-upload", [ "sftp:upload", "sshexec:unzip", "sshexec:cleanrelease" ]
	grunt.registerTask "sshdeploy-configure", [ "sftp:configfile", "sshexec:renameconfig" ]
	grunt.registerTask "sshdeploy-restart", [ "sshexec:stop", "sshexec:start" ]
	
	grunt.registerTask "sshdeploy",		[ "sshexec:cleanup_nonpm", "sshdeploy-upload", "sshdeploy-configure", "deploy-restart" ]
	grunt.registerTask "sshdeploy-npm",	[ "sshexec:cleanup", "sshdeploy-upload", "sshexec:doinstall", "sshdeploy-configure", "deploy-restart" ]


	grunt.registerTask "deploy-restart", "sshdeploy-restart"
	grunt.registerTask "deploy-npm", [ "release", "sshdeploy-npm", "build_staticjs", "ping-test" ]
	grunt.registerTask "deploy", [ "release", "sshdeploy", "build_staticjs", "ping-test" ]
