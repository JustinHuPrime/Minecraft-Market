-- stock transfer client

local channels = require("channels")

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param chest string the name of the chest peripheral
--- @param name string item id to sell
--- @param quantity number quantity to sell
--- @return number sold quantity actually sold
local function sell(modem, id, chest, name, quantity)
  modem.open(id)
  modem.transmit(channels.STOCKER_CHANNEL, id, { type = "sell", chest = chest, name = name, quantity = quantity })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param chest string the name of the chest peripheral
--- @param name string item id to sell
--- @param quantity number quantity to sell
--- @return number sold quantity actually bought
local function buy(modem, id, chest, name, quantity)
  modem.open(id)
  modem.transmit(channels.STOCKER_CHANNEL, id, { type = "buy", chest = chest, name = name, quantity = quantity })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

return {
  sell = sell,
  buy = buy
}
