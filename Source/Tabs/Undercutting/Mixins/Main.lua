AuctionatorUndercuttingFrameMixin = {}

function AuctionatorUndercuttingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorUndercuttingFrameMixin:OnLoad()")
end

-- Just putting this here since its temporary
AuctionatorMagicButton = {}

function AuctionatorMagicButton:OnLoad()
  DynamicResizeButton_Resize(self)
end

function AuctionatorMagicButton:OnClick()
  Auctionator.Debug.Message("AuctionatorMagicButton:OnClick()")

  if not AuctionatorMagicButtonUndercutFrame then
    frame = CreateFrame(
      "FRAME",
      "AuctionatorMagicButtonUndercutFrame",
      nil,
      "AuctionatorMagicButtonUndercutFrameTemplate"
    )
  else
    AuctionatorMagicButtonUndercutFrame:ButtonPress()
  end
end
