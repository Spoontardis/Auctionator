Auctionator.Search.FilterProcessorMixin = {}

-- Derive
function Auctionator.Search.FilterProcessorMixin:Init(browseResult, filter)
  self.browseResult = browseResult
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
