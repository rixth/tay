defaultOptions =
  boolean_option: true
  string_option: "@rx"
  select_option: "2"
  radio_option: "b"

extendObject = (dest, srcs...) ->
  for src in srcs
    for name in Object.getOwnPropertyNames(src) when name not in dest
      dest[name] = src[name]
  dest

options = extendObject {}, defaultOptions, JSON.parse(localStorage.getItem('options') || "{}")

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  return unless /^options\./.test(request.method)

  switch request.method
    when "options.getAll"
      sendResponse options
    when "options.setMany"
      extendObject options, request.options
      localStorage.setItem 'options', JSON.stringify(options)
    when "options.setAll"
      options = request.options
      localStorage.setItem 'options', JSON.stringify(options)