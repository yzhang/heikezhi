#= require vendor/zepto
#= require vendor/zepto.scroll
#= require vendor/underscore
#= require vendor/backbone

#= require models/article
#= require collections/articles

#= require routers/router

#= require views/article_item_view
#= require views/article_list_view
#= require views/article_view

class App
  constructor: ->
    @articles = new Articles()
    @router   = new Router()

    @articleListView = new ArticleListView(collection: @articles)
    @articles.on 'reset', =>
      @articleListView.render()
      Backbone.history.start(pushState: true)

  start: ->
    @articles.fetch({reset:true})

$ ->
  window.app = new App()
  app.start()
