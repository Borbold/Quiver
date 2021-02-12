function UpdateSave(reset)
  self.UI.setValue("maxText", maxValue)
  local changeXml = (not reset and self.UI.getXml()) or nil
  local dataToSave = {
    ["maxValue"] = maxValue, ["countAmunition"] = countAmunition, ["changeXml"] = changeXml,
    ["fildForAmmunitions"] = fildForAmmunitions
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  colorPlayer = {
      ["White"] = {r = 1, g = 1, b = 1},
      ["Red"] = {r = 0.86, g = 0.1, b = 0.09},
      ["Blue"] = {r = 0.12, g = 0.53, b = 1},
      ["Green"] = {r = 0.19, g = 0.7, b = 0.17},
      ["Yellow"] = {r = 0.9, g = 0.9, b = 0.17},
      ["Orange"] = {r = 0.96, g = 0.39, b = 0.11},
      ["Brown"] = {r = 0.44, g = 0.23, b = 0.09},
      ["Purple"] = {r = 0.63, g = 0.12, b = 0.94},
      ["Pink"] = {r = 0.96, g = 0.44, b = 0.81},
      ["Teal"] = {r = 0.13, g = 0.69, b = 0.61},
      ["Black"] = {r = 0.25, g = 0.25, b = 0.25}
  }
  hexArray = {
    ["a"] = 10, ["b"] = 11, ["c"] = 12, ["d"] = 13, ["e"] = 14, ["f"] = 15,
  }

  maxValue, countAmunition, selectTypeId = 1, 1, -1
  fildForAmmunitions = {}
  Wait.Frames(|| Confer(savedData), 15)
end
function Confer(savedData)
  originalXml = self.UI.getXml()
  RebuildAssets()
  if(savedData ~= "") then
    local loadedData = JSON.decode(savedData)
    maxValue = loadedData.maxValue or 1
    countAmunition = loadedData.countAmunition or 1
    fildForAmmunitions = loadedData.fildForAmmunitions or {}
    SetNewAmmunitionType(_, _, _, true)
  end
end

function PanelTool()
  if(self.UI.getAttribute("panelTool", "active") == "false") then
    self.UI.show("panelTool")
    self.UI.show("panelClose")
  else
    self.UI.hide("panelTool")
    self.UI.hide("panelClose")
  end
  Wait.Frames(UpdateSave, 5)
end

function PanelTool2()
  if(self.UI.getAttribute("panelTool2", "active") == "false") then
    self.UI.show("panelTool2")
  else
    self.UI.hide("panelTool2")
  end
  Wait.Frames(UpdateSave, 5)
end

function SetInputMax(_, input, id)
  input = tonumber(input)
  maxValue = input
  Wait.Frames(UpdateSave, 5)
end

function PlusValue(_, _, id)
  SetValueAmmunition(_, 1, id)
end
function MinusValue(_, _, id)
  SetValueAmmunition(_, -1, id)
end

function SetNewAmmunitionType(_, _, _, isOnLoad)
  if(not isOnLoad) then
    fildForAmmunitions[tostring(countAmunition)] = {name = "", color = "000000", value = 0}
    countAmunition = countAmunition + 1
  end

  local allXml = originalXml

  local newType = ""
  for i,v in pairs(fildForAmmunitions) do
    newType = newType .. [[
      <Row preferredHeight='25'>
        <Cell columnSpan='1'>
          <InputField id='name]]..i..[[' class='inputType' color='#ffffff' placeholder='Name' text=']]..v.name..[['/>
        </Cell>
        <Cell columnSpan='1'>
          <InputField id='color]]..i..[[' class='inputType' color='#ffffff' placeholder='#color' characterLimit='6'
            characterValidation='Alphanumeric' text=']]..v.color..[['/>
        </Cell>
      </Row>
    ]]
  end

  local searchString = "<NewRowS />"
  local searchStringLength = #searchString

  local indexFirst = allXml:find(searchString)
  
  local startXml = allXml:sub(1, indexFirst + searchStringLength)
  local endXml = allXml:sub(indexFirst + searchStringLength)
  allXml = startXml .. newType .. endXml
  --------------------------------------------------------------------------------
  newType = ""
  for i,v in pairs(fildForAmmunitions) do
    newType = newType .. [[
      <Row preferredHeight='25'>
        <Cell columnSpan='4' dontUseTableCellBackground='true'>
          <Text id='nameT]]..i..[[' class='bestFitT' text=']]..v.name..[[' color='#]]..v.color..[['/>
        </Cell>
        <Cell columnSpan='2' dontUseTableCellBackground='true'>
          <InputField id='value]]..i..[[' class='inputValue' color='#44944a' placeholder='value'
            characterValidation='Integer' text=']]..v.value..[['/>
        </Cell>
        <Cell columnSpan='1' dontUseTableCellBackground='true'>
          <Button id='buttonS]]..i..[[' image='uiCube' class='bestFitB' onClick='SelectTypeAmmunition'/>
        </Cell>
        <Cell columnSpan='1' dontUseTableCellBackground='true'>
          <Button id='buttonP]]..i..[[' image='uiPlus' class='bestFitB' onClick='PlusValue'/>
        </Cell>
      </Row>
    ]]
  end

  searchString = "<NewRowC />"
  searchStringLength = #searchString

  indexFirst = allXml:find(searchString)
  
  startXml = allXml:sub(1, indexFirst + searchStringLength)
  endXml = allXml:sub(indexFirst + searchStringLength)

  startXml = startXml .. newType .. endXml
  self.UI.setXml(startXml)
  UpdateSave()
end

function SetInputTypeAmmunition(_, input, id)
  if(id:find("name")) then
    self.UI.setAttribute(id, "text", input)
    id = id:sub(5, #id)
    fildForAmmunitions[id].name = input
    self.UI.setValue("nameT"..id, input)
  elseif(id:find("color")) then
    self.UI.setAttribute(id, "text", input)
    id = id:sub(6, #id)
    fildForAmmunitions[id].color = input
    self.UI.setAttribute("nameT"..id, "color", "#"..input)
  end
  Wait.Frames(UpdateSave, 5)
end

function SetValueAmmunition(_, input, id)
  if(not input or input == "") then return end

  if(id:find("value")) then
    id = id:sub(6, #id)

    local currentValue = 0
    for i,v in pairs(fildForAmmunitions) do
      if(id ~= i) then
        currentValue = currentValue + v.value
      end
    end
    if(tonumber(input) + currentValue > maxValue) then
      broadcastToAll("Не влезает больше")
      self.UI.setAttribute("value"..id, "text", 0)
      return
    end

    fildForAmmunitions[id].value = tonumber(input)
  elseif(id:find("buttonP")) then
    id = id:sub(8, #id)

    local currentValue = 0
    for _,v in pairs(fildForAmmunitions) do
      currentValue = currentValue + v.value
    end
    if(tonumber(input) + currentValue > maxValue) then
      broadcastToAll("Не влезает больше")
      return
    end

    fildForAmmunitions[id].value = fildForAmmunitions[id].value + tonumber(input)
    self.UI.setAttribute("value"..id, "text", fildForAmmunitions[id].value)
  elseif(id:find("buttonM")) then
    id = id:sub(8, #id)

    if(fildForAmmunitions[id].value + tonumber(input) < 0) then
      broadcastToAll("Боеприпасы кончились")
      return
    end

    local colorRGB, index = {r = 0, b = 0, g = 0}, 1
    local locTableHex = {r = "", g = "", b = ""}
    fildForAmmunitions[id].color = fildForAmmunitions[id].color:lower()
    locTableHex.r = fildForAmmunitions[id].color:sub(1, 2)
    locTableHex.g = fildForAmmunitions[id].color:sub(3, 4)
    locTableHex.b = fildForAmmunitions[id].color:sub(5, 6)
    for i,c in pairs(locTableHex) do
      local locC = hexArray[c:sub(1, 1)] or c:sub(1, 1)
      colorRGB[i] = colorRGB[i] + 16*tonumber((locC ~= "" and locC) or 0)
      locC = hexArray[c:sub(2, 2)] or c:sub(2, 2)
      colorRGB[i] = colorRGB[i] + tonumber((locC ~= "" and locC) or 0)
      colorRGB[i] = colorRGB[i]/255
    end

    broadcastToAll("Использована " .. fildForAmmunitions[id].name, colorRGB)
    fildForAmmunitions[id].value = fildForAmmunitions[id].value + tonumber(input)
    self.UI.setAttribute("value"..id, "text", fildForAmmunitions[id].value)
  end
  UpdateSave()
end

function Reset()
  maxValue, countAmunition, selectTypeId = 1, 1, -1
  fildForAmmunitions = {}
  self.UI.setXml(originalXml)
  UpdateSave(true)
end

function SelectTypeAmmunition(_, input, id)
  if(id:find("buttonS")) then
    id = id:sub(8, #id)
    local locId = (selectTypeId > 0 and selectTypeId) or ""
    self.UI.setAttribute("buttonM"..locId, "active", "true")
    self.UI.setAttribute("buttonM"..locId, "id", "buttonM"..id)
    selectTypeId = tonumber(id)
  end
  UpdateSave()
end

function DenoteSth()
	local color = ""
  for iColor,_ in pairs(colorPlayer) do
    if(CheckColor(iColor)) then
	    color = iColor
      break
    end
  end
  return color
end
function CheckColor(color)
  local colorObject = {
    ["R"] = Round(self.getColorTint()[1], 2),
    ["G"] = Round(self.getColorTint()[2], 2),
    ["B"] = Round(self.getColorTint()[3], 2)
  }
	if(colorObject.R == colorPlayer[color].r and
     colorObject.G == colorPlayer[color].g and
     colorObject.B == colorPlayer[color].b) then
    return true
  else
    return false
  end
end
function Round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function RebuildAssets()
  local root = 'https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/'
  local assets = {
    {name = 'uiGear', url = root .. 'gear.png'},
    {name = 'uiBars', url = root .. 'bars.png'},
    {name = 'uiPlus', url = root .. 'plus.png'},
    {name = 'uiClose', url = root .. 'close.png'},
    {name = 'uiCube', url = root .. 'cube.png'},
  }
  self.UI.setCustomAssets(assets)
end
