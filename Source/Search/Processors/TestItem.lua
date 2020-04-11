Auctionator.Search.TestItemMixin = {}

function Auctionator.Search.TestItemMixin:Init(browseResult)
  self.browseResult = browseResult
  self.waiting = 0
  self.result = true
end

function Auctionator.Search.TestItemMixin:AddWaiting()
  self.waiting = self.waiting + 1
end

function Auctionator.Search.TestItemMixin:MergeResult(result)
  self.result = result and self.result
  self.waiting = self.waiting - 1
end

function Auctionator.Search.TestItemMixin:IsReady()
  return self.waiting <= 0
end
