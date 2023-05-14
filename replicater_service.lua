-- replicater service

local channels = require("channels")

local modem = peripheral.wrap("top") or error("No modem attached", 0)
modem.open(channels.REPLICATER_CHANNEL)

local stockTank = peripheral.wrap("modern_industrialization:quantum_tank_0") or error("No stock tank attached", 0)
local useTank = peripheral.wrap("modern_industrialization:quantum_tank_1") or error("No use tank attached", 0)
local turtleStorage = peripheral.wrap("modern_industrialization:configurable_chest_13") or
    error("No temp storage attached", 0)
local replicator = peripheral.wrap("modern_industrialization:replicator_2") or error("No replicator attached", 0)
local outputBarrel = peripheral.wrap("modern_industrialization:quantum_barrel_1") or
    error("No output barrel attached", 0)

print("Replicater started")

while true do
  local _, _, _, replyChannel, message, _ = os.pullEvent("modem_message")

  local chest = peripheral.wrap(message.chest) or error("Bad chest to get template from", 0)

  local transferred = replicator.pullItem(peripheral.getName(chest), nil, 1) == 0
  if transferred ~= 0 then
    stockTank.pushFluid(peripheral.getName(useTank), 100 * message.quantity)

    while outputBarrel.items()[1] == nil or outputBarrel.items()[1].count < message.quantity do
      os.sleep(1)
    end

    while outputBarrel.items()[1] ~= nil do
      outputBarrel.pushItem(peripheral.getName(chest), nil, nil)
    end

    modem.transmit(channels.REPLICATER_TURTLE_CHANNEL, 0, "extract")

    while turtleStorage.pushItem(peripheral.getName(chest), nil, nil) == 0 do
      -- intentionally empty
    end

    modem.transmit(replyChannel, channels.REPLICATER_CHANNEL, message.quantity)
    print("Replicated " .. message.quantity .. " items")
  else
    modem.transmit(replyChannel, channels.REPLICATER_CHANNEL, 0)
    print("No item to replicate")
  end
end
