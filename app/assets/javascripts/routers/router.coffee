@Router = Backbone.Router.extend
  routes:
    '*permalink': 'showArticle'

  showArticle: (permalink) ->
    article = app.articles.findWhere({permalink:"#{permalink}"})
    article ||= app.articles.first()
    article.trigger("active") if article

    if @prev
      @prev.trigger("deactive") 
      (new ArticleView({model: article})).render()

    $("aside").scrollTo
      endY: $(".active")[0].offsetTop - 200
      duration: 500

    @prev = article
