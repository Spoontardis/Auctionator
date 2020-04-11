Auctionator.Search.FilterProcessorMixin = {}

function Auctionator.Search.FilterProcessorMixin:Init(testItem, filter)
  self.testItem = testItem
  self.testItem:AddWaiting()
  self.browseResult = testItem.browseResult
  self.filter = filter
  self:Update()
end

-- Derive
function Auctionator.Search.FilterProcessorMixin:OnFilterEventReceived(eventName, ...)
end

-- Derive
function Auctionator.Search.FilterProcessorMixin:Update()
end

-- Derive
function Auctionator.Search.FilterProcessorMixin:IsComplete()
end

-- Derive
function Auctionator.Search.FilterProcessorMixin:GetResult()
end
