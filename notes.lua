-- item manipulation tools for notes

local function stackValue(item)
  if item == nil then
    return 0
  elseif item.name ~= "minecraft:written_book" then
    return 0
  elseif item.displayName == "100 IC" then
    return 10000 * item.count
  elseif item.displayName == "50 IC" then
    return 5000 * item.count
  elseif item.displayName == "20 IC" then
    return 2000 * item.count
  elseif item.displayName == "10 IC" then
    return 1000 * item.count
  elseif item.displayName == "5 IC" then
    return 500 * item.count
  elseif item.displayName == "2 IC" then
    return 200 * item.count
  elseif item.displayName == "1 IC" then
    return 100 * item.count
  elseif item.displayName == "0.25 IC" then
    return 25 * item.count
  elseif item.displayName == "0.10 IC" then
    return 10 * item.count
  elseif item.displayName == "0.05 IC" then
    return 5 * item.count
  elseif item.displayName == "0.01 IC" then
    return 1 * item.count
  else
    return 0
  end
end

return {
  stackValue = stackValue
}
