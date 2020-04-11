Auctionator.Search.CraftLevelMixin = CreateFromMixins(Auctionator.Search.FilterProcessorMixin)

function Auctionator.Search.CraftLevelMixin:OnFilterEventReceived(eventName, itemID)
  if (eventName == "EXTRA_BROWSE_INFO_RECEIVED" or
      eventName == "GET_ITEM_INFO_RECEIVED") and
     itemID == self.browseResult.itemKey.itemID then
    self:Update()
  end
end

function Auctionator.Search.CraftLevelMixin:Update()
  if not self:HasFilter() then
    return
  end

  local itemKey = self.browseResult.itemKey

  if self.itemInfo == nil or #self.itemInfo == 0 then
    self.itemInfo = {GetItemInfo(itemKey.itemID)}
  end

  if #self.itemInfo == 0 then
    return
  end

  if #self.itemInfo > 0 and
      self.itemInfo[12] ~= LE_ITEM_CLASS_GEM and
      self.itemInfo[12] ~= LE_ITEM_CLASS_ITEM_ENHANCEMENT and
      self.itemInfo[12] ~= LE_ITEM_CLASS_CONSUMABLE then

    self.wrongItemType = true
    return
  end

  if self.extraInfo == nil then
    self.extraInfo = C_AuctionHouse.GetExtraBrowseInfo(itemKey)
  end
end

function Auctionator.Search.CraftLevelMixin:IsComplete()
  return (not self:HasFilter()) or self.wrongItemType or (#self.itemInfo > 0 and self.extraInfo ~= nil)
end

function Auctionator.Search.CraftLevelMixin:LevelFilterSatisfied(craftLevel)
  return
    (
      --Minimum item level check
      self.filter.min == nil or
      self.filter.min <= craftLevel
    ) and (
      --Maximum item level check
      self.filter.max == nil or
      self.filter.max >= craftLevel
    )
end

function Auctionator.Search.CraftLevelMixin:GetResult()
  return not self:HasFilter() or
    (not self.wrongItemType and self:LevelFilterSatisfied(self.extraInfo))
end
function Auctionator.Search.CraftLevelMixin:HasFilter()
  return self.filter.min ~= nil or self.filter.max ~= nil
end
