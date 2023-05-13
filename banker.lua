-- banker client

local channels = require("channels")

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param uuid string player uuid
--- @return number amount amount of cents in the player's account
local function query(modem, id, uuid)
  modem.open(id)
  modem.transmit(channels.BANKER_CHANNEL, id, { type = "query", uuid = uuid })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param uuid string player uuid
--- @param amount number amount to remove from the account
--- @return number amount amount of cents remaining in the player's account (maybe negative)
local function withdraw(modem, id, uuid, amount)
  modem.open(id)
  modem.transmit(channels.BANKER_CHANNEL, id, { type = "withdraw", uuid = uuid, amount = amount })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param uuid string player uuid
--- @param amount number amount to add to the account
--- @return number amount amount of cents now in the player's account (maybe negative)
local function deposit(modem, id, uuid, amount)
  modem.open(id)
  modem.transmit(channels.BANKER_CHANNEL, id, { type = "deposit", uuid = uuid, amount = amount })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

return {
  query = query,
  withdraw = withdraw,
  deposit = deposit
}
