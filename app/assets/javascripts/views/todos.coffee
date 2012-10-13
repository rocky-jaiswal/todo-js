define ["jquery", "underscore", "backbone", "text!templates/todos.html", "common"], ($, _, Backbone, todosTemplate, Common) ->
  
  class TodoView extends Backbone.View

    tagName: "li"
    template: _.template(todosTemplate)
    
    # The DOM events specific to an item.
    events:
      "click .toggle": "togglecompleted"
      "dblclick label": "edit"
      "click .destroy": "clear"
      "keypress .edit": "updateOnEnter"
      "blur .edit": "close"

    # The TodoView listens for changes to its model, re-rendering. Since there's
    # a one-to-one correspondence between a **Todo** and a **TodoView** in this
    # app, we set a direct reference on the model for convenience.
    initialize: ->
      @model.on "change", @render, this
      @model.on "destroy", @remove, this
      @model.on "visible", @toggleVisible, this

    # Re-render the titles of the todo item.
    render: ->
      @$el.html @template(@model.toJSON())
      @$el.toggleClass "completed", @model.get("completed")
      @toggleVisible()
      @input = @$(".edit")
      this

    toggleVisible: ->
      @$el.toggleClass "hidden", @isHidden()

    isHidden: ->
      isCompleted = @model.get("completed")
      # hidden cases only
      (not isCompleted and Common.TodoFilter is "completed") or (isCompleted and Common.TodoFilter is "active")

    # Toggle the `"completed"` state of the model.
    togglecompleted: ->
      @model.toggle()

    # Switch this view into `"editing"` mode, displaying the input field.
    edit: ->
      @$el.addClass "editing"
      @input.focus()

    # Close the `"editing"` mode, saving changes to the todo.
    close: ->
      value = @input.val().trim()
      if value
        @model.save title: value
      else
        @clear()
      @$el.removeClass "editing"

    # If you hit `enter`, we're through editing the item.
    updateOnEnter: (e) ->
      @close()  if e.keyCode is Common.ENTER_KEY

    # Remove the item, destroy the model from *localStorage* and delete its view.
    clear: ->
      @model.destroy()
