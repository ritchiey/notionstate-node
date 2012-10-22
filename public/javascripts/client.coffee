$ ->
  $detail = $('detail')
  $outstanding = $('#outstanding')
  serverUrl = $outstanding.data('url')

  # Display the new notion form by default
  $detail.html window.Templates['new_notion_form']
    action: "#{serverUrl}/messages"

  # Intercept form submissions and perform them in
  # the background
  $('#detail').on 'submit', 'form', ->
    target = $(this).attr('action')
    $.post target, $(this).serialize()
    false

  # Display items requiring attention
  socket = io.connect(serverUrl)
  socket.on 'update', (item) ->
    $outstanding.append window.Templates['outstanding_item'](item)
 