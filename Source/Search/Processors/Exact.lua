Auctionator.Search.Processors.ExactMixin = CreateFromMixins(Auctionator.Search.Processors.ProcessorMixin)

function Auctionator.Search.Processors.ExactMixin:OnFilterEventReceived(eventName, itemID)
  if eventName == "ITEM_KEY_ITEM_INFO_RECEIVED" and
     self.browseResult.itemKey.itemID == itemID then
    self:Update()
  end
end

function Auctionator.Search.Processors.ExactMixin:Update()
  if not self:IsComplete() then
    Auctionator.Debug.Message("Auctionator.Search.Processors.ExactMixin:Update() key", self.browseResult.itemKey)
    local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.browseResult.itemKey)
    if itemKeyInfo ~= nil then
      self.stringName = itemKeyInfo.itemName
    end
  end
end

function Auctionator.Search.Processors.ExactMixin:IsComplete()
  return self:FilterMissing() or (self.stringName ~= nil)
end

function Auctionator.Search.Processors.ExactMixin:GetResult()
  return self:FilterMissing() or self:ExactMatchCheck()
end

function Auctionator.Search.Processors.ExactMixin:ExactMatchCheck()
  return string.lower(self.stringName) == string.lower(self.filter)
end

function Auctionator.Search.Processors.ExactMixin:FilterMissing()
  return self.filter == nil
end
