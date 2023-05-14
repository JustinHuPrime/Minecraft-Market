-- stock transfer service

local channels = require("channels")

local modem = peripheral.wrap("top") or error("No modem attached", 0)
modem.open(channels.STOCKER_CHANNEL)

local storage = peripheral.wrap("ae2:dense_energy_cell_0") or error("No storage system attached", 0)

print("Stocker started")

while true do
  local _, _, _, replyChannel, message, _ = os.pullEvent("modem_message")
  if message.type == "sell" then
    local chest = peripheral.wrap(message.chest) or error("Bad chest to sell from")
    local leftToMove = message.quantity
    local lastMove = 128
    while leftToMove > 0 and lastMove ~= 0 do
      lastMove = storage.pullItem(peripheral.getName(chest), message.name, leftToMove)
      leftToMove = leftToMove - lastMove
    end
    local pulled = message.quantity - leftToMove

    modem.transmit(replyChannel, channels.STOCKER_CHANNEL, pulled)
    print("Customer sold " .. pulled .. " " .. message.name)
  elseif message.type == "buy" then
    local chest = peripheral.wrap(message.chest) or error("Bad chest to sell from")
    local leftToMove = message.quantity
    local lastMove = 128
    while leftToMove > 0 and lastMove ~= 0 do
      lastMove = storage.pushItem(peripheral.getName(chest), message.name, message.quantity)
      leftToMove = leftToMove - lastMove
    end
    local pushed = message.quantity - leftToMove

    modem.transmit(replyChannel, channels.STOCKER_CHANNEL, pushed)
    print("Customer bought " .. pushed .. " out of " .. message.quantity .. " " .. message.name)
  else
    -- bad message
    modem.transmit(replyChannel, channels.PRICER_CHANNEL, "bad message")
    print("Bad message: " .. textutils.serialize(message))
  end
end
