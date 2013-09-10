@ArticleListView = Backbone.View.extend
  el: 'aside'

  events:
    "click a.delete": "deleteArticle"
  
  deleteArticle: (e) ->
    e.preventDefault()
    e.stopPropagation()
    link = $(e.target).closest('a')
    href = link.attr('href')
    method = link.data('method')

    return false if !confirm(link.data('confirm'))

    csrf_token = $('meta[name=csrf-token]').attr('content')
    csrf_param = $('meta[name=csrf-param]').attr('content')
    form = $('<form method="post" action="' + href + '"></form>')
    metadata_input = '<input name="_method" value="' + method + '" type="hidden" />'

    if csrf_param != undefined && csrf_token != undefined
      metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />'

    form.hide().append(metadata_input).appendTo('body')
    form.submit()

  renderArticleItem: (article) ->
    view = new ArticleItemView model:article
    view.render()
    @$("#article-list").append(view.el)

  render: ->
    @$("#article-list").html('')
    @collection.each(@renderArticleItem, @)
