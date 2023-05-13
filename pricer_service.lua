-- sets prices for things
-- price change = quantity * ln[(numberOfPurchases + targetStockLevel)/numberOfSales]

local channels = require("channels")

local modem = peripheral.wrap("top") or error("No modem attached", 0)
modem.open(channels.PRICER_CHANNEL)

local pricesFile = io.open("prices.dat", "r") or error("No prices file", 0)
local prices = textutils.unserialize(pricesFile:read("a"))
pricesFile:close()

local function savePrices()
  pricesFile = io.open("prices.dat", "w") or error("Couldn't open prices file", 0)
  pricesFile:write(textutils.serialize(prices))
  pricesFile:close()
end

local INITIAL_PRICE = 10
local TARGET_STOCK_LEVEL = 4096
local function ensurePrice(name)
  if prices[name] == nil then
    prices[name] = {
      bought = 1 + TARGET_STOCK_LEVEL,
      sold = 1,
      price = INITIAL_PRICE
    }
  end
end

local PRICE_DELTA_SCALE = 0.01
local function updatePrice(name, quantity)
  prices[name].price = prices[name].price +
      quantity * PRICE_DELTA_SCALE * math.log(prices[name].bought / prices[name].sold, math.exp(1))
end

print("Pricer started")

while true do
  local _, _, _, replyChannel, message, _ = os.pullEvent("modem_message")
  if message.type == "query" then
    ensurePrice(message.name)

    modem.transmit(replyChannel, channels.PRICER_CHANNEL, prices[name].price)
    print("Query for " .. message.name .. " = " .. math.floor(prices[name].price) .. " IC")
  elseif message.type == "sell" then
    ensurePrice(message.name)

    prices[message.name].sold = prices[message.name].sold + message.quantity
    updatePrice(message.name)

    modem.transmit(replyChannel, channels.PRICER_CHANNEL, prices[name].price)
    savePrices()
    print("Customer sold " ..
      message.quantity .. "x " .. message.name .. " = " .. math.floor(prices[name].price) .. " IC")
  elseif message.type == "buy" then
    ensurePrice(message.name)

    prices[message.name].bought = prices[message.name].bought + message.quantity
    updatePrice(message.name)

    modem.transmit(replyChannel, channels.PRICER_CHANNEL, prices[name].price)
    savePrices()
    print("Customer bought " ..
      message.quantity .. "x " .. message.name .. " = " .. math.floor(prices[name].price) .. " IC")
  else
    -- bad message
    modem.transmit(replyChannel, channels.PRICER_CHANNEL, "bad message")
    print("Bad message: " .. textutils.serialize(message))
  end
end
