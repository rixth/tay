document.addEventListener('DOMContentLoaded', function () {
  var el = document.createElement('p');
  el.appendChild(document.createTextNode('The time is now: ' + (new Date()).toTimeString()));
  document.body.appendChild(el);
}, false);