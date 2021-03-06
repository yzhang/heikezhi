@HKZ.Editor::initUploader = ->
  @fileInput.change (e) =>
    pic = e.target.files[0]
    @insertImage(pic)
  
  @editor.bind 'drop', (e) =>
    e.stopPropagation()
    e.preventDefault()

    dt = e.originalEvent.dataTransfer
    imageId = dt.getData("Text")
    
    if imageId
      @setCaret(e.originalEvent.target)
      img = $("##{imageId}")
      document.execCommand('inserthtml', false, "<img src='#{img.data('large')}' width='#{img.data('width')}'>")
    else
      pic = e.originalEvent.dataTransfer.files[0]
      @insertImage(pic)

  $("aside").on 'dragstart', "#images-list img", (e) ->
    e.originalEvent.dataTransfer.setData("Text", $(this).attr('id'));

  $("aside").on "click", "#images-list img", (e) =>
    e.preventDefault()
    return unless @range()
    img = $(e.target)
    document.execCommand('inserthtml', false, "<img src='#{img.data('large')}' width='#{img.data('width')}'>")

@HKZ.Editor::uploadImage = (imageId) ->
  data  = new FormData()
  data.append("image[image_data]", $("img#" + imageId).attr('src'))
  $("img#" + imageId).attr('data-uploaded', false)
  

  @ajax(
    type: 'POST'
    url:  '/images'
    data: data
    cache: false
    contentType: false
    processData: false
    xhr: ->
      myXhr = $.ajaxSettings.xhr()
      if myXhr.upload
        myXhr.upload.addEventListener 'progress', (e) ->
          progress = Math.floor(100*e.loaded / e.total)
          if progress == 100
            $("aside .percent").text("...")
          else
            $("aside .percent").text(progress + '%')
        , false
      return myXhr
  ).done((image) =>
    $("img#" + imageId).attr('src', image.src)
    $("img#" + imageId).attr("width", image.width)
    $("img#" + imageId).attr('data-uploaded', true)
    @dirty = true
    $("#images-list").prepend("<li><img id='image#{image.id}' src='#{image.thumb}' data-large='#{image.src}' data-width='#{image.width}'></li>")
  )

@HKZ.Editor::insertImage = (pic) ->
  return if !pic

  typeReg = /^image\/*/
  if !typeReg.test(pic.type)
    $(".upload p").text("unsupported file type")
    return

  if pic.size > 2048000
    alert("File size can't exceed 2M")
    return

  reader = new FileReader()
  reader.onload = (e) =>
    imageId = (new Date()).valueOf()

    @setCaret(@lastP()[0]) unless @range()

    document.execCommand('inserthtml', false, "<img id='" + imageId + "' src='" + e.target.result + "'>")
    @p().after('<p></p>') unless @p().next().length

    @uploadImage(imageId)

  reader.readAsDataURL(pic)

