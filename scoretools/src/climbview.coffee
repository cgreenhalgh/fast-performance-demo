# utils to generate musiccodes climbview config file

class Generator
	constructor: (@title, config) ->
		@preload = []
		@layers = [
				title:'background'
				channel:'v.background'
				#defaultUrl: config.background_url
				loop: true
				fadeIn: config.backgroundfadein ? 0
				fadeOut: config.backgroundfadeout ? 0				
				crossfade: false
			,
				title:'animation'
				channel:'v.animation'
				defaultUrl: config.noanimationurl
				loop: false
				fadeIn: 0
				fadeOut: 0
				crossfade: true				
			,
				title:'weather'
				channel:'v.weather'
				loop: true
				fadeIn: config.weatherfadein ? 0
				fadeOut: config.weatherfadeout ? 0				
				crossfade: true				
			,
				title:'muzicode'
				channel:'v.muzicode'
				loop: false
				fadeIn: config.muzicodefadein ? 0
				fadeOut: config.muzicodefadeout ? 0				
				holdTime: config.muzicodeholdtime ? null
				crossfade: true				
		]
		@add config.noanimationurl
		@add config.noweather_url
		@add config.defaultmuzicodeurl
		@add config.noweather_url
		@add config.rain_url
		@add config.snow_url
		@add config.sun_url
		@add config.storm_url
		@add config.wind_url

	get: ->
		{
			title: @title
			generated: (new Date()).toISOString()
			preload: @preload
			layers: @layers
		}

	add: (url) ->
		if url? and (@preload.indexOf url)<0
			@preload.push url

module.exports.generator = (title, config) ->
	new Generator(title, config)

module.exports.BACKGROUND = 'v.background'
module.exports.ANIMATION = 'v.animation'
module.exports.WEATHER = 'v.weather'
module.exports.MUZICODE = 'v.muzicode'
