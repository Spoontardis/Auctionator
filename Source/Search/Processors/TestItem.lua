Auctionator.Search.Processors.TestItemMixin = {}

function Auctionator.Search.Processors.TestItemMixin:Init(browseResult)
  self.browseResult = browseResult
  self.waiting = 0
  self.result = true
end

-- Notify this item that it has 1 more processor's filter to wait for
function Auctionator.Search.Processors.TestItemMixin:AddWaiting()
  self.waiting = self.waiting + 1
end

-- Combine a finished filter test with previous test results
function Auctionator.Search.Processors.TestItemMixin:MergeResult(result)
  self.result = result and self.result
  self.waiting = self.waiting - 1
end

-- Have the results from every filter test been "merged"
function Auctionator.Search.Processors.TestItemMixin:IsReady()
  return self.waiting <= 0
end
