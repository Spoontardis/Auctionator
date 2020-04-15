AuctionatorMagicButtonUndercutFrameMixin = {}

local UNDERCUT_EVENTS = {
  "AUCTION_HOUSE_SHOW",
  "OWNED_AUCTIONS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "ITEM_SEARCH_RESULTS_UPDATED",
  "AUCTION_CANCELED",
}

MAGIC_BUTTON_L_UNDERCUT_LOADED = "Auction cancelling loaded. Click once more please :)"
MAGIC_BUTTON_L_NOT_FIRST = "You aren't first. Click again to cancel %s"
MAGIC_BUTTON_L_OWNED_TOP = "You own the top auction for %s. Skipping"
MAGIC_BUTTON_L_SEARCH_RESTART = "Click again to restart undercut search"

function AuctionatorMagicButtonUndercutFrameMixin:OnLoad()
  self:Reset()
  Auctionator.Utilities.Message(MAGIC_BUTTON_L_UNDERCUT_LOADED)
  FrameUtil.RegisterFrameForEvents(self, UNDERCUT_EVENTS)
  C_AuctionHouse.QueryOwnedAuctions({})
end

function AuctionatorMagicButtonUndercutFrameMixin:OnEvent(event, ...)
  print(event)
  if event == "AUCTION_HOUSE_SHOW" or 
     not self:AuctionsTabShown() then
    self:Reset()

  elseif event == "OWNED_AUCTIONS_UPDATED" then
    self:UpdateCurrentAuction()

  elseif event == "AUCTION_CANCELED" then
    Auctionator.Utilities.Message(MAGIC_BUTTON_L_SEARCH_RESTART)

  elseif self.currentAuction and self.currentAuction.status == 1 then
    self:SkipAuction()

  elseif self.searchWaiting then
    self:ProcessSearchResults(...)
  end
end

function AuctionatorMagicButtonUndercutFrameMixin:ProcessSearchResults(...)
  local resultInfo

  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.currentAuction.itemKey)
  if itemKeyInfo.isCommodity then
    resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(self.currentAuction.itemKey.itemID, 1)
  else
    resultInfo = C_AuctionHouse.GetItemSearchResultInfo(self.currentAuction.itemKey, 1)
  end

  if not resultInfo then
    return
  end
  
  self.searchWaiting = false

  if resultInfo.owners[1] ~= "player" then
    self.isUndercut = true
    Auctionator.Utilities.Message(MAGIC_BUTTON_L_NOT_FIRST:format(itemKeyInfo.itemName))
  else
    Auctionator.Utilities.Message(MAGIC_BUTTON_L_OWNED_TOP:format(itemKeyInfo.itemName))
    self:SkipAuction()
  end
end

function AuctionatorMagicButtonUndercutFrameMixin:AuctionsTabShown()
  return AuctionHouseFrame.displayMode == AuctionHouseFrameDisplayMode.Auctions
end

function AuctionatorMagicButtonUndercutFrameMixin:ButtonPress()
  if self.currentAuction and self.isUndercut then
    Auctionator.Utilities.Message("Cancelling ID " .. self.currentAuction.auctionID)
    C_AuctionHouse.CancelAuction(self.currentAuction.auctionID)
    self.toCancel = nil
    self.searchWaiting = false
  else
    self:UpdateCurrentAuction()
    self:SearchForUndercuts()
  end
end

function AuctionatorMagicButtonUndercutFrameMixin:SearchForUndercuts()
  self.isUndercut = false
  if self.currentAuction then
    print("search")
    self.searchWaiting = true
    C_AuctionHouse.SendSearchQuery(self.currentAuction.itemKey, {{sortOrder = 4, reverseSort = false}}, true)
  end
end

function AuctionatorMagicButtonUndercutFrameMixin:CancelNow()
  C_AuctionHouse.CancelAuction(self.currentAuction.auctionID)
  self.currentAuction = nil
end

function AuctionatorMagicButtonUndercutFrameMixin:UpdateCurrentAuction()
  self.isUndercut = false
  self.currentAuction = C_AuctionHouse.GetOwnedAuctionInfo(self.auctionIndex)
  print(self.currentAuction)
  if not self.currentAuction then
    Auctionator.Utilities.Message("No more to cancel")
    self:Reset()
  end
end

function AuctionatorMagicButtonUndercutFrameMixin:SkipAuction()
  self.auctionIndex = self.auctionIndex + 1
  self:UpdateCurrentAuction()
  self:SearchForUndercuts()
end

function AuctionatorMagicButtonUndercutFrameMixin:Reset()
  self.searchWaiting = false
  self.isUndercut = false
  self.currentAuction = nil
  self.auctionIndex = 1
end
