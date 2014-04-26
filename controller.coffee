class window.Controller
  constructor: (template) ->
    controller = @
    @events or= {}
    @helpers or= {}

    events = {}
    _.each @events, (method, key) ->
      events[key] = controller[method]

    helpers = {}
    _.each @helpers, (method, key) ->
      helpers[key] = ->
        controller[method].call(controller, @)

    _.each @actions, (method, key) ->
      events[key] = (e, template) ->
        e.preventDefault()
        controller[method].call(controller, @, e, template)

    @eventsForTemplate = events
    @helpersForTemplate = helpers
  
    @addTemplate(template) if template

  addTemplate: (template) ->
    controller = @

    template.events(@eventsForTemplate)
    template.helpers(@helpersForTemplate)

    template.rendered = ->
      # Set the first template
      controller.template = @
      # Set all templates
      controller.templates or= []
      controller.templates.push(@)

      controller.didRender.call(controller, @) if controller.didRender