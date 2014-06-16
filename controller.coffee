window.Grid or= {}

moduleKeywords = ['included', 'extended']

assert = Grid.Util.assert

class window.Controller
  constructor: (template) ->

  $: (selector) ->
    @el.find(selector) if @el
    # TODO: Log an error if this failed


  @template: (name) ->
    setTimeout =>
      constructor = @
      templateConstructor = Template[name]
      controllerPrototype = @prototype

      events = {}

      # Collect events
      _.each controllerPrototype.events, (method, key) ->
        events[key] = (e, template) ->
          controller = template.controller
          controller[method](e, template)

      # Collect actions
      _(controllerPrototype.actions).each (method, key) ->
        events[key] = (e, template) ->
          e.preventDefault()
          controller = template.controller
          controller[method].call(controller, @, e, template)

      templateConstructor.events(events)

      templateConstructor.created = ->
        template = this
        controller = new constructor
        # controller._id = "#{name} #{Math.random()}"
        
        template.controller = controller
        controller.template = template

        helpers = {}

        addHelper = (key, fun) ->
          helpers[key] = ->
            args = (a for a in arguments)
            args.unshift(@)
            fun.apply(controller, args)

        addHelperByKey = (method, key) ->
          addHelper(key, controller[method])

        # Collect helpers
        if _(controller.helpers).isArray()
          _(controller.helpers).each (method) ->
            addHelperByKey(method, method)
        else
          _(controller.helpers).each (method, key) ->
            addHelperByKey(method, key)

        # Helpers from class methods
        ignored = ['__super__', 'template', 'include', 'extend']
        for method, fun of constructor
          addHelper(method, fun) unless method in ignored

        templateConstructor.helpers(helpers)

        controller.created.call(controller, @) if controller.created
      
      templateConstructor.rendered = ->
        template = @
        controller = template.controller
        controller.$el = $(template.firstNode)
        controller.el = controller.$el
        controller.data = template.data
        controller.rendered.call(controller, @) if controller.rendered

      templateConstructor.destroyed = ->
        template = @
        controller = template.controller
        # controller.$el = null
        # controller.el = null
        controller.destroyed.call(controller, @) if controller.destroyed

    , 0

  @include: (obj) ->
    throw new Error('include(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(this)
    this

  @extend: (obj) ->
    throw new Error('extend(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @[key] = value
    obj.extended?.apply(this)
    this
