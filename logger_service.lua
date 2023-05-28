-- logging system

local channels = require("channels")

local modem = peripheral.wrap("top") or error("No modem attached", 0)
modem.open(channels.LOGGER_CHANNEL)

print("Logger started")

while true do
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  print(message)
  local log = io.open("log-" .. os.date("%F") .. ".log", "a") or error("Couldn't open log file", 0)
  log:write(message .. "\n")
  log:close()
end
