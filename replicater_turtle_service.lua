-- replicater service - turtle component

local channels = require("channels")

local modem = peripheral.wrap("top") or error("No modem attached", 0)
modem.open(channels.REPLICATER_TURTLE_CHANNEL)

local storage = peripheral.wrap("modern_industrialization:configurable_chest_13") or
    error("No temp storage attached", 0) -- TODO: what's this?

print("Replicater turtle started")

while true do
  local _, _, _, replyChannel, message, _ = os.pullEvent("modem_message")
  if message == "extract" then
    turtle.dig()
    if turtle.getItemDetail(1).name == "modern_industrialization:replicator" then
      turtle.select(1)
      turtle.place()
      turtle.select(2)
      turtle.dropDown()
    else
      turtle.select(2)
      turtle.place()
      turtle.select(1)
      turtle.dropDown()
    end
  end
end
