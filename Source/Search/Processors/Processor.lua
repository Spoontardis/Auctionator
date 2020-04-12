Auctionator.Search.Processors.ProcessorMixin = {}

function Auctionator.Search.Processors.ProcessorMixin:Init(testItem, filter)
  self.testItem = testItem
  self.testItem:AddWaiting()
  self.browseResult = testItem.browseResult
  self.filter = filter
  self:Update()
end

-- Derive
function Auctionator.Search.Processors.ProcessorMixin:OnFilterEventReceived(eventName, ...)
end

-- Derive
function Auctionator.Search.Processors.ProcessorMixin:Update()
end

-- Derive
function Auctionator.Search.Processors.ProcessorMixin:IsComplete()
end

-- Derive
function Auctionator.Search.Processors.ProcessorMixin:GetResult()
end
