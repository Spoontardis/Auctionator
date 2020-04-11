function Auctionator.Utilities.InitInstance(mixin, ...)
  local result = CreateFromMixins(mixin)
  result:Init(...)
  return result
end
