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
      exactSearch = ExtractExactSearch(parsed.queryString),
    }
  }
end

local function GetProcessors(browseResult, filter)
  return {
    Auctionator.Utilities.InitInstance(Auctionator.Search.ItemLevelMixin, browseResult, filter.itemLevel or {}),
    Auctionator.Utilities.InitInstance(Auctionator.Search.ExactMixin, browseResult, filter.exactSearch),
    Auctionator.Utilities.InitInstance(Auctionator.Search.CraftLevelMixin, browseResult, filter.craftLevel or {}),
  }
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
    self:ProcessProcessors(eventName, ...)
  end
end

function AuctionatorAdvancedSearchProviderMixin:ProcessProcessors(eventName, ...)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessProcessors", eventName)
  local allOthersComplete = true
  local results = {}
  for _, processorInfo in ipairs(self.allProcessors) do
    local allComplete = true
    local result = true
    for _, processor in ipairs(processorInfo.processors) do
      processor:OnFilterEventReceived(eventName, ...)
      allComplete = processor:IsComplete() and allComplete
      if allComplete then
        result = result and processor:GetResult()
      end
    end
    if allComplete and result then
      table.insert(results, processorInfo.browseResult)
    end
    allOthersComplete = allOthersComplete and allComplete
  end
  if allOthersComplete then
    self.allProcessors = {}
  end
  self:AddResults(results)
end

function AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults()")

  local results = {}

  for index = 1, #addedResults do
    local browseResult = addedResults[index]
    local processors = GetProcessors(browseResult, self.currentFilter)
    local incomplete = {}
    local checkValue = true
    for _, processor in ipairs(processors) do
      if not processor:IsComplete() then
        table.insert(incomplete, processor)
      else
        checkValue = checkValue and processor:GetResult()
      end
    end

    if #incomplete > 0 then
      table.insert(self.allProcessors, {
        browseResult = browseResult,
        processors = incomplete
      })
    elseif checkValue then
      table.insert(results, browseResult)
    end
  end

  self:AddResults(results)
end

function AuctionatorAdvancedSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorAdvancedSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
end
