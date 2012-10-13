define ["underscore", "backbone"], (_, Backbone) ->

  class TodoModel extends Backbone.Model

    # Default attributes for the todo
    # and ensure that each todo created has `title` and `completed` keys.
    defaults:
    	title: ""
    	completed: false

    # Toggle the `completed` state of this todo item.
    toggle: ->
    	@save completed: not @get("completed")
