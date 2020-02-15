local _, addonTable = ...;
local zc = addonTable.zc;

function Auctionator.SlashCmd.Initialize()
  SlashCmdList["Auctionator"] = Auctionator.SlashCmd.Handler
  SLASH_Auctionator1 = "/auctionator"
  SLASH_Auctionator2 = "/atr"
end

--Update SLASH_COMMAND_DESCRIPTIONS in Commands.lua for new commands
local SLASH_COMMANDS = {
  ["rt"] = Auctionator.SlashCmd.ResetTimer,
  ["resettimer"] = Auctionator.SlashCmd.ResetTimer,
  ["rdb"] = Auctionator.SlashCmd.ResetDatabase,
  ["resetdatabase"] = Auctionator.SlashCmd.ResetDatabase,
  ["d"] = Auctionator.SlashCmd.ToggleDebug,
  ["debug"] = Auctionator.SlashCmd.ToggleDebug,
  ["h"] = Auctionator.SlashCmd.Help,
  ["help"] = Auctionator.SlashCmd.Help,
}

function Auctionator.SlashCmd.Handler(input)
  Auctionator.Debug.Message( 'Auctionator.SlashCmd.Handler', input )

  if #input == 0 then
    Auctionator.SlashCmd.Help()
  else
    local command = {zc.words(input:lower())};
    local handler = SLASH_COMMANDS[command[1]]
    if handler == nil then
      Auctionator.Utilities.Message("Unrecognized command '" .. command[1] .. "'")
      Auctionator.SlashCmd.Help()
    else
      handler()
    end
  end
end