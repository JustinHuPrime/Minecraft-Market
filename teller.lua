-- teller client

local channels = require("channels")

local function deposit(modem, id, chest)
  modem.open(id)
  modem.transmit(channels.TELLER_CHANNEL, id, { type = "deposit", chest = chest })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

local function withdraw(modem, id, chest, amount)
  modem.open(id)
  modem.transmit(channels.TELLER_CHANNEL, id, { type = "withdraw", chest = chest, amount = amount })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

return {
  deposit = deposit,
  withdraw = withdraw
}
