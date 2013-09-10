@ArticleItemView = Backbone.View.extend
  tagName: 'li'

  template: _.template($('#article-item').html())
  
  events:
    'click a': 'showArticle'

  initialize: ->
    @model.on('active', @activate, @)
    @model.on('deactive', @deactivate, @)

  render: ->
    @$el.html(@template(@model.toJSON()))

  showArticle: (e) ->
    return true if window.location.pathname == '/' && $(window).width() <= 640

    e.preventDefault()
    e.stopPropagation()
    app.router.navigate(@$("a").attr('href'), {trigger:true})
    return false

  activate: ->
    @$el.addClass('active')
  
  deactivate: ->
    @$el.removeClass('active')
