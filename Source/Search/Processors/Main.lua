local PROCESSOR_MAPPING = {
  craftLevel = Auctionator.Search.Processors.CraftLevelMixin,
  itemLevel = Auctionator.Search.Processors.ItemLevelMixin,
  exactSearch = Auctionator.Search.Processors.ExactMixin,
  priceRange = Auctionator.Search.Processors.PriceMixin,
}

function Auctionator.Search.Processors.Create(testItem, allFilters)
  local processors = {}

  for key, filter in pairs(allFilters) do
    if PROCESSOR_MAPPING[key] ~= nil then
      table.insert(
        processors,
        CreateAndInitFromMixin(PROCESSOR_MAPPING[key], testItem, filter)
      )
    end
  end

  if #processors == 0 then
    return {
      CreateAndInitFromMixin(Auctionator.Search.Processors.ProcessorMixin, testItem, {})
    }
  else
    return processors
  end
end

function Auctionator.Search.Processors.GetResultsAndUpdate(allProcessors)
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
