-- trading terminal

local banker = require("banker")
local teller = require("teller")
local pricer = require("pricer")
local stocker = require("stocker")
local replicater = require("replicater")

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
  print("Approach the terminal and press enter to begin...")
  io.read()
  local player = findPlayer()
  if player ~= nil then
    while true do
      print("Hello, " .. player.name)
      print("Your balance is " .. math.floor(banker.query(modem, channel, player.uuid)) / 100 .. " IC")

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
        if amountDeposited ~= "contaminated" then
          banker.deposit(modem, channel, player.uuid, amountDeposited)

          print("Deposited " .. amountDeposited / 100 .. " IC")
        else
          print("Remove non-banknote items from chest and try again")
        end
      elseif selection == "w" or selection == "withdraw" then
        print("How much would like like to withdraw?")
        local amountWithdrawn = tonumber(io.read())

        if amountWithdrawn ~= nil then
          amountWithdrawn = math.floor(amountWithdrawn * 100)

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
          print("Continue? (y/n)")
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
        if #chest.list() == 1 then
          local detail = nil
          for slot = 1, chest.size() do
            detail = chest.getItemDetail(slot)
            if detail ~= nil then
              break
            end
          end

          if detail.nbt == nil then
            if detail.name ~= "minecraft:written_book" then
              if detail.tags == nil or detail.tags["modern_industrialization:replicator_blacklist"] == nil then
                print("How many copies?")
                local copies = tonumber(io.read())

                if copies ~= nil then
                  copies = math.floor(copies)

                  local preBalance = banker.query(modem, channel, player.uuid)

                  if preBalance > copies * 100 then
                    -- commit transaction
                    local actualCopies = replicater.replicate(modem, channel, peripheral.getName(chest), copies)
                    local amountLeft = banker.withdraw(modem, channel, player.uuid, actualCopies * 100)

                    print("You have " .. amountLeft / 100 .. " IC remaining in your account")
                  end
                else
                  print("Could not parse number to replicate")
                end
              else
                print("Detected unreplicable item; refusing to replicate")
              end
            else
              print("Detected written book; refusing to replicate")
            end
          else
            print("Detected item with NBT; refusing to replicate")
          end
        else
          print("More than one stack present in chest; remove other stacks and try again")
        end
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
