@ArticleView = Backbone.View.extend
  el: '#content'

  render: ->
    @$el.html('')
    $("#spinner").show()

    $("a.edit").attr('href', @model.get('permalink').replace(/.*?\//, "/edit/"))
    $("a.delete").attr('href', @model.get('permalink').replace(/.*?\//, "/delete/"))

    $.ajax
      type: 'get'
      url: "/#{@model.get('permalink')}"
      data: 'bare=1'
      success: (html) =>
        @$el.html(html)
        $("#spinner").hide()
