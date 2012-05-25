document.addEventListener 'DOMContentLoaded', ->
  el = document.createElement('p');
  currentTime = (new Date()).toTimeString()
  el.appendChild document.createTextNode("The time is now: #{currentTime}")
  document.body.appendChild el
, false