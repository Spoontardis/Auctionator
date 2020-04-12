AuctionatorAdvancedSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
  "ITEM_KEY_ITEM_INFO_RECEIVED",
  "EXTRA_BROWSE_INFO_RECEIVED",
  "GET_ITEM_INFO_RECEIVED",
}

local function ExtractExactSearch(queryString)
  return string.match(queryString, "^\"(.*)\"$")
end

local function GetItemClassFilters(filterKey)
  local lookup = Auctionator.Search.FilterLookup[filterKey]
  if lookup ~= nil then
    return lookup.filter
  else
    return {}
  end
end

local function ParseAdvancedSearch(searchString)

  local parsed = Auctionator.Search.SplitAdvancedSearch(searchString)

  return {
    query = {
      searchString = parsed.queryString,
      minLevel = parsed.minLevel,
      maxLevel = parsed.maxLevel,
      filters = {},
      itemClassFilters = GetItemClassFilters(parsed.filterKey),
      sorts = {},
    },
    extraFilters = {
      itemLevel = {
        min = parsed.minItemLevel,
        max = parsed.maxItemLevel,
      },
      craftLevel = {
        min = parsed.minCraftLevel,
        max = parsed.maxCraftLevel,
      },
      priceRange = {
        min = parsed.minPrice,
        max = parsed.maxPrice,
      },
      exactSearch = ExtractExactSearch(parsed.queryString),
    }
  }
end

local function GetProcessors(testItem, filter)
  return {
    CreateAndInitFromMixin(Auctionator.Search.Processors.ItemLevelMixin, testItem, filter.itemLevel or {}),
    CreateAndInitFromMixin(Auctionator.Search.Processors.ExactMixin, testItem, filter.exactSearch),
    CreateAndInitFromMixin(Auctionator.Search.Processors.CraftLevelMixin, testItem, filter.craftLevel or {}),
    CreateAndInitFromMixin(Auctionator.Search.Processors.PriceMixin, testItem, filter.priceRange or {}),
  }
end

local function GetResults(allProcessors)
  local results = {}
  local offset = 0

  for index = 1, #allProcessors do
    local p = allProcessors[index - offset]
    if p:IsComplete() then
      p.testItem:MergeResult(p:GetResult())

      if p.testItem:IsReady() and p.testItem.result then
        table.insert(results, p.browseResult)
      end

      table.remove(allProcessors, index-offset)
      offset = offset + 1
    end
  end

  return results
end

function AuctionatorAdvancedSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:CreateSearchTerm()", term)
  if Auctionator.Search.IsAdvancedSearch(term) then
    return ParseAdvancedSearch(term)
  else
    return  {
      query = {
        searchString = term,
        filters = {},
        itemClassFilters = {},
        sorts = {},
      },
      extraFilters = {
        exactSearch = ExtractExactSearch(term)
      }
    }
  end
end

function AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    C_AuctionHouse.SendBrowseQuery(searchTerm.query)
    self.currentFilter = searchTerm.extraFilters
    self.allProcessors = {}
  end
end

function AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()")

  --Loaded all the terms from API, and we have filtered every item
  return C_AuctionHouse.HasFullBrowseResults() and
         #(self.allProcessors) == 0
end

function AuctionatorAdvancedSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResults(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    AuctionHouseFrame.BrowseResultsFrame.ItemList:SetCustomError(
      RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR)
    )
  else
    self:ProcessorsEvents(eventName, ...)
  end
end

function AuctionatorAdvancedSearchProviderMixin:ProcessorsEvents(eventName, ...)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessProcessors", eventName)

  for _, p in ipairs(self.allProcessors) do
    if p then
      p:OnFilterEventReceived(eventName, ...)
    end
  end

  local results = GetResults(self.allProcessors)
  self:AddResults(results)
end

function AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults()")
  for index = 1, #addedResults do
    local testItem = CreateAndInitFromMixin(
      Auctionator.Search.Processors.TestItemMixin,
      addedResults[index]
    )
    for _, p in ipairs(GetProcessors(testItem, self.currentFilter)) do
      table.insert(self.allProcessors, p)
    end
  end

  local results = GetResults(self.allProcessors)
  self:AddResults(results)
end

function AuctionatorAdvancedSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorAdvancedSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
end
