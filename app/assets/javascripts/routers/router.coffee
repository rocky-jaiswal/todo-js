define ["jquery", "backbone", "collections/todos", "common"], ($, Backbone, Todos, Common) ->
 
  class Workspace extends Backbone.Router
    routes:
      "*filter": "setFilter"

    setFilter: (param) ->
      # Set the current filter to be used
      Common.TodoFilter = param.trim() or ""
      # Trigger a collection filter event, causing hiding/unhiding
      # of the Todo view items
      Todos.trigger "filter"
