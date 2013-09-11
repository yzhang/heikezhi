@HKZ.Editor::save = ->
  @saveImages()
  return unless @dirty && !HKZ.Editor.Queue.queue().length
  
  data  = new FormData()
  data.append("title", @title.val())
  data.append("permalink", @permalink.val())
  
  content = @sanitizer.clean_node(@editor[0])
  container = document.createElement('div')
  container.appendChild(content)

  clean = $(container).html()
  clean = clean.replace(/^[\s\r\n]*/, '')
  clean = clean.replace(/[\s\r\n]*$/, '')
  
  if @last_saved_content == clean
    @dirty = false
    return
  else
    @last_saved_content = clean

  data.append("content", clean)

  @ajax(
    url: $("#article-form").attr('action')
    type: 'put'
    data: data
    cache: false
    contentType: false
    processData: false
  ).done =>
    @dirty = false

@HKZ.Editor::publish = ->
  @ajax(
    url: $("a.publish").attr('href')
    type: 'put'
  ).done =>
    $("aside .status").text('published')
    $("aside .publish").remove()

@HKZ.Editor::saveImages = ->
  @editor.find('img').each (i, n) =>
    @uploadImage($(n).attr('id')) if $(n).data('uploaded') == false

@HKZ.Editor::initAutoSave = ->
  @title.change => 
    @dirty = true
    @save()
  @permalink.change =>
    @dirty = true
    @save()
  $("aside .save").click  => @save()
  $("aside .publish").click (e) => 
    e.preventDefault()
    e.stopPropagation()
    @publish()
    return false
  setInterval =>
    @save()
  , 5000
