-- logger client

local channels = require("channels")

--- @param modem table a modem peripheral
--- @param message string a message to log
local function log(modem, message)
  print(message)
  modem.transmit(channels.LOGGER_CHANNEL, 0, message)
end

return {
  log = log
}
