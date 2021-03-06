local SHOPPING_LIST_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "minPrice" },
    headerText = AUCTIONATOR_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minPrice" },
    width = 140
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_RESULTS_NAME_COLUMN,
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "totalQuantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "totalQuantity" },
    width = 70
  }
}

local ITEM_KEY_EVENT = "ITEM_KEY_ITEM_INFO_RECEIVED"

ShoppingListDataProviderMixin = CreateFromMixins(DataProviderMixin)

function ShoppingListDataProviderMixin:OnLoad()
  Auctionator.Debug.Message("ShoppingListDataProviderMixin:OnLoad()")

  self.pendingItemIds = {}

  DataProviderMixin.OnLoad(self)

  self:GetParent():Register( self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
    Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate
  })

  self:SetOnEntryProcessedCallback(function(entry)
    self:FetchItemKey(entry)
  end)
end

function ShoppingListDataProviderMixin:OnEvent(event, ...)
  if event == ITEM_KEY_EVENT then
    local itemId = ...

    for _, entry in ipairs(self.results) do
      if entry.itemKey.itemID == itemId then
        self:FetchItemKey(entry)
      end
    end
  end
end

function ShoppingListDataProviderMixin:EventUpdate(eventName, eventData)
  Auctionator.Debug.Message(eventName, eventData)

  if eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Reset()
    if eventData ~= 0 then
      self.onSearchStarted()
    end
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:AppendEntries(eventData, true)
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate then
    self:AppendEntries(eventData)
  end
end

function ShoppingListDataProviderMixin:FetchItemKey(rowEntry)
  local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(rowEntry.itemKey)

  if not itemKeyInfo then
    self:RegisterEvent(ITEM_KEY_EVENT)

    table.insert(self.pendingItemIds, rowEntry.itemKey.itemID)
    rowEntry.itemName = ""

    return
  end

  for index, pendingId in ipairs(self.pendingItemIds) do
    if pendingId == rowEntry.itemKey.itemID then
      table.remove(self.pendingItemIds, index)
    end
  end

  if #self.pendingItemIds == 0 then
    self:UnregisterEvent(ITEM_KEY_EVENT)
  end

  local text = AuctionHouseUtil.GetItemDisplayTextFromItemKey(rowEntry.itemKey, itemKeyInfo, false)

  rowEntry.itemName = text
  rowEntry.name = Auctionator.Utilities.RemoveTextColor(text)
  rowEntry.iconTexture = itemKeyInfo.iconFileID
  rowEntry.noneAvailable = rowEntry.totalQuantity == 0

  self.onUpdate(self.results)
end

function ShoppingListDataProviderMixin:UniqueKey(entry)
    return
      entry.itemKey.itemID .. " " ..
      entry.itemKey.itemSuffix .. " " ..
      entry.itemKey.itemLevel .. " " ..
      entry.itemKey.battlePetSpeciesID
end

local COMPARATORS = {
  minPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  totalQuantity = Auctionator.Utilities.NumberComparator
}

function ShoppingListDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function ShoppingListDataProviderMixin:GetTableLayout()
  return SHOPPING_LIST_TABLE_LAYOUT
end

function ShoppingListDataProviderMixin:GetRowTemplate()
  return "ShoppingListResultsRowTemplate"
end
