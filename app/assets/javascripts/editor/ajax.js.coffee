Queue = $({})

@HKZ.Editor.Queue = Queue
  
@HKZ.Editor::ajax = (params) ->
  deferred = $.Deferred()
  promise  = deferred.promise()

  Queue.queue   ->
    $.ajax(params)
      .done(deferred.resolve)
      .fail(deferred.reject)
      .always =>
        $(@).dequeue()

  promise
