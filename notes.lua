-- item manipulation tools for notes

local hundredBin = peripheral.wrap("modern_industrialization:steel_barrel_0") or error("No 100 IC bin found", 0)
local fiftyBin = peripheral.wrap("modern_industrialization:steel_barrel_1") or error("No 50 IC bin found", 0)
local twentyBin = peripheral.wrap("modern_industrialization:steel_barrel_2") or error("No 20 IC bin found", 0)
local tenBin = peripheral.wrap("modern_industrialization:steel_barrel_3") or error("No 10 IC bin found", 0)
local fiveBin = peripheral.wrap("modern_industrialization:steel_barrel_4") or error("No 5 IC bin found", 0)
local twoBin = peripheral.wrap("modern_industrialization:steel_barrel_5") or error("No 2 IC bin found", 0)
local oneBin = peripheral.wrap("modern_industrialization:steel_barrel_6") or error("No 1 IC bin found", 0)
local quarterBin = peripheral.wrap("modern_industrialization:steel_barrel_7") or error("No 0.25 IC bin found", 0)
local dimeBin = peripheral.wrap("modern_industrialization:steel_barrel_8") or error("No 0.10 IC bin found", 0)
local nickelBin = peripheral.wrap("modern_industrialization:steel_barrel_9") or error("No 0.05 IC bin found", 0)
local pennyBin = peripheral.wrap("modern_industrialization:steel_barrel_10") or error("No 0.01 IC bin found", 0)

local HUNDRED_NBT = "b460dce227ac316a0e8df577c71076d3"
local FIFTY_NBT = "e8160b40f180c4fe69e83bb785c176c8"
local TWENTY_NBT = "3e51584c572da2e9e20edee5d2d5fe5f"
local TEN_NBT = "da974be8479aa96bdb3d1c2d4f9f3aeb"
local FIVE_NBT = "db0538ccfc8d47c79ec31f85071288d7"
local TWO_NBT = "b4be2a999599f0ed3c776f1eb62dd5cf"
local ONE_NBT = "3756940e52ae6b00f449d7752a58e665"
local QUARTER_NBT = "41603d93141bd0e25928b6a31953f5e4"
local DIME_NBT = "62f61d5b7323b16618178cb1b9636a16"
local NICKEL_NBT = "c4c51ab5f782a9f37a9857257bce36e2"
local PENNY_NBT = "8af352aaf9451c133c49c0133a50e8b4"

local function stackValue(item)
  if item == nil then
    return 0
  elseif item.name ~= "minecraft:written_book" then
    return 0
  elseif item.nbt == HUNDRED_NBT or item.nbt == hundredBin.items()[1].nbt then
    return 10000 * item.count
  elseif item.nbt == FIFTY_NBT or item.nbt == fiftyBin.items()[1].nbt then
    return 5000 * item.count
  elseif item.nbt == TWENTY_NBT or item.nbt == twentyBin.items()[1].nbt then
    return 2000 * item.count
  elseif item.nbt == TEN_NBT or item.nbt == tenBin.items()[1].nbt then
    return 1000 * item.count
  elseif item.nbt == FIVE_NBT or item.nbt == fiveBin.items()[1].nbt then
    return 500 * item.count
  elseif item.nbt == TWO_NBT or item.nbt == twoBin.items()[1].nbt then
    return 200 * item.count
  elseif item.nbt == ONE_NBT or item.nbt == oneBin.items()[1].nbt then
    return 100 * item.count
  elseif item.nbt == QUARTER_NBT or item.nbt == quarterBin.items()[1].nbt then
    return 25 * item.count
  elseif item.nbt == DIME_NBT or item.nbt == dimeBin.items()[1].nbt then
    return 10 * item.count
  elseif item.nbt == NICKEL_NBT or item.nbt == nickelBin.items()[1].nbt then
    return 5 * item.count
  elseif item.nbt == PENNY_NBT or item.nbt == pennyBin.items()[1].nbt then
    return 1 * item.count
  else
    return 0
  end
end

return {
  stackValue = stackValue
}
