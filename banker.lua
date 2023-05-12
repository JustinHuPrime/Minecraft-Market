-- banker client

local channels = require("channels")

local function query(modem, id, uuid)
    modem.open(id)
    modem.transmit(channels.BANKER_CHANNEL, id, { type = "query", uuid = uuid })
    local _, _, _, _, message, _ = os.pullEvent("modem_message")
    modem.close(id)
    return message
end

local function withdraw(modem, id, uuid, amount)
    modem.open(id)
    modem.transmit(channels.BANKER_CHANNEL, id, { type = "withdraw", uuid = uuid, amount = amount })
    local _, _, _, _, message, _ = os.pullEvent("modem_message")
    modem.close(id)
    return message
end

local function deposit(modem, id, uuid, amount)
    modem.open(id)
    modem.transmit(channels.BANKER_CHANNEL, id, { type = "deposit", uuid = uuid, amount = amount })
    local _, _, _, _, message, _ = os.pullEvent("modem_message")
    modem.close(id)
    return message
end

return {
    query = query,
    withdraw = withdraw,
    deposit = deposit
}
