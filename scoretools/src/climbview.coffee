# utils to generate musiccodes climbview config file

class Generator
	constructor: (@title, config) ->
	
		@preload = []
		@config = config
		@layers = [
				title:'background'
				channel:'v.background'
				defaultUrl: @content_url config.forcebackgroundurl, config
				loop: true
				fadeIn: config.backgroundfadein ? 0
				fadeOut: config.backgroundfadeout ? 0				
				insetTop: config.backgroundInsetTop ? 0
				insetBottom: config.backgroundInsetBottom ? 0
				insetLeft: config.backgroundInsetLeft ? 0
				insetRight: config.backgroundInsetRight ? 0
				crossfade: false
			,
				title:'animation'
				channel:'v.animate'
				defaultUrl: @content_url config.noanimationurl, config
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
				channel:'v.mc'
				loop: false
				fadeIn: config.muzicodefadein ? 0
				fadeOut: config.muzicodefadeout ? 0				
				holdTime: config.muzicodeholdtime ? null
				crossfade: true				
		]
		@add config.forcebackgroundurl
		@add config.noanimationurl
		@add config.no_url
		@add config.defaultmuzicodeurl
		@add config.rain_url
		@add config.snow_url
		@add config.sun_url
		@add config.storm_url
		@add config.wind_url

	content_url: (url, config) ->
		if url? and config.contenturi? and (url.indexOf ':') < 0 and (url.substring 0,1) != '/'
			return config.contenturi+url
		else
		return url

	get: ->
		{
			title: @title
			generated: (new Date()).toISOString()
			preload: @preload
			layers: @layers
		}

	add: (url) ->
		url = @content_url url, @config
		if url? and (@preload.indexOf url)<0
			@preload.push url

module.exports.generator = (title, config) ->
	new Generator(title, config)

module.exports.BACKGROUND = 'v.background'
module.exports.ANIMATION = 'v.animation'
module.exports.WEATHER = 'v.weather'
module.exports.MUZICODE = 'v.muzicode'
