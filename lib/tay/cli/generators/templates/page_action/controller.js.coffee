chrome.tabs.onUpdated.addListener (tabId, changed, info) ->
  chrome.pageAction.show tabId

chrome.pageAction.onClicked.addListener (tab) ->
  alert "The page action was clicked on tab: #{tab.title}"