Auctionator.Search.Processors.TestItemMixin = {}

function Auctionator.Search.Processors.TestItemMixin:Init(browseResult)
  self.browseResult = browseResult
  self.waiting = 0
  self.result = true
end

function Auctionator.Search.Processors.TestItemMixin:AddWaiting()
  self.waiting = self.waiting + 1
end

function Auctionator.Search.Processors.TestItemMixin:MergeResult(result)
  self.result = result and self.result
  self.waiting = self.waiting - 1
end

function Auctionator.Search.Processors.TestItemMixin:IsReady()
  return self.waiting <= 0
end
