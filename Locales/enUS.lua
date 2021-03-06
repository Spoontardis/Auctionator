AUCTIONATOR_LOCALES.enUS = function()
  local L = {}

  L["CONFIG_BASIC_OPTIONS_CATEGORY"] = "Basic Options"
  L["CONFIG_BASIC_OPTIONS_TEXT"] = "Basic options for enabling features in Auctionator."
  L["CONFIG_SHOPPING_LIST"] = "Shopping List Settings"
  L["CONFIG_AUTOSCAN"] = "Run autoscan when Auction House is opened."
  L["CONFIG_AUTOSCAN_TOOLTIP_HEADER"] = "Autoscan"
  L["CONFIG_AUTOSCAN_TOOLTIP_TEXT"] = "Run a full scan when the auction house is opened. If not selected, you may run a full scan by clicking the 'Full Scan' button in the auction house."
  L["CONFIG_AUTO_LIST_SEARCH"] = "Automatically scan for shopping list items."
  L["CONFIG_AUTO_LIST_SEARCH_TOOLTIP_HEADER"] = "Automatic List Search"
  L["CONFIG_AUTO_LIST_SEARCH_TOOLTIP_TEXT"] = "When a list is selected, automatically scan the auction house for the list entries. When this option is off, you may scan for the entire list when selecting the 'Search' button in the Shopping List sidebar."
  L["CONFIG_CHAT_LOG"] = "Show your new auctions in chat"
  L["CONFIG_CHAT_LOG_TOOLTIP_HEADER"] = "Auction Chat Log"
  L["CONFIG_CHAT_LOG_TOOLTIP_TEXT"] = "If this option is off your auctions will not be scanned to find your new auctions."
  L["CONFIG_DEVELOPER"] = "Developer Settings"
  L["CONFIG_DEBUG"] = "Toggle debug output."
  L["CONFIG_DEBUG_TOOLTIP_HEADER"] = "Auctionator Debug"
  L["CONFIG_DEBUG_TOOLTIP_TEXT"] = "This is used by the maintainers to output debug messages to the chat frame."
  


  L["CONFIG_TOOLTIPS_CATEGORY"] = "Tooltips"
  L["CONFIG_TOOLTIPS_TEXT"] = "Options to display different auction related information on game tooltips."
  L["CONFIG_MAIL_TOOLTIP"] = "Show mailbox tooltips"
  L["MAIL_TOOLTIP_TOOLTIP_HEADER"] = "Mailbox Tooltips"
  L["MAIL_TOOLTIP_TOOLTIP_TEXT"] = "Shows Auctionator information for items in your mailbox on mouseover."
  L["CONFIG_VENDOR_TOOLTIP"] = "Show vendor tooltips."
  L["VENDOR_TOOLTIP_TOOLTIP_HEADER"] = "Vendor Tooltip Information"
  L["VENDOR_TOOLTIP_TOOLTIP_TEXT"] = "Show vendor information in tooltip on mouseover."
  L["CONFIG_AUCTION_TOOLTIP"] = "Show auction tooltips."
  L["AUCTION_TOOLTIP_TOOLTIP_HEADER"] = "Auction Tooltip Information"
  L["AUCTION_TOOLTIP_TOOLTIP_TEXT"] = "Show auction information in tooltip on mouseover."
  L["CONFIG_ENCHANT_TOOLTIP"] = "Show enchant tooltips (WoD, Legion & BfA only.)"
  L["ENCHANT_TOOLTIP_TOOLTIP_HEADER"] = "Enchant Tooltip Information"
  L["ENCHANT_TOOLTIP_TOOLTIP_TEXT"] = "Show enchant information in tooltip on mouseover."
  L["CONFIG_STACK_TOOLTIP"] = "Show stack price when holding shift."
  L["STACK_TOOLTIP_TOOLTIP_HEADER"] = "Stack Prices"
  L["STACK_TOOLTIP_TOOLTIP_TEXT"] = "When selected, the shift key must be held to see stack prices. When not selected, stack prices show by default."

  L["CONFIG_LIFO_CATEGORY"] = "Selling"
  L["CONFIG_NOT_LIFO_CATEGORY"] = "Gear/Pets"
  L["CONFIG_SELLING_LIFO_HEADER"] = "Selling"
  L["CONFIG_SELLING_NOT_LIFO_HEADER"] = "Selling Gear/Pets"
  L["CONFIG_SELLING_LIFO_TEXT"] = "Options to set undercutting percent or values and duration for most items."
  L["CONFIG_SELLING_NOT_LIFO_TEXT"] = "Options to set undercutting percent or values and duration for gear or pet cages."
  L["DEFAULT_AUCTION_DURATION"] = "Default Auction Duration"
  L["AUCTION_DURATION_12"] = "12 Hours"
  L["AUCTION_DURATION_24"] = "24 Hours"
  L["AUCTION_DURATION_48"] = "48 Hours"

  L["SALES_PREFERENCE"] = "Sales Preference"
  L["PERCENTAGE"] = "Percentage"
  L["SET_VALUE"] = "Set Value"

  L["PERCENTAGE_SUFFIX"] = "% Undercut"
  L["SET_VALUE_SUFFIX"] = "Undercut"

  L["PERCENTAGE_TOOLTIP_HEADER"] = "Undercut percentage"
  L["PERCENTAGE_TOOLTIP_TEXT"] = "The undercut percentage that will be used to calculate the sell price. For example, a value of 5 means that your item will be posted at 5% less than the current lowest price."

  L["UNDERCUT_TOOLTIP_HEADER"] = "Undercut Value"
  L["UNDERCUT_TOOLTIP_TEXT"] = "The undercut value that will be used to calculate the sell price."

  L["AUTHOR_HEADER"] = "Author"
  L["CONTRIBUTORS_HEADER"] = "Contributors"
  L["VERSION_HEADER"] = "Version"
  L["OPEN_ADDON_OPTIONS"] = "Open Addon Options"

  L["STACK_AUCTION_INFO"] = "%s for %s (at %s each)"
  L["BIDDING_AUCTION_INFO"] = "%s bidding at %s"
  L["BUYOUT_AUCTION_INFO"] = "%s buyout at %s"
  L["VERSION_MESSAGE"] = "Version %s"
  L["DATABASE_LOADED"] = "Database loaded with %s entries."
  L["LIMITED_FUNCTIONALITY_MESSAGE"] = "Limited functionality due to 8.3 AH updates."

  L["STARTING_FULL_SCAN"] = "Starting a full scan."
  L["NEXT_SCAN_MESSAGE"] = "A full scan may be started in %s minutes and %s seconds."
  L["FULL_SCAN_FAILED"] = "Full scan failed to complete."
  L["FINISHED_PROCESSING"] = "Finished processing %s items."
  L["STOPPED_PROCESSING"] = "Stopped processing at %s out of %s."

  L["TOO_MANY_SEARCH_RESULTS"] = "Too many search results. Limiting results displayed." 
  L["LIST_DELETE_ERROR"] = "An error occurred attempting to delete a list."
  L["LIST_ADD_ERROR"] = "An error occurred attempting to add an item to a list."

  L["TOO_SMALL_PERCENTAGE"] = "%% must be >= 0 (provided %s)"
  L["TOO_BIG_PERCENTAGE"] = "%% must be <= 100 (provided %s)"

  L["AUCTION"] = "Auction"
  L["CANNOT_AUCTION"] = "Cannot Auction"
  L["UNKNOWN"] = "unknown"
  L["VENDOR"] = "Vendor"
  L["DISENCHANT"] = "Disenchant"
  L["TOTAL_ITEMS_COLORED"] = "Total |cFFAAAAFF %s items|r"

  L["DELETE_LIST_NONE_SELECTED"] = "You must select a list to delete."
  L["DELETE_LIST_CONFIRM"] = "Are you SURE you want to delete '%s'?"
  L["CREATE_LIST_DIALOG"] = "Enter the name of the new shopping list:"
  L["RENAME_LIST_DIALOG"] = "Enter the new name for the shopping list:"
  L["ADD_TERM_TO_LIST_DIALOG"] = "Enter the search term to add:"

  L["RENAME"] = "Rename"
  L["DELETE"] = "Delete"
  L["CREATE"] = "Create"
  L["ADD_ITEM"] = "Add Item"
  L["SEARCH"] = "Search"

  L["SHOPPING_TAB"] = "Shopping"
  L["SHOPPING_TAB_HEADER"] = "Auctionator - Shopping Lists"
  L["INFO_TAB_HEADER"] = "Auctionator - Info"

  L["FETCHING_ITEM_INFO"] = "Fetching item info..."
  L["LIST_SEARCH_START"] = "Searching for items in %s..."
  L["LIST_SEARCH_STATUS"] = "Search for item %s/%s in\n %s"
  L["RESULTS_PRICE_COLUMN"] = "Price"
  L["RESULTS_NAME_COLUMN"] = "Name"
  L["RESULTS_AVAILABLE_COLUMN"] = "Available"

  L["FULL_SCAN_BUTTON"] = "Full Scan"

  return L
end
