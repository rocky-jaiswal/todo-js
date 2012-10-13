define ["jquery", "underscore", "backbone", "collections/todos", "views/todos", "text!templates/stats.html", "common"], ($, _, Backbone, Todos, TodoView, statsTemplate, Common) ->
  
  class AppView extends Backbone.View
    
    # Instead of generating a new element, bind to the existing skeleton of
    # the App already present in the HTML.
    el: "#todoapp"
    
    # Compile our stats template
    template: _.template(statsTemplate)
    
    # Delegated events for creating new items, and clearing completed ones.
    events:
      "keypress #new-todo": "createOnEnter"
      "click #clear-completed": "clearCompleted"
      "click #toggle-all": "toggleAllComplete"

    # At initialization we bind to the relevant events on the `Todos`
    # collection, when items are added or changed. Kick things off by
    # loading any preexisting todos that might be saved in *localStorage*.
    initialize: ->
      @input = @$("#new-todo")
      @allCheckbox = @$("#toggle-all")[0]
      @$footer = @$("#footer")
      @$main = @$("#main")
      Todos.on "add", @addOne, this
      Todos.on "reset", @addAll, this
      Todos.on "change:completed", @filterOne, this
      Todos.on "filter", @filterAll, this
      Todos.on "all", @render, this
      Todos.fetch()
    
    # Re-rendering the App just means refreshing the statistics -- the rest
    # of the app doesn't change.
    render: ->
      completed = Todos.completed().length
      remaining = Todos.remaining().length
      if Todos.length
        @$main.show()
        @$footer.show()
        @$footer.html @template(
          completed: completed
          remaining: remaining
        )
        @$("#filters li a").removeClass("selected").filter("[href=\"#/" + (Common.TodoFilter or "") + "\"]").addClass "selected"
      else
        @$main.hide()
        @$footer.hide()
      @allCheckbox.checked = not remaining

    
    # Add a single todo item to the list by creating a view for it, and
    # appending its element to the `<ul>`.
    addOne: (todo) ->
      view = new TodoView(model: todo)
      $("#todo-list").append view.render().el

    # Add all items in the **Todos** collection at once.
    addAll: ->
      @$("#todo-list").html ""
      Todos.each @addOne, this

    filterOne: (todo) ->
      todo.trigger "visible"

    filterAll: ->
      Todos.each @filterOne, this
    
    # Generate the attributes for a new Todo item.
    newAttributes: ->
      title: @input.val().trim()
      order: Todos.nextOrder()
      completed: false
    
    # If you hit return in the main input field, create new **Todo** model,
    # persisting it to *localStorage*.
    createOnEnter: (e) ->
      return  if e.which isnt Common.ENTER_KEY or not @input.val().trim()
      Todos.create @newAttributes()
      @input.val ""
    
    # Clear all completed todo items, destroying their models.
    clearCompleted: ->
      _.each Todos.completed(), (todo) ->
        todo.destroy()
      false

    toggleAllComplete: ->
      completed = @allCheckbox.checked
      Todos.each (todo) ->
        todo.save completed: completed
