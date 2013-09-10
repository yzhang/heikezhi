@Articles = Backbone.Collection.extend
  model: Article
  url: $("body").data('articles-url')
