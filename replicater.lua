-- replicater client

local channels = require("channels")

--- @param modem table a modem peripheral
--- @param id integer a channel id to use
--- @param chest string the name of the chest peripheral
--- @param quantity integer how many to replicate
--- @return integer quantity quantity actually replicated
local function replicate(modem, id, chest, quantity)
  modem.open(id)
  modem.transmit(channels.REPLICATER_CHANNEL, id, { chest = chest, quantity = quantity })
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  modem.close(id)
  return message
end

return {
  replicate = replicate
}
