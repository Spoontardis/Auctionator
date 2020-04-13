-- Used to make blizz API calls to get item information needed to test a
-- filtering condition.
Auctionator.Search.Processors.ProcessorMixin = {}

function Auctionator.Search.Processors.ProcessorMixin:Init(testItem, filter)
  self.testItem = testItem
  self.testItem:AddWaiting()
  self.browseResult = testItem.browseResult
  self.filter = filter
  self:Update()
end

-- Pass any Blizz API events for item information to this. Currently:
-- ITEM_KEY_ITEM_INFO_RECEIVED, ITEM_INFO_RECEIVED, EXTRA_BROWSE_INFO_RECEIVED
function Auctionator.Search.Processors.ProcessorMixin:OnFilterEventReceived(eventName, ...)
end

-- Internal update, only called from processor methods.
function Auctionator.Search.Processors.ProcessorMixin:Update()
end

-- Is all the information needed to test a filter available
function Auctionator.Search.Processors.ProcessorMixin:IsComplete()
  return true
end

-- Return the result of the filter test. Assumes :IsComplete() == true
function Auctionator.Search.Processors.ProcessorMixin:GetResult()
  return true
end
