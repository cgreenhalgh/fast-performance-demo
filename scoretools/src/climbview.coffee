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
		video = 
				title:'video'
				channel:'v.video'
				loop: false
				fadeIn: 0
				fadeOut: 0
				crossfade: false
				insetTop: config.videoInsetTop ? 0
				insetBottom: config.videoInsetBottom ? 0
				insetLeft: config.videoInsetLeft ? 0
				insetRight: config.videoInsetRight ? 0
				cropTop: config.videoCropTop ? 0
				cropBottom: config.videoCropBottom ? 0
				cropLeft: config.videoCropLeft ? 0
				cropRight: config.videoCropRight ? 0
		if config.videourl?
			video.defaultUrl = config.videourl
			layer = config.videolayer ? 0
			if layer>@layers.length
				layer = @layers.length
			else if layer<0
				layer = 0
			@layers.splice layer,0,video

		@add config.forcebackgroundurl
		@add config.videourl
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
