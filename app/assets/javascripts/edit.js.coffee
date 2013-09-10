#= require jquery
#= require jquery_ujs

#= require editor/sanitize
#= require editor/base
#= require editor/sanitizer
#= require editor/embedly
#= require editor/uploader
#= require editor/ajax
#= require editor/save

#= require_self

$ ->
  $(document).ajaxError ->
    $("aside .spinner").hide()
    $("aside .percent").hide()

    HKZ.Editor.Queue.queue([])

  $(document).ajaxStart ->
    $("aside .spinner").show()
    $("aside .percent").show()

  $(document).ajaxSuccess ->
    $("aside .icon-save").show()
    $("aside .error").hide()
    $("aside .icon-spinner").hide()
    $("aside .percent").hide()
    $("aside .success").show()
    $("aside .save").hide()

  
  new window.HKZ.Editor('article', '.menu', 'input.image', "input.title", "input.permalink")
