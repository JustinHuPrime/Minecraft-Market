-- handles input and output of banknotes

local channels = require("channels")

local modem = peripheral.wrap("top") or error("No modem attached", 0)
modem.open(channels.TELLER_CHANNEL)

local trash = peripheral.wrap("expandedstorage:obsidian_barrel_0") or error("No trash can found", 0)

local hundred = peripheral.wrap("modern_industrialization:steel_barrel_0") or error("No 100 IC bin found", 0)
local fifty = peripheral.wrap("modern_industrialization:steel_barrel_1") or error("No 50 IC bin found", 0)
local twenty = peripheral.wrap("modern_industrialization:steel_barrel_2") or error("No 20 IC bin found", 0)
local ten = peripheral.wrap("modern_industrialization:steel_barrel_3") or error("No 10 IC bin found", 0)
local five = peripheral.wrap("modern_industrialization:steel_barrel_4") or error("No 5 IC bin found", 0)
local two = peripheral.wrap("modern_industrialization:steel_barrel_5") or error("No 2 IC bin found", 0)
local one = peripheral.wrap("modern_industrialization:steel_barrel_6") or error("No 1 IC bin found", 0)
local quarter = peripheral.wrap("modern_industrialization:steel_barrel_7") or error("No 0.25 IC bin found", 0)
local dime = peripheral.wrap("modern_industrialization:steel_barrel_8") or error("No 0.10 IC bin found", 0)
local nickel = peripheral.wrap("modern_industrialization:steel_barrel_9") or error("No 0.05 IC bin found", 0)
local penny = peripheral.wrap("modern_industrialization:steel_barrel_10") or error("No 0.01 IC bin found", 0)

local notes = require("notes")

local function transfer(source, target, amount)
  local amountLeft = amount
  while amountLeft > 0 do
    amountLeft = amountLeft - source.pushItem(peripheral.getName(target), nil, amountLeft)
  end
end

print("Teller started")

while true do
  local _, _, _, replyChannel, message, _ = os.pullEvent("modem_message")
  if message.type == "deposit" then
    local chest = peripheral.wrap(message.chest) or error("Bad chest to deposit from", 0)
    local total = 0
    for slot = 1, chest.size() do
      local stackValue = notes.stackValue(chest.getItemDetail(slot))
      if stackValue ~= 0 then
        total = total + stackValue
        chest.pushItems(peripheral.getName(trash), slot)
      end
    end

    modem.transmit(replyChannel, channels.TELLER_CHANNEL, total)
    print("Deposited " .. total / 100 .. " IC from " .. peripheral.getName(chest))
  elseif message.type == "withdraw" then
    local chest = peripheral.wrap(message.chest) or error("Bad chest to withdraw into", 0)
    local amountLeft = message.amount

    local hundreds = math.floor(amountLeft / 10000)
    transfer(hundred, chest, hundreds)
    amountLeft = math.fmod(amountLeft, 10000)

    local fifties = math.floor(amountLeft / 5000)
    transfer(fifty, chest, fifties)
    amountLeft = math.fmod(amountLeft, 5000)

    local twenties = math.floor(amountLeft / 2000)
    transfer(twenty, chest, twenties)
    amountLeft = math.fmod(amountLeft, 2000)

    local tens = math.floor(amountLeft / 1000)
    transfer(ten, chest, tens)
    amountLeft = math.fmod(amountLeft, 1000)

    local fives = math.floor(amountLeft / 500)
    transfer(five, chest, fives)
    amountLeft = math.fmod(amountLeft, 500)

    local twos = math.floor(amountLeft / 200)
    transfer(two, chest, twos)
    amountLeft = math.fmod(amountLeft, 200)

    local ones = math.floor(amountLeft / 100)
    transfer(one, chest, ones)
    amountLeft = math.fmod(amountLeft, 100)

    local quarters = math.floor(amountLeft / 25)
    transfer(quarter, chest, quarters)
    amountLeft = math.fmod(amountLeft, 25)

    local dimes = math.floor(amountLeft / 10)
    transfer(dime, chest, dimes)
    amountLeft = math.fmod(amountLeft, 10)

    local nickels = math.floor(amountLeft / 5)
    transfer(nickel, chest, nickels)
    amountLeft = math.fmod(amountLeft, 5)

    local pennies = math.floor(amountLeft)
    transfer(penny, chest, pennies)
    amountLeft = math.fmod(amountLeft, 1)

    modem.transmit(replyChannel, channels.TELLER_CHANNEL, amountLeft)
    print("Withdrew " ..
      math.floor(message.amount) / 100 ..
      " IC into " .. peripheral.getName(chest) .. " with residue of " .. amountLeft / 100 .. " IC")
  else
    -- bad message
    modem.transmit(replyChannel, channels.TELLER_CHANNEL, "bad message")
    print("Bad message: " .. textutils.serialize(message))
  end
end
