chrome.tabs.onUpdated.addListener(function (tabId, changed, info) {
  chrome.pageAction.show(tabId);
});

chrome.pageAction.onClicked.addListener(function (tab) {
  alert('The page action was clicked on tab: ' + tab.title)
});