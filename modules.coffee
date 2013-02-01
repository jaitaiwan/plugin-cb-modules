###
# @name cb-modules
# @author Daniel J Holmes
# @description A plugin which abstracts away dealing with req and response objects and provides an MVC interface
###

Plugin = require '../../library/Plugin.main'
IO = require '../../coffeeblog/log'
path = require 'path'
fs = require 'fs'
mvcHelper = require '../../helpers/Helper.mvc'

class cb_modules extends Plugin
	routes: []

	init: (@app) ->
		super
		@loadModules()

	setupRoutes: (Router) =>
		super Router

	loadModules: =>
		try
			data = fs.readdirSync path.resolve("#{__dirname}/../../modules/")
		catch e
			IO.error "The modules folder is missing!"
			throw "Missing the modules folder"
			return false
		@modules = []
		for moduleDir in data
			if moduleDir[0...1] is "." then continue
			moduleDir = path.resolve "#{__dirname}/../../modules/#{moduleDir}"
			try
				moduleInfo = require "#{moduleDir}/config"
				moduleInfo.dir = moduleDir
				@modules.push moduleInfo
				IO.log "Loaded module '#{moduleInfo.name}' from '#{path.relative(path.resolve('./'),moduleDir)}'"
				try
					IO.log "Initialising module with namespace '../#{path.relative(path.resolve('./'),moduleDir)}/#{moduleInfo.namespace}'"
					@routes.push
						address: "/#{moduleInfo.namespace}/:controller?/:action?/:view?"
						method: 'get'
						callback: (req, res, template, next) ->
							return mvcHelper.loadModule moduleInfo, req, res, template, next
					@routes.push
						address: "/#{moduleInfo.namespace}/:controller?/:action?/:view?"
						method: 'put'
						callback: (req, res, template, next) ->
							return mvcHelper.loadModule moduleInfo, req, res, template, next
					@routes.push
						address: "/#{moduleInfo.namespace}/:controller?/:action?/:view?"
						method: 'del'
						callback: (req, res, template, next) ->
							return mvcHelper.loadModule moduleInfo, req, res, template, next
					@routes.push
						address: "/#{moduleInfo.namespace}/:controller?/:action?/:view?"
						method: 'post'
						callback: (req, res, template, next) ->
							return mvcHelper.loadModule moduleInfo, req, res, template, next
					IO.log "Initialised module '#{moduleInfo.name}' with namespace '#{moduleInfo.namespace}'"
				catch e
					IO.error "Failed to initialise '#{moduleInfo.name}' with namespace '#{moduleInfo.namespace}'"
					IO.debug e
			catch e
				IO.warn "Failed to load module from \"#{moduleDir}\""
				IO.debug e
		Router = require '../../coffeeblog/router'
		@setupStaticRoutes Router.singleton()
		@setupRoutes Router.singleton()
		true

	setupStaticRoutes:(router) =>
		for module in @modules
			##TODO: Make this part work... lol
			router.addStaticRoute "/#{module.name}", path.resolve "#{__dirname}/../../modules/#{module.name}/public"


module.exports = cb_modules