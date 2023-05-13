-- teller client

local channels = require("channels")

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param chest string the name of the chest peripheral
--- @return number|string amount how many cents were deposited, or "contaminated"
local function deposit(modem, id, chest)
  modem.open(id)
  modem.transmit(channels.TELLER_CHANNEL, id, { type = "deposit", chest = chest })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param chest string the name of the chest peripheral
--- @param amount number how many cents to withdraw
--- @return number remainder the fractions of a cent that could not be withdrawn
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
