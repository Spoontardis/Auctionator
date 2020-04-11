Auctionator.Search.ExactMixin = CreateFromMixins(Auctionator.Search.FilterProcessorMixin)

function Auctionator.Search.ExactMixin:OnFilterEventReceived(eventName, itemID)
  if eventName == "ITEM_KEY_ITEM_INFO_RECEIVED" and
     self.browseResult.itemKey.itemID == itemID then
    self:Update()
  end
end

function Auctionator.Search.ExactMixin:Update()
  if not self:IsComplete() then
    Auctionator.Debug.Message("Auctionator.Search.ExactMixin:Update() key", self.browseResult.itemKey)
    local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.browseResult.itemKey)
    if itemKeyInfo ~= nil then
      self.stringName = itemKeyInfo.itemName
    end
  end
end

function Auctionator.Search.ExactMixin:IsComplete()
  return self:FilterMissing() or (self.stringName ~= nil)
end

function Auctionator.Search.ExactMixin:GetResult()
  return self:FilterMissing() or self:ExactMatchCheck()
end

function Auctionator.Search.ExactMixin:ExactMatchCheck()
  return string.lower(self.stringName) == string.lower(self.filter)
end

function Auctionator.Search.ExactMixin:FilterMissing()
  return self.filter == nil
end
