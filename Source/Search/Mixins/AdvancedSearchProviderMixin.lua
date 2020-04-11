AuctionatorAdvancedSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
  "ITEM_KEY_ITEM_INFO_RECEIVED",
  "EXTRA_BROWSE_INFO_RECEIVED",
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
    Auctionator.Utilities.InitInstance(Auctionator.Search.ItemLevelMixin, browseResult, filter.itemLevel),
    --Auctionator.Search.ExactMixin.Init({}, browseResult, filter.craftLevel),
    --Auctionator.Search.CraftLevelMixin.Init({}, browseResult, filter.exactSearch),
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
    self:ProcessProcessors(...)
  end
end

function AuctionatorAdvancedSearchProviderMixin:ProcessProcessors(eventName, ...)
  local allOthersComplete = true
  for _, processorInfo in ipairs(self.allProcessors) do
    local allComplete = true
    local result = true
    for _, processor in ipairs(processorInfo.processors) do
      processor:OnSearchEventReceived(eventName, ...)
      allComplete = processor:IsComplete() and allComplete
      if allComplete then
        result = result and processor:GetResult()
      end
    end
    if allComplete then
      processorInfo.processors = {}
      if result then
        self:AddResults({result})
      else
        self:AddResults({})
      end
    end
    allOthersComplete = allOthersComplete and allComplete
  end
  if allOthersComplete then
    self.allProcessors = {}
  end
end

function AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults()")

  local results = {}
  self.allProcessors = {}

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

function AuctionatorAdvancedSearchProviderMixin:ProcessItemKeyInfo(itemID)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessItemKeyInfo. Waiting", #self.itemKeyInfoQueue)
  --Event for missing info received about itemID.
  for index, browseResult in ipairs(self.itemKeyInfoQueue) do
    if browseResult.itemKey.itemID == itemID then
      local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(browseResult.itemKey)

      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessItemKeyInfo", itemKeyInfo.itemName)

      --Remove key from list of those with missing info
      table.remove(self.itemKeyInfoQueue, index)

      --Only exact search uses this info, and the event won't have been queued
      --otherwise.
      if self:ExactMatchCheck(itemKeyInfo) and
         self:FilterByCraftLevel(browseResult) then
        self:AddResults({browseResult})
      else
      --Post empty results, so the mixin supplying it runs
      --self:HasCompleteTermResults() and can see if the search is complete
        self:AddResults({})
      end

      return
    end
  end
end

function AuctionatorAdvancedSearchProviderMixin:ProcessExtraBrowseInfo(itemID)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessExtraBrowseInfo. Waiting", #self.extraBrowseInfoQueue)
  --Event for missing info received about itemID.
  for index, browseResult in ipairs(self.extraBrowseInfoQueue) do
    if browseResult.itemKey.itemID == itemID then
      local extraBrowseInfo = C_AuctionHouse.GetExtraBrowseInfo(browseResult.itemKey)

      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessExtraBrowseInfo", extraBrowseInfo)

      --Remove key from list of those with missing info
      table.remove(self.extraBrowseInfoQueue, index)

      if self:CraftLevelCheck(extraBrowseInfo) then
        self:AddResults({browseResult})
      else
      --Post empty results, so the mixin supplying it runs
      --self:HasCompleteTermResults() and can see if the search is complete
        self:AddResults({})
      end

      return
    end
  end
end

function AuctionatorAdvancedSearchProviderMixin:FilterByExact(browseResult)
  local itemKey = browseResult.itemKey

  if self.currentFilter.exactSearch ~= nil then
    local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey)

    if itemKeyInfo == nil then
      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:FilterByExact Missing itemKeyInfo")

      --Put key in the queue for completing filtering later in an
      --ITEM_KEY_ITEM_INFO_RECEIVED event
      table.insert(self.itemKeyInfoQueue, browseResult)

      return false
    else
      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:FilterByExact Got itemKeyInfo", itemKeyInfo.itemName)

      return self:ExactMatchCheck(itemKeyInfo)
    end
  end

  return true
end

function AuctionatorAdvancedSearchProviderMixin:ExactMatchCheck(itemKeyInfo)
  return string.lower(itemKeyInfo.itemName) == string.lower(self.currentFilter.exactSearch)
end

function AuctionatorAdvancedSearchProviderMixin:FilterByCraftLevel(browseResult)
  local itemKey = browseResult.itemKey

  if self:HasCraftLevelFilter() then
    local extraBrowseInfo = C_AuctionHouse.GetExtraBrowseInfo(itemKey)

    if extraBrowseInfo == nil then
      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:FilterByCraftLevel Missing extraBrowseInfo")

      --Put key in the queue for completing filtering later in an
      --EXTRA_BROWSE_INFO_RECEIVED event
      table.insert(self.extraBrowseInfoQueue, browseResult)

      return false
    else
      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:FilterByCraftLevel Got extraBrowseInfo", extraBrowseInfo)
      Auctionator.Debug.Message("checked", self:CraftLevelCheck(extraBrowseInfo))

      return self:CraftLevelCheck(extraBrowseInfo)
    end
  end

  return true
end

function AuctionatorAdvancedSearchProviderMixin:HasCraftLevelFilter()
  return self.currentFilter.minCraftLevel ~= nil or
         self.currentFilter.maxCraftLevel ~= nil
end

function AuctionatorAdvancedSearchProviderMixin:CraftLevelCheck(extraBrowseInfoNum)
  return
    (
      --Minimum item level check
      self.currentFilter.minCraftLevel == nil or
      self.currentFilter.minCraftLevel <= extraBrowseInfoNum
    ) and (
      --Maximum item level check
      self.currentFilter.maxCraftLevel == nil or
      self.currentFilter.maxCraftLevel >= extraBrowseInfoNum
    )
end

function AuctionatorAdvancedSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorAdvancedSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
end
