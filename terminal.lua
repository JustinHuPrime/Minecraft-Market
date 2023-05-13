-- trading terminal

local banker = require("banker")
local teller = require("teller")
local pricer = require("pricer")
local stocker = require("stocker")

local modem = peripheral.wrap("bottom") or error("No modem attached", 0)
local chestName, detectorName, channelName = ...
local chest = peripheral.wrap(chestName) or error("No chest attached", 0)
local detector = peripheral.wrap(detectorName) or error("No detector attached", 0)
local channel = tonumber(channelName) or error("Bad channel specifier", 0)

local function findPlayer()
  local nearby = detector.nearbyEntities()
  for _, entity in ipairs(nearby) do
    if entity.isPlayer and math.abs(entity.x) <= 1 and math.abs(entity.z) <= 1 and entity.y == 2 then
      return entity
    end
  end

  return nil
end

-- per-player loop
while true do
  term.clear()
  term.setCursorPos(1, 1)
  print("Press enter to begin...")
  io.read()
  local player = findPlayer()
  if player ~= nil then
    while true do
      print("Hello, " .. player.name)
      print("Your balance is " .. math.floor(banker.query(modem, channel, player.uuid)) / 100)

      print("Would you like to")
      print("[D]eposit cash")
      print("[W]ithdraw cash")
      print("[B]uy items")
      print("[S]ell items")
      print("[R]eplicate items")
      print("[Q]uit")
      local selection = string.lower(io.read())

      if selection == "d" or selection == "deposit" then
        local amountDeposited = teller.deposit(modem, channel, peripheral.getName(chest))
        banker.deposit(modem, channel, player.uuid, amountDeposited)

        print("Deposited " .. amountDeposited / 100 .. " IC")
      elseif selection == "w" or selection == "withdraw" then
        print("How much would like like to withdraw?")
        local amountWithdrawn = tonumber(io.read())

        if amountWithdrawn ~= nil then
          amountWithdrawn = amountWithdrawn * 100

          local preBalance = banker.query(modem, channel, player.uuid)

          if preBalance > amountWithdrawn then
            -- commit transaction
            local amountLeft = banker.withdraw(modem, channel, player.uuid, amountWithdrawn)
            teller.withdraw(modem, channel, peripheral.getName(chest), amountWithdrawn)

            print("You have " .. amountLeft / 100 .. " IC remaining in your account")
          else
            print("Insufficient funds")
          end
        else
          print("Could not parse amount to withdraw")
        end
      elseif selection == "b" or selection == "buy" then
        print("What is the id of the item you'd like to buy?")
        local item = io.read()
        print("How many would you like to buy?")
        local amount = tonumber(io.read())
        if amount ~= nil then
          amount = math.floor(amount)

          local price = pricer.query(modem, channel, item)
          local preBalance = banker.query(modem, channel, player.uuid)

          if preBalance > price then
            -- commit transaction
            local bought = stocker.buy(modem, channel, peripheral.getName(chest), item, amount)
            pricer.buy(modem, channel, item, bought)
            local cost = price * bought
            local postBalance = banker.withdraw(modem, channel, player.uuid, cost)

            if bought == 0 then
              print("Item not in stock")
            else
              if bought < amount then
                print("Item had insufficient stock")
              end
              print("You bought " .. bought .. " items for a total of " .. cost / 100 .. " IC")
              print("You have " .. postBalance / 100 .. " IC remaining in your account")
            end
          else
            print("Insufficient funds")
          end
        else
          print("Could not parse amount to buy")
        end
      elseif selection == "s" or selection == "sell" then
        local hasNbt = false
        local items = {}
        for slot = 1, chest.size() do
          local item = chest.getItemDetail(slot)
          if item ~= nil then
            if item.nbt ~= nil then
              hasNbt = true
            else
              if items[item.name] == nil then
                items[item.name] = {}
                items[item.name].quantity = 0
              end
              items[item.name].quantity = items[item.name].quantity + item.count
            end
          end
        end

        if not hasNbt then
          local total = 0
          for name, record in pairs(items) do
            record.unitPrice = pricer.query(modem, channel, name)
            local stackPrice = record.unitPrice * record.quantity
            total = total + stackPrice
            print("Buying " ..
              record.quantity .. "x " .. name .. " @ " .. record.unitPrice / 100 .. " IC = " .. stackPrice / 100 .. " IC")
          end
          print("Buying all for " .. total / 100 .. " IC")
          print("Continue?")
          local continue = string.lower(io.read())

          if continue == "y" or continue == "yes" then
            -- commit
            local totalGain = 0
            local totalSold = 0
            for name, record in pairs(items) do
              local sold = stocker.sell(modem, channel, peripheral.getName(chest), name, record.quantity)
              totalSold = totalSold + sold
              pricer.sell(modem, channel, name, sold)
              local stackGain = record.unitPrice * sold
              totalGain = totalGain + stackGain
              banker.deposit(modem, channel, player.uuid, stackGain)
            end

            print("You sold " .. totalSold .. " items for a total of " .. totalGain / 100 .. " IC")
            print("You have " .. banker.query(modem, channel, player.uuid) / 100 .. " IC now in your account")
          else
            print("Transaction aborted")
          end
        else
          print("Detected item with NBT; refusing to buy")
        end
      elseif selection == "r" or selection == "replicate" then
        -- TODO: implement
        print("Sorry, replication services are not yet offered")
      elseif selection == "q" or selection == "quit" then
        break
      else
        -- bad selection
        print("Bad selection")
      end

      print("Press enter to continue...")
      io.read()
    end
  end
end
