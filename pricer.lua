-- pricer client

local channels = require("channels")

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param name string id of the item
--- @return number price price of the item
local function query(modem, id, name)
  modem.open(id)
  modem.transmit(channels.PRICER_CHANNEL, id, { type = "query", name = name })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param name string id of the item
--- @param quantity integer how many got sold
--- @return number price new price of the item
local function sell(modem, id, name, quantity)
  modem.open(id)
  modem.transmit(channels.PRICER_CHANNEL, id, { type = "sell", name = name, quantity = quantity })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param name string id of the item
--- @param quantity integer how many got bought
--- @return number price new price of the item
local function buy(modem, id, name, quantity)
  modem.open(id)
  modem.transmit(channels.PRICER_CHANNEL, id, { type = "buy", name = name, quantity = quantity })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

return {
  query = query,
  sell = sell,
  buy = buy
}
