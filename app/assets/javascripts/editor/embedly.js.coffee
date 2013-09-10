@HKZ.Editor::initEmbedly = ->
  @embedSanitizer = new Sanitize
    elements: ['iframe', 'object', 'param', 'embed', 'audio', 'source'],
    attributes:
      object: ['width', 'height']
      iframe: ['src', 'width', 'height', 'frameborder', 'webkitallowfullscreen', 'mozallowfullscreen', 'allowfullscreen']
      param:  ['name', 'value']
      embed:  ['width', 'height', 'allowfullscreen', 'allowscriptaccess', 'quality', 'src', 'type']
      audio:  ['controls', 'autobuffer']
      source: ['src', 'type']

  @editor.on 'paste', '.embedly textarea', (e) =>
    e.stopPropagation()

  @editor.on 'click', '.embedly .save', (e) =>
    e.preventDefault()
    e.stopPropagation()
    
    embed = $(".embedly textarea").val()
    
    div = document.createElement('div')
    $(div).html(embed)
    embedClean = @embedSanitizer.clean_node($(div)[0])
    div = document.createElement('div')
    $(div).append(embedClean)
    $(div).append("<p></p>") unless $(".embedly").next().length
    $(".embedly").replaceWith($(div).html())
    @editor.attr('contenteditable', true)

  
  @editor.on 'click', '.embedly .cancel', (e) =>
    $(".embedly").remove()
    @editor.attr('contenteditable', true)
    #document.execCommand('formatBlock', false, 'p')
