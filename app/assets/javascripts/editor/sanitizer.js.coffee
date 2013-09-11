@HKZ.Editor::initSanitizer = ->
  @sanitizer = new Sanitize
    elements: ['a', 'b', 'p', 'strike', 'h3', 'img', 'pre', 'blockquote', 'code', 'ul', 'ol', 'li','iframe', 'object', 'param', 'embed', 'audio', 'source'],
    attributes: 
      a: ['href', 'title']
      img: ['src', 'width']
      object: ['width', 'height']
      iframe: ['src', 'width', 'height', 'frameborder', 'webkitallowfullscreen', 'mozallowfullscreen', 'allowfullscreen']
      param:  ['name', 'value']
      embed:  ['width', 'height', 'allowfullscreen', 'allowscriptaccess', 'quality', 'src', 'type']
      audio:  ['controls', 'autobuffer']
      source: ['src', 'type']
    protocols:
      a: 
        href: ['http', 'https', 'mailto']
  
  @editor.bind 'paste', (e) =>
    top = @editor.scrollTop()
    @storeRange()

    if @pre().length
      @pre().after("<textarea class='paste' style='display:block;position:absolute;top:-9999px;left:-9999px;'></textarea>")
      $(".paste").focus()

      setTimeout =>
        e = document.createElement('div')
        t = $(".paste").val()
        t = $(e).text(t).html()
        $(".paste").remove()
        @restoreRange()
        document.execCommand('inserthtml', false, $.trim(t))
        @editor.scrollTop(top)
      , 0

    else
      # if @isFirefox()
      #   $(@container()).closest("p,blockquote,h3,ul,ol").after("<div class='paste' style='display:block;position:absolute;top:-9999px;left:-9999px;'> </div>")
      # else
      $(@container()).closest("p,blockquote,h3,ul,ol").after("<p class='paste' style='display:block;position:absolute;top:-9999px;left:-9999px;'> </p>")
      u = $(".paste")[0].childNodes[0]
      @setCaret(u)

      setTimeout =>
        clean = @sanitizer.clean_node($(".paste")[0])
        e = document.createElement('div')
        e.appendChild(clean)
        $(".paste").remove()
        @restoreRange()
        @editor.scrollTop(top)
        
        $(e).children().each (i, n) ->
          if !$(n).closest("p,blockquote,h3,ul,ol,pre,iframe,object,audio").length
            $(n).wrap('p')

        if @quote().length
          document.execCommand('inserthtml', false, $.trim($(e).html()))
        else if @p().length
          @p().append("&nbsp;") unless @p().text().length
          document.execCommand('inserthtml', false, $.trim($(e).html()))
        else
          document.execCommand('inserthtml', false, $.trim($(e).text().html()))

        top = $(@container()).closest("p,blockquote,h3,ul,ol.pre").offset().top - 190
        if top > @editor.height()
          @editor.scrollTop(@editor.scrollTop() + top - @editor.height() + 190)
      , 0
