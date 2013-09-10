@HKZ ||= {}
class @HKZ.Editor
  constructor: (selector, menu, fileInput, title, permalink) ->
    @editor    = $(selector)
    @title     = $(title)
    @permalink = $(permalink)
    @fileInput = $(fileInput)
    
    @dirty = false

    @initMenu(menu)
    @initEditor()
    @initSanitizer()
    @initEmbedly()
    @initUploader()
    @initAutoSave()
  
  isFirefox: ->
    navigator.userAgent.toLowerCase().indexOf('firefox') > -1

  range: -> 
    s = window.getSelection()
    return null unless s.type == 'Caret' || s.type == 'Range' || @isFirefox()
    r = s.getRangeAt(0)
    return r if $(r.commonAncestorContainer).closest('article').length
    
  storeRange: ->
    r = @range()
    @storedRange =
      startContainer: r.startContainer
      startOffset:    r.startOffset
      endContainer:   r.endContainer
      endOffset:      r.endOffset

  restoreRange: ->
    s = document.getSelection()
    r = document.createRange()
    if @storedRange
      r.setStart(@storedRange.startContainer,@storedRange.startOffset)
      r.setEnd(@storedRange.endContainer,@storedRange.endOffset)
      s.removeAllRanges()
      s.addRange(r)

  container: ->
    r   = @range()
    r.commonAncestorContainer if r

  pre:    -> $(@container()).closest("pre")
  code:   -> $(@container()).closest("code")
  p:      -> $(@container()).closest("p")
  a:      -> $(@container()).closest("a")
  strike: -> $(@container()).closest("strike")
  b:      -> $(@container()).closest("b")
  quote:  -> $(@container()).closest("blockquote")
  header: -> $(@container()).closest("h3")
  ol:     -> $(@container()).closest("ol")
  ul:     -> $(@container()).closest("ul")
  li:     -> $(@container()).closest("li")

  setCaret: (node) ->
    t=window.getSelection()
    if t.type == 'Caret' || t.type == 'Range'
      n=t.getRangeAt(0)
    else
      n=document.createRange()

    if node.childNodes.length
      l=node.childNodes.length
      n.setStartAfter(node.childNodes[l-1])
      n.setEndAfter(node.childNodes[l-1])
    else
      n.setStartAfter(node)
      n.setEndAfter(node)
    t.removeAllRanges()
    t.addRange(n)

  setSelection: (node) ->
    t=window.getSelection()
    if t.type == 'Caret' || t.type == 'Range'
      n=t.getRangeAt(0)
    else
      n=document.createRange()

    if node.childNodes.length
      l=node.childNodes.length
      n.setStartBefore(node.childNodes[0])
      n.setEndAfter(node.childNodes[l-1])
    else
      n.setStartBefore(node)
      n.setEndAfter(node)
    t.removeAllRanges()
    t.addRange(n)

  updateMenu: ->
    @menus.removeClass('active')

    if @header().length
      @menu.header.addClass('active')
    else if @ol().length
      @menu.ol.addClass('active')
    else if @ul().length
      @menu.ul.addClass('active')
    else if @quote().length
      @menu.quote.addClass('active')
    else if @pre().length
      @menu.code.addClass('active')
    else if @a().length
      @menu.link.addClass('active')
    else if @b().length
      @menu.bold.addClass('active')
    else if @strike().length
      @menu.strike.addClass('active')
  
  # autoScroll: ->
  #   r = @range()
  #   c = @container()
  #   return unless r && c
  #   return unless r.collapsed
  # 
  #   u = document.createElement("span")
  #   $(u).html("&#8203;")
  #   $(u).addClass("caret")
  #   r.insertNode(u)
  # 
  #   top  = $(".caret").offset().top - 190
  #   left = $(".caret").offset().left
  #   $("span.caret").remove()
  #   code = $(c).closest('code')
  #   if code.length
  #     @storeRange()
  #     t = code.text()
  #     code.text(t)
  #     @restoreRange()
  # 
  #   if window.scrollY > top
  #     window.scrollTo(left, top)
  
  newPreLine: (e) ->
    e.preventDefault()

    t = window.getSelection()
    r = t.getRangeAt(0)
    pre = @pre()
    r.deleteContents()
    s = (pre.find("code").contents().last()[0]==r.endContainer)
    o = (r.endContainer.length==r.endOffset)

    newline = document.createTextNode("\n")
    r.insertNode(newline)
    s&&o&&pre.find("code").append(document.createTextNode("\n"))
    
    @setCaret(newline)
  
  newQuoteLine: (e) ->
    return if @p().text().length
    e.preventDefault()
    if @quote().text().length
      @p().remove()
      @quote().after("<p></p>")
      b = @quote()[0]
    else
      b = document.createElement('p')
      b.appendChild(document.createTextNode("\n"))
      @quote().after(b)
      @quote().remove()
      b = b.childNodes[0]

    @setCaret(b)

  newParagraph: ->
    if !$(@container()).closest('p,li,blockquote,pre').length
      document.execCommand('formatBlock', false, 'p')

  del: ->
    nodeName = $(@container()).parent()[0].nodeName
    if nodeName == 'FORM' || nodeName == 'ARTICLE'
      document.execCommand('formatBlock', false, 'p')

  tab: (e) ->
    e.preventDefault()
    document.execCommand('insertText', false, '  ')

  markDirty: ->
    @dirty = true
    $("aside .success").hide()
    $("aside .save").show()

  initEditor: ->
    @editor.height($(window).height() - 216)

    @editor.click (e) =>
      node = $(@container()).parent()[0]

      if node && node.nodeName == 'FORM' && @isFirefox()
        p = document.createElement('p')
        $(p).append(document.createTextNode("\n"))
        @editor.append(p)
        a = $(p).prev()
        $(p).remove()
        if a[0].childNodes.length
          @setCaret(a[0].childNodes[0])
        else
          a.append(document.createTextNode("\n"))
          @setCaret(a[0].childNodes[0])

      @updateMenu()

    @editor.keyup (e) =>
      @newParagraph() if e.which == 13 
      @del()   if e.which == 8
      if @editor.find('br').length
        @storeRange()
        @editor.find('br').remove() 
        @restoreRange()
    
      @updateMenu()
      @markDirty()

    @editor.keydown (e) =>
      @tab(e) if e.which == 9

      if e.which == 13 
        @newPreLine(e) if @pre().length
        @newQuoteLine(e) if @quote().length
    
    @editor.on 'click', 'img', (e) =>
      e.preventDefault()

      @setSelection(e.target)
  
    window.onbeforeunload = =>
      if @dirty
        return "Article unsaved, sure to leave?"
      
  initMenu: (menu) ->
    @menus     = $(menu).find('a')
    @menu =
      bold:    $(menu).find('.bold')
      strike:  $(menu).find('.strike')
      link:    $(menu).find('.link')
      header:  $(menu).find('.header')
      picture: $(menu).find('.picture')
      video:   $(menu).find('.video')
      ul:      $(menu).find('.ul')
      ol:      $(menu).find('.ol')
      quote:   $(menu).find('.quote')
      code:    $(menu).find('.code')

    @menus.click (e) =>
      e.preventDefault()
      e.stopPropagation()
      @markDirty()

    @menu.header.click  (e) => @insertHeader()
    @menu.ul.click      (e) => @insertUL()
    @menu.ol.click      (e) => @insertOL()
    @menu.quote.click   (e) => @insertQuote()
    @menu.code.click    (e) => @insertCode()
    @menu.picture.click (e) => 
      return unless @range()
      @fileInput.click()
    @menu.video.click   (e) => @insertVideo()
    @menu.link.click    (e) => @insertLink()
    @menu.bold.click    (e) => 
      @bold()
    @menu.strike.click  (e) => @setStrike()

  insertHeader: ->
    return unless @range()

    if @p().length
      t = @p().text()
      if t.length == 0
        @p().remove()
      document.execCommand('formatBlock', false, 'h3')


      # @storeRange()
      # if @isFirefox()
      #   @p().replaceWith(@p().html()) if @p().length
      # else
      #   @header().text(@p().text()) if @p().length
      # @restoreRange()

      @menus.removeClass('active')
      @menu.header.addClass('active')
    else if @header().length
      document.execCommand('formatBlock', false, 'p')
      @menu.header.removeClass('active')
  
  insertUL: ->
    return unless @range()
    return if $(@container()).closest("h3, code, blockquote").length

    if @li().length
      html = @li().html()
      if @isFirefox()
        @ul().replaceWith("<p>" + html + "</p>")
      else
        document.execCommand('formatBlock', false, 'p')
        @p().html(@li().html())

      @menu.ul.removeClass('active')
    else if @p().length
      document.execCommand('insertunorderedlist', false, '');
      @storeRange()
      if @isFirefox()
        @p().replaceWith(@p().html()) if @p().length
      else
        @ul().unwrap("p") if @p().length
      @restoreRange()

      @menus.removeClass('active')
      @menu.ul.addClass('active')

  insertOL: ->
    return unless @range()
    return if $(@container()).closest("h3, code, blockquote").length

    if @li().length
      html = @li().html()
      if @isFirefox()
        @ol().replaceWith("<p>" + html + "</p>")
      else
        document.execCommand('formatBlock', false, 'p')
        @p().html(html)

      @menu.ol.removeClass('active')
    else if @p().length 
      document.execCommand('insertorderedlist', false, '');
      @storeRange()
      if @isFirefox()
        @p().replaceWith(@p().html()) if @p().length
      else
        @ol().unwrap("p") if @p().length
      @restoreRange()

      @menus.removeClass('active')
      @menu.ol.addClass('active')

  insertQuote: ->
    return unless @range()
    if @quote().length
      p = @p()
      p.unwrap('blockquote')
      p.append(document.createTextNode("\n")) 

      @setCaret(p[0].childNodes[0])
      @menu.quote.removeClass('active')

    else if @p().length
      p = @p()
      p.after('<p></p>') unless p.next().length
      p.wrap('<blockquote></blockquote>')

      quote = p.closest('blockquote')
      @setCaret(quote[0].childNodes[0])

      @menus.removeClass('active')
      @menu.quote.addClass('active')
  
  insertCode: ->
    return unless @range()
    p = @p()
    if p.length
      text = p.text()
      p.after("<p></p>") unless p.next().length
      p.wrap('<pre><code></code></pre>')

      code = p.closest('code')
      t= p.text()
      code.text($.trim(t))
      code.append(document.createTextNode("\n"))

      @setCaret(code[0].childNodes[0])

      @menus.removeClass('active')
      @menu.code.addClass('active')
    else if @pre().length
      text = @code().text()
      pre =  @pre()
      pre.wrap("<p></p>")
      p   = pre.closest('p')
      p.text(text)
      p.append(document.createTextNode("\n"))

      @setCaret(p[0].childNodes[0])
      @menu.code.removeClass('active')

  insertVideo: ->
    return unless @range()
    return if $(".embedly").length

    block = $(@container()).closest('p,h3,blockquote,pre,ul,ol')
    block.after($("#embedly-template").html())
    block.remove() unless block.text().length

    @editor.attr('contenteditable', false)
    offset = $(".embedly").offset()
    @editor.scrollTop(offset.y-180)
    $(".embedly textarea").focus()

  insertLink: ->
    return unless @range()
    a= @a()
    if a.length
      @setSelection(a[0])
      document.execCommand('unlink', false)
      @menu.link.removeClass('active')
    else if $(@container()).closest('p,li,blockquote,h3').length
      document.execCommand('createlink', false, prompt("url"))
      @menu.link.addClass('active')

  bold: ->
    alert('a')
    return unless @range()
    b= @b()
    if b.length
      u = document.createTextNode(b.text())
      b.replaceWith(u)

      @setCaret(u)
      @menu.bold.removeClass('active')
    else if $(@container()).closest('p,li,blockquote,h3').length
      alert('b')
      document.execCommand('bold', false)
      @menu.bold.addClass('active')
  
  setStrike: ->
    return unless @range()

    s = @strike()
    if s.length
      u = document.createTextNode(s.text())
      s.replaceWith(u)
      @setCaret(u)
      @menu.strike.removeClass('active')
    else if $(@container()).closest('p,li,blockquote,h3').length
      document.execCommand('strikethrough', false)
      @menu.strike.addClass('active')

