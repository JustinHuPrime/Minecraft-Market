-- tracks bank balances associated with players

local channels = require("channels")

local modem = peripheral.wrap("top") or error("No modem attached", 0)
modem.open(channels.BANKER_CHANNEL)

local accountsFile = io.open("accounts.dat", "r") or error("No accounts file", 0)
local accounts = textutils.unserialize(accountsFile:read("a"))
accountsFile:close()

local function saveAccounts()
  accountsFile = io.open("accounts.dat", "w") or error("Couldn't open accounts file", 0)
  accountsFile:write(textutils.serialize(accounts))
  accountsFile:close()
end

local function ensureAccount(uuid)
  if accounts[uuid] == nil then
    accounts[uuid] = 0
  end
end

print("Banker started")

while true do
  local _, _, _, replyChannel, message, _ = os.pullEvent("modem_message")
  if message.type == "query" then
    ensureAccount(message.uuid)

    modem.transmit(replyChannel, channels.BANKER_CHANNEL, accounts[message.uuid])
    print("Query for " .. message.uuid .. " = " .. math.floor(accounts[message.uuid]) / 100 .. " IC")
  elseif message.type == "deposit" then
    ensureAccount(message.uuid)
    accounts[message.uuid] = accounts[message.uuid] + message.amount

    modem.transmit(replyChannel, channels.BANKER_CHANNEL, accounts[message.uuid])
    saveAccounts()
    print("Deposit for " ..
      message.uuid ..
      " of " .. math.floor(message.amount) / 100 .. " IC = " .. math.floor(accounts[message.uuid]) / 100 .. " IC")
  elseif message.type == "withdraw" then
    ensureAccount(message.uuid)
    accounts[message.uuid] = accounts[message.uuid] - message.amount

    modem.transmit(replyChannel, channels.BANKER_CHANNEL, accounts[message.uuid])
    saveAccounts()
    print("Withdraw for " ..
      message.uuid ..
      " of " ..
      math.floor(message.amount) / 100 .. " IC = " .. math.floor(accounts[message.uuid]) / 100 .. " IC")
  else
    -- bad message
    modem.transmit(replyChannel, channels.BANKER_CHANNEL, "bad message")
    print("Bad message: " .. textutils.serialize(message))
  end
end
