class exports.PerspectiveView 
	animationCurve = "spring(120, 20, 0, 0.07)"
	activated = false
	rotateObject = null
	initialRotation = 0

	allLayers = null

	togglePerspective: (verticalSeparation = 40, temporalOpacity = 0.8) ->
		allLayers = Framer.CurrentContext.getLayers()

		rotateObject = if Framer.Device.deviceType isnt "fullscreen" then Framer.Device.phone else Framer.Device.screen
		@_eventsOn() 

		if not activated and not @_childrenAnimating(Framer.Device.screen.children)
			activated = true
			Framer.Device.screen.clip = false

			@_setAllLayersAsChildrenOf(Framer.Device.screen)

			rotateObject.originalProps = rotateObject.props
			rotateObject.animate
				properties:
					rotationZ: 45
					rotationX: 45
					scaleY: 0.86062
					y: verticalSeparation * (allLayers.length / 3.4)
				curve: animationCurve

			for layer in Framer.Device.screen.children
				layer.originalProps = layer.props

				layer.animate
					properties:
						z: verticalSeparation * (layer.index - 1)
						opacity: temporalOpacity
					delay: (allLayers.length - layer.index) / allLayers.length
					curve: animationCurve

		else if activated and not @_childrenAnimating(Framer.Device.screen.children)
			activated = false
			@_eventsOff()

			rotationNegative = rotateObject.rotationZ < 0

			if Math.abs(rotateObject.rotationZ) > 180
				rotateObject.originalProps.rotationZ = if rotationNegative then -360 else 360
			else
				rotateObject.originalProps.rotationZ = if rotationNegative then -0 else 0

			rotateObject.animate
				properties:
					rotationZ: rotateObject.originalProps.rotationZ
					rotationX: rotateObject.originalProps.rotationX
					scaleY: rotateObject.originalProps.scaleY
					y: rotateObject.originalProps.y 
				curve: animationCurve

			for layer in Framer.Device.screen.children when Framer.Device.screen.children.indexOf(layer) isnt 0
				layer.animate
					properties: layer.originalProps
					curve: animationCurve

			rotateObject.once Events.AnimationEnd, ->
				Framer.Device.screen.clip = true
				rotateObject.rotationZ = 0
				layer.parent = null for layer in Framer.Device.screen.children when Framer.Device.screen.children.indexOf(layer) isnt 0

	_setAllLayersAsChildrenOf: (parent) ->
		for layer in allLayers when layer.parent is null
			parent.addSubLayer(layer)

	_childrenAnimating: (layersArray) ->
		_.some layersArray, (layer) -> layer.isAnimating

	### EVENTS ###

	_panStart: ->
		initialRotation = rotateObject.rotationZ

	_pan: (e) ->
		rotateObject.rotationZ = initialRotation - ((event.touchCenterX - event.startX) / 4)

	_panEnd: ->
		rotateObject.rotationZ = rotateObject.rotationZ % 360

	_eventsOn: ->
		if rotateObject is Framer.Device.screen
			rotateObject.animate
				properties:
					backgroundColor: "rgba(128, 128, 128, 0.2)"

		rotateObject.on(Events.PanStart, @_panStart)
		rotateObject.on(Events.Pan, @_pan)
		rotateObject.on(Events.PanEnd, @_panEnd)

	_eventsOff: ->
		if rotateObject is Framer.Device.screen
			rotateObject.animate
				properties:
					backgroundColor: "transparent"

		rotateObject.off(Events.PanStart, @_panStart)
		rotateObject.off(Events.Pan, @_pan)
		rotateObject.off(Events.PanEnd, @_panEnd)