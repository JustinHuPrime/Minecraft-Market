-- pricer client

local channels = require("channels")

local function query(modem, id, name)
  modem.open(id)
  modem.transmit(channels.PRICER_CHANNEL, id, { type = "query", name = name })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

local function sell(modem, id, name, quantity)
  modem.open(id)
  modem.transmit(channels.PRICER_CHANNEL, id, { type = "sell", name = name, quantity = quantity })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

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
