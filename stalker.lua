

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera 
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
 
-- ========================================================================
-- TAMANHO DA GUI
-- ========================================================================
local GUI_WIDTH = 260    
local GUI_HEIGHT = 510  
 
-- ========================================================================
-- SETTINGS
-- ========================================================================
local stalkFOVdeg = 160      
local escapeMaxDistance = 35    
local maxStalkDistance = 35   
local stalkBehindDistance = 2.5 
local cameraOffset = Vector3.new(0, 5, 10) 
local cameraDistance = 10 
local riseSpeed = 45
local descendSpeed = 100
local shadowUndergroundDepth = 11
local shadowFollowSpeed = 18
 
-- PHYSICS
local TP_CHECK_HEIGHT = 100     
local TP_RAY_LENGTH = 200       
local CEILING_CHECK_HEIGHT = 8
 
-- STATE
local destroyed = false
local stalking = false
local viewingTarget = false     
local stalkConn = nil
local viewConn = nil            
local stalkTarget = nil
local viewTarget = nil
local selectedPlayer = nil
local originalCFrame = nil      
local TPToggle = false
local TPTool = nil
local shadowStalking = false
local shadowConn = nil
local shadowAnchor = nil
local anchorOffsetY = 0
local shadowMaxRise = 6
local shadowOriginalWalkSpeed = nil
local shadowOriginalAutoRotate = nil
local recentStalked = {}
local sortMode = "Alphabet"
local isRising = false
local shouldDescend = false
local updatePlayerList -- Forward declaration
local selectPlayer -- Forward declaration
local updateButtonsState -- Forward declaration
local mobileQBtn = nil 
local savedEmoteTrack = nil 
 
-- GUI State
local lastSelectedItem = nil 
local DEFAULT_COLOR = Color3.fromRGB(20, 20, 20)
local SELECTED_COLOR = Color3.fromRGB(100, 100, 100) 
 
cameraDistance = cameraOffset.Z
 
-- ========================================================================
-- I. MAIN GUI GENERATION
-- ========================================================================
 
local gui = Instance.new("ScreenGui")
gui.Name = "StalkGUI"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
 
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT) 
frame.Position = UDim2.new(0.5, -(GUI_WIDTH/2), 0.5, -(GUI_HEIGHT/2))
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ZIndex = 1
 
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame
 
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.Parent = frame 
 
-- Title
local titleContainer = Instance.new("Frame", frame)
titleContainer.Size = UDim2.new(1, 0, 0, 30)
titleContainer.Position = UDim2.new(0, 0, 0, 0)
titleContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
titleContainer.BorderSizePixel = 0
 
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleContainer
 
local title = Instance.new("TextLabel", titleContainer)
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "STALK MODE V2 - by HAX"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BorderSizePixel = 0
title.TextXAlignment = Enum.TextXAlignment.Left
 
local minimizeBtn = Instance.new("TextButton", titleContainer)
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0.2, 0, 1, 0)
minimizeBtn.Position = UDim2.new(0.8, 0, 0, 0)
minimizeBtn.Text = "−"
minimizeBtn.TextScaled = true
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
 
local isMinimized = false
 
-- Search & Filter
local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.new(0.75, 0, 0, 30) 
searchBox.Position = UDim2.new(0, 0, 0, 30)
searchBox.PlaceholderText = "Search Players..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.BorderSizePixel = 0
searchBox.ClearTextOnFocus = false
 
local searchStroke = Instance.new("UIStroke")
searchStroke.Color = Color3.fromRGB(100, 100, 100)
searchStroke.Thickness = 0.5
searchStroke.Parent = searchBox
 
local filterBtn = Instance.new("TextButton", frame)
filterBtn.Name = "FilterBtn"
filterBtn.Size = UDim2.new(0.25, 0, 0, 30)
filterBtn.Position = UDim2.new(0.75, 0, 0, 30)
filterBtn.Text = "FILTER"
filterBtn.TextScaled = true
filterBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
filterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
filterBtn.Font = Enum.Font.GothamBold
filterBtn.BorderSizePixel = 0
filterBtn.ZIndex = 2
 
local filterCorner = Instance.new("UICorner")
filterCorner.CornerRadius = UDim.new(0, 4)
filterCorner.Parent = filterBtn
 
local filterStroke = Instance.new("UIStroke")
filterStroke.Color = Color3.fromRGB(100, 100, 100)
filterStroke.Thickness = 0.5
filterStroke.Parent = filterBtn
 
local filterOptionsFrame = Instance.new("Frame", frame)
filterOptionsFrame.Name = "FilterOptions"
filterOptionsFrame.Size = UDim2.new(0, 120, 0, 0)
filterOptionsFrame.Position = UDim2.new(0.75, -20, 0, 60)
filterOptionsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
filterOptionsFrame.BorderSizePixel = 0
filterOptionsFrame.Visible = false
filterOptionsFrame.ZIndex = 50
 
local filterOptionsCorner = Instance.new("UICorner")
filterOptionsCorner.CornerRadius = UDim.new(0, 8)
filterOptionsCorner.Parent = filterOptionsFrame
 
local filterOptionsStroke = Instance.new("UIStroke")
filterOptionsStroke.Color = Color3.fromRGB(100, 100, 100)
filterOptionsStroke.Thickness = 1
filterOptionsStroke.Parent = filterOptionsFrame
 
local filterOptionsLayout = Instance.new("UIListLayout", filterOptionsFrame)
filterOptionsLayout.Padding = UDim.new(0, 2)
filterOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
filterOptionsLayout.FillDirection = Enum.FillDirection.Vertical
 
local filterOptions = {}
 
local function createFilterOption(text, mode)
    local btn = Instance.new("TextButton", filterOptionsFrame)
    btn.Name = mode
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Text = text
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 51
    btn.AutoButtonColor = true
 
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
 
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(100, 100, 100)
    btnStroke.Thickness = 0.5
    btnStroke.Parent = btn
 
    btn.MouseButton1Click:Connect(function()
        sortMode = mode
        filterOptionsFrame.Visible = false
        if mode == "Alphabet" and searchBox and searchBox.Parent then
            searchBox.Text = ""
        end
        if updatePlayerList and type(updatePlayerList) == "function" then
            updatePlayerList()
        end
    end)
 
    table.insert(filterOptions, btn)
    return btn
end
 
createFilterOption("Alphabet", "Alphabet")
createFilterOption("ShortDist", "ShortDist")
createFilterOption("LongDist", "LongDist")
createFilterOption("RecentStalk", "RecentStalk")
 
filterOptionsFrame.Size = UDim2.new(0, 120, 0, (#filterOptions * 30) + 4)
 
-- SCROLLING FRAME (LISTA DE PLAYERS)
local scrollingFrame = Instance.new("ScrollingFrame", frame)
scrollingFrame.Size = UDim2.new(1, 0, 0, 200) -- Altura fixa
scrollingFrame.Position = UDim2.new(0, 0, 0, 60)
-- AutomaticCanvasSize DESATIVADO para evitar bugs de sumiço
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None 
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
scrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
 
local listLayout = Instance.new("UIListLayout", scrollingFrame)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.FillDirection = Enum.FillDirection.Vertical
 
-- Placeholder para quando a lista estiver vazia
local emptyLabel = Instance.new("TextLabel", scrollingFrame)
emptyLabel.Name = "EmptyLabel"
emptyLabel.Size = UDim2.new(1, 0, 0, 50)
emptyLabel.Text = "Nobody was here..."
emptyLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
emptyLabel.BackgroundTransparency = 1
emptyLabel.Font = Enum.Font.Gotham
emptyLabel.Visible = false
emptyLabel.LayoutOrder = 9999
 
local playerTemplate = Instance.new("TextButton")
playerTemplate.Name = "PlayerTemplate"
playerTemplate.Size = UDim2.new(1, 0, 0, 45) 
playerTemplate.BackgroundColor3 = DEFAULT_COLOR
playerTemplate.Text = "" 
playerTemplate.BorderSizePixel = 0
playerTemplate.AutoButtonColor = true
 
local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 4)
playerCorner.Parent = playerTemplate
 
local avatarImage = Instance.new("ImageLabel", playerTemplate)
avatarImage.Name = "Avatar"
avatarImage.Size = UDim2.new(0, 35, 0, 35)
avatarImage.Position = UDim2.new(0, 5, 0.5, -17.5)
avatarImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
avatarImage.ScaleType = Enum.ScaleType.Fit
avatarImage.Image = "rbxassetid://1526372134" 
avatarImage.BorderSizePixel = 0
 
local nameLabel = Instance.new("TextLabel", playerTemplate)
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(0.75, 0, 1, 0)
nameLabel.Position = UDim2.new(0, 45, 0, 0)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.Gotham
nameLabel.BorderSizePixel = 0
 
-- MAIN GUI BUTTONS (POSICIONADOS MAIS PARA CIMA)
local startY = 265
local btnHeight = 35
local padding = 5
 
local configBtn = Instance.new("TextButton", frame)
configBtn.Name = "ConfigButton"
configBtn.Size = UDim2.new(0.9, 0, 0, btnHeight)
configBtn.Position = UDim2.new(0.05, 0, 0, startY)
configBtn.Text = "SETTINGS"
configBtn.TextScaled = true
configBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
configBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
configBtn.Font = Enum.Font.GothamBold
configBtn.BorderSizePixel = 0
 
local configCorner = Instance.new("UICorner")
configCorner.CornerRadius = UDim.new(0, 4)
configCorner.Parent = configBtn
 
local configStroke = Instance.new("UIStroke")
configStroke.Color = Color3.fromRGB(100, 100, 100)
configStroke.Thickness = 0.5
configStroke.Parent = configBtn
 
startY = startY + btnHeight + padding
 
local viewTargetBtn = Instance.new("TextButton", frame)
viewTargetBtn.Name = "ViewTargetButton"
viewTargetBtn.Size = UDim2.new(0.9, 0, 0, btnHeight)
viewTargetBtn.Position = UDim2.new(0.05, 0, 0, startY)
viewTargetBtn.Text = "VIEW"
viewTargetBtn.TextScaled = true
viewTargetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
viewTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
viewTargetBtn.Font = Enum.Font.GothamBold
viewTargetBtn.BorderSizePixel = 0
 
local viewCorner = Instance.new("UICorner")
viewCorner.CornerRadius = UDim.new(0, 4)
viewCorner.Parent = viewTargetBtn
 
local viewStroke = Instance.new("UIStroke")
viewStroke.Color = Color3.fromRGB(100, 100, 100)
viewStroke.Thickness = 0.5
viewStroke.Parent = viewTargetBtn
 
startY = startY + btnHeight + padding
 
local stalkBtn = Instance.new("TextButton", frame)
stalkBtn.Name = "StalkButton"
stalkBtn.Size = UDim2.new(0.9, 0, 0, btnHeight)
stalkBtn.Position = UDim2.new(0.05, 0, 0, startY)
stalkBtn.Text = "STALK"
stalkBtn.TextScaled = true
stalkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
stalkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stalkBtn.Font = Enum.Font.GothamBold
stalkBtn.BorderSizePixel = 0
 
local stalkCorner = Instance.new("UICorner")
stalkCorner.CornerRadius = UDim.new(0, 4)
stalkCorner.Parent = stalkBtn
 
local stalkStroke = Instance.new("UIStroke")
stalkStroke.Color = Color3.fromRGB(100, 100, 100)
stalkStroke.Thickness = 0.5
stalkStroke.Parent = stalkBtn
 
startY = startY + btnHeight + padding
 
local shadowStalkBtn = Instance.new("TextButton", frame)
shadowStalkBtn.Name = "ShadowStalkButton"
shadowStalkBtn.Size = UDim2.new(0.9, 0, 0, btnHeight)
shadowStalkBtn.Position = UDim2.new(0.05, 0, 0, startY)
shadowStalkBtn.Text = "SHADOW STALK"
shadowStalkBtn.TextScaled = true
shadowStalkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shadowStalkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shadowStalkBtn.Font = Enum.Font.GothamBold
shadowStalkBtn.BorderSizePixel = 0
 
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 4)
shadowCorner.Parent = shadowStalkBtn
 
local shadowStroke = Instance.new("UIStroke")
shadowStroke.Color = Color3.fromRGB(100, 100, 100)
shadowStroke.Thickness = 0.5
shadowStroke.Parent = shadowStalkBtn
 
startY = startY + btnHeight + padding 
 
local clickTPBtn = Instance.new("TextButton", frame)
clickTPBtn.Name = "ClickTPButton"
clickTPBtn.Size = UDim2.new(0.9, 0, 0, btnHeight)
clickTPBtn.Position = UDim2.new(0.05, 0, 0, startY)
clickTPBtn.Text = "CLICK TP"
clickTPBtn.TextScaled = true
clickTPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
clickTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickTPBtn.Font = Enum.Font.GothamBold
clickTPBtn.BorderSizePixel = 0
 
local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0, 4)
clickCorner.Parent = clickTPBtn
 
local clickStroke = Instance.new("UIStroke")
clickStroke.Color = Color3.fromRGB(100, 100, 100)
clickStroke.Thickness = 0.5
clickStroke.Parent = clickTPBtn
 
startY = startY + btnHeight + padding
 
local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Name = "RefreshButton"
refreshBtn.Size = UDim2.new(0.43, 0, 0, btnHeight)
refreshBtn.Position = UDim2.new(0.05, 0, 0, startY)
refreshBtn.Text = "REFRESH"
refreshBtn.TextScaled = true
refreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
refreshBtn.TextColor3 = Color3.fromRGB(100, 50, 255)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.BorderSizePixel = 0
 
local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 4)
refreshCorner.Parent = refreshBtn
 
local refreshStroke = Instance.new("UIStroke")
refreshStroke.Color = Color3.fromRGB(100, 100, 100)
refreshStroke.Thickness = 0.5
refreshStroke.Parent = refreshBtn
 
local destroyBtn = Instance.new("TextButton", frame)
destroyBtn.Name = "DestroyButton"
destroyBtn.Size = UDim2.new(0.43, 0, 0, btnHeight)
destroyBtn.Position = UDim2.new(0.52, 0, 0, startY)
destroyBtn.Text = "DESTROY"
destroyBtn.TextScaled = true
destroyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
destroyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.BorderSizePixel = 0
 
local destroyCorner = Instance.new("UICorner")
destroyCorner.CornerRadius = UDim.new(0, 4)
destroyCorner.Parent = destroyBtn
 
local destroyStroke = Instance.new("UIStroke")
destroyStroke.Color = Color3.fromRGB(100, 100, 100)
destroyStroke.Thickness = 0.5
destroyStroke.Parent = destroyBtn
 
local mainElements = {scrollingFrame, viewTargetBtn, stalkBtn, shadowStalkBtn, clickTPBtn, refreshBtn, destroyBtn, searchBox, filterBtn, configBtn}
 
-- ========================================================================
-- II. SETTINGS FRAME
-- ========================================================================
local settingsFrame = Instance.new("Frame", frame)
settingsFrame.Name = "SettingsFrame"
settingsFrame.Size = UDim2.new(1, 0, 0, 320)
settingsFrame.Position = UDim2.new(0, 0, 0, 60)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
settingsFrame.Visible = false 
settingsFrame.BorderSizePixel = 0
 
local settingsScrolling = Instance.new("ScrollingFrame", settingsFrame)
settingsScrolling.Size = UDim2.new(1, 0, 1, -100)
settingsScrolling.Position = UDim2.new(0, 0, 0, 0)
settingsScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsScrolling.BackgroundTransparency = 1
settingsScrolling.BorderSizePixel = 0
settingsScrolling.ScrollBarThickness = 4
settingsScrolling.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
 
local settingsLayout = Instance.new("UIListLayout", settingsScrolling)
settingsLayout.Padding = UDim.new(0, 5)
settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
settingsLayout.FillDirection = Enum.FillDirection.Vertical
 
local function createSettingInput(parent, settingName, initialValue)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(0.95, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
 
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = settingName
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.BorderSizePixel = 0
 
    local input = Instance.new("TextBox", container)
    input.Name = settingName:gsub(" ", ""):gsub("[^%w_]", "") 
    input.Size = UDim2.new(0.35, 0, 1, 0)
    input.Position = UDim2.new(0.65, 0, 0, 0)
    input.Text = tostring(initialValue)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.Font = Enum.Font.Gotham
    input.TextSize = 11
    input.ClearTextOnFocus = false
    input.BorderSizePixel = 0
 
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(80, 80, 80)
    inputStroke.Thickness = 0.5
    inputStroke.Parent = input
 
    return input
end
 
local fovInput = createSettingInput(settingsScrolling, "FOV Angle:", stalkFOVdeg)
local escapeInput = createSettingInput(settingsScrolling, "Escape Distance:", escapeMaxDistance)
local tpMaxInput = createSettingInput(settingsScrolling, "Stalk Distance:", maxStalkDistance)
local tpBehindInput = createSettingInput(settingsScrolling, "Behind Distance:", stalkBehindDistance)
local riseSpeedInput = createSettingInput(settingsScrolling, "Rise Speed:", riseSpeed)
local descendSpeedInput = createSettingInput(settingsScrolling, "Descend Speed:", descendSpeed)
local shadowMaxRiseInput = createSettingInput(settingsScrolling, "Shadow Max Rise:", shadowMaxRise)
local undergroundDepthInput = createSettingInput(settingsScrolling, "Underground Depth:", shadowUndergroundDepth)
 
local applyBtn = Instance.new("TextButton", settingsFrame)
applyBtn.Name = "ApplyButton"
applyBtn.Size = UDim2.new(0.9, 0, 0, 30)
applyBtn.Position = UDim2.new(0.05, 0, 1, -70)
applyBtn.Text = "APPLY"
applyBtn.TextScaled = true
applyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
applyBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.BorderSizePixel = 0
 
local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 4)
applyCorner.Parent = applyBtn
 
local applyStroke = Instance.new("UIStroke")
applyStroke.Color = Color3.fromRGB(100, 100, 100)
applyStroke.Thickness = 0.5
applyStroke.Parent = applyBtn
 
local backBtnSettings = Instance.new("TextButton", settingsFrame) 
backBtnSettings.Name = "BackButtonSettings"
backBtnSettings.Size = UDim2.new(0.9, 0, 0, 30)
backBtnSettings.Position = UDim2.new(0.05, 0, 1, -35)
backBtnSettings.Text = "BACK"
backBtnSettings.TextScaled = true
backBtnSettings.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
backBtnSettings.TextColor3 = Color3.fromRGB(255, 255, 255)
backBtnSettings.Font = Enum.Font.GothamBold
backBtnSettings.BorderSizePixel = 0
 
local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 4)
backCorner.Parent = backBtnSettings
 
local backStroke = Instance.new("UIStroke")
backStroke.Color = Color3.fromRGB(100, 100, 100)
backStroke.Thickness = 0.5
backStroke.Parent = backBtnSettings
 
-- ========================================================================
-- III. GAME LOGIC
-- ========================================================================
 
local character
local hrp
local hum
 
local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    hrp = character:WaitForChild("HumanoidRootPart")
    hum = character:FindFirstChildOfClass("Humanoid")
end
 
updateCharacter()
 
player.CharacterAdded:Connect(function(newCharacter)
    if stalking then stopStalk() end
    if viewingTarget then stopView() end 
    if TPToggle then toggleClickTP() end
    if shadowStalking then stopShadowStalk() end
    updateCharacter()
end)
 
-- HELPER: TOGGLE DEFAULT ANIMATION SCRIPT
local function toggleAnimateScript(enable)
    if character then
        local animScript = character:FindFirstChild("Animate")
        if animScript and animScript:IsA("LocalScript") then
            animScript.Disabled = not enable
        end
    end
end
 
local function setStalkerState(isStalking)
    if not character or not hrp then return end
 
    local transparencyValue = 0 
    local canCollideValue = not isStalking         
 
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("SpecialMesh") then
            if part.Name ~= "HumanoidRootPart" then 
                pcall(function() part.LocalTransparencyModifier = transparencyValue end) 
            end
            pcall(function() part.CanCollide = canCollideValue end) 
        elseif part:IsA("Shirt") or part:IsA("Pants") then
            pcall(function() part.Transparency = transparencyValue end)
        end
    end
 
    if hum then
        hum.PlatformStand = false
    end
end
 
local function getSafeCFrame(desiredPosition, currentCFrame)
    local rayOrigin = Vector3.new(desiredPosition.X, desiredPosition.Y + TP_CHECK_HEIGHT, desiredPosition.Z)
    local rayDirection = Vector3.new(0, -TP_RAY_LENGTH, 0)
 
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character} 
 
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
 
    if rayResult then
        local safeY = rayResult.Position.Y + 2.5 
 
        local lookVector = currentCFrame.LookVector
        local upVector = currentCFrame.UpVector
 
        return CFrame.new(desiredPosition.X, safeY, desiredPosition.Z) * CFrame.fromMatrix(Vector3.new(), lookVector, upVector)
    else
        return CFrame.new(desiredPosition.X, desiredPosition.Y, desiredPosition.Z) 
    end
end
 
local function teleportStalk(desiredCFrame, targetHRP)
    if destroyed or not hrp or not targetHRP or not targetHRP.Parent then return end
 
    local targetY = targetHRP.Position.Y
    local finalPosition = Vector3.new(desiredCFrame.X, targetY, desiredCFrame.Z)
 
    local newCFrame = CFrame.new(finalPosition) * (desiredCFrame - desiredCFrame.Position)
 
    hrp.CFrame = newCFrame
end
 
local function addToRecent(pl)
    if table.find(recentStalked, pl) then
        table.remove(recentStalked, table.find(recentStalked, pl))
    end
    table.insert(recentStalked, 1, pl)
    if #recentStalked > 5 then
        table.remove(recentStalked)
    end
end
 
-- EMOTE KEEPER FUNCTION
local function getActiveEmote()
    if not hum then return nil end
    local tracks = hum:GetPlayingAnimationTracks()
    for i = #tracks, 1, -1 do
        local t = tracks[i]
        if t.Priority == Enum.AnimationPriority.Action or t.Priority == Enum.AnimationPriority.Movement then
            return t
        end
        if t.Animation and t.Animation.AnimationId and string.find(t.Animation.AnimationId, "rbxassetid") then
             return t
        end
    end
    return nil
end
 
-- ========================================================================
-- IV. VIEWING
-- ========================================================================
 
local function stopView()
    if not viewingTarget then return end
 
    viewingTarget = false
    viewTarget = nil
 
    if viewConn then
        viewConn:Disconnect()
        viewConn = nil
    end
 
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        Camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
        Camera.CameraType = Enum.CameraType.Custom
    else
        Camera.CameraSubject = nil
        Camera.CameraType = Enum.CameraType.Custom
    end
 
    if updateButtonsState then updateButtonsState() end
end
 
local function startView(pl)
    if destroyed or not pl or not pl.Character or not hrp then return end
 
    if viewingTarget then 
        stopView()  
        if viewTarget == pl then return end
    end
 
    local targHum = pl.Character:FindFirstChildOfClass("Humanoid")
    local targHRP = pl.Character:FindFirstChild("HumanoidRootPart")
    if not targHum and not targHRP then 
        if viewTargetBtn and viewTargetBtn.Parent then
            viewTargetBtn.Text = "ERROR"
            task.wait(1.0)
            updateButtonsState()
        end
        return  
    end
 
    viewingTarget = true
    viewTarget = pl
 
    if targHum then
        Camera.CameraSubject = targHum
        Camera.CameraType = Enum.CameraType.Custom
    else
        Camera.CameraSubject = nil
        Camera.CameraType = Enum.CameraType.Scriptable
        if viewConn then viewConn:Disconnect() end
        viewConn = RunService.RenderStepped:Connect(function()
            local ch = pl.Character
            local h = ch and ch:FindFirstChild("HumanoidRootPart")
            if h then
                local focus = h.Position
                local pos = focus + cameraOffset
                Camera.CFrame = CFrame.new(pos, focus)
            end
        end)
    end
 
    if updateButtonsState then updateButtonsState() end
end
 
-- ========================================================================
-- V. STALK
-- ========================================================================
 
local function stalkLoop() end
 
local function stopStalk()
    if not stalking then return end 
 
    stalking = false
    stalkTarget = nil
 
    -- [CORREÇÃO] NÃO REATIVA O ANIMATE SCRIPT SE TIVER EMOTE
    if savedEmoteTrack then
        savedEmoteTrack:Play()
    else
        toggleAnimateScript(true)
    end
 
    if originalCFrame and hrp then
        hrp.CFrame = getSafeCFrame(originalCFrame.Position, originalCFrame)
        originalCFrame = nil 
    end
 
    setStalkerState(false)  
 
    -- HARD PHYSICS RESET
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
        hum:ChangeState(Enum.HumanoidStateType.Landed)
    end
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        local rx, ry, rz = hrp.CFrame:ToOrientation()
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.fromOrientation(0, ry, 0)
    end
 
    if stalkConn then
        stalkConn:Disconnect()
        stalkConn = nil
    end
 
    if updateButtonsState then updateButtonsState() end
end
 
local function startStalk(pl)
    addToRecent(pl)
 
    if destroyed or not pl or not pl.Character or not hrp or not hum then return end
 
    if stalking and stalkTarget == pl then  
        stopStalk()
        return 
    end
 
    if stalking and stalkTarget ~= pl then  
        stopStalk() 
    end
 
    local targHRP = pl.Character:FindFirstChild("HumanoidRootPart")
    local targHum = pl.Character:FindFirstChildOfClass("Humanoid")
 
    if not (targHRP and targHum and targHum.Health > 0) then 
        if stalkBtn and stalkBtn.Parent then
            stalkBtn.Text = "ERROR"
            task.wait(1.5)
            updateButtonsState()
        end
        if updatePlayerList then updatePlayerList() end
        return 
    end
 
    savedEmoteTrack = getActiveEmote()
    
    -- [FIX] DESATIVAR O SCRIPT DE ANIMAÇÃO PADRÃO
    toggleAnimateScript(false)
 
    if not stalking then
        originalCFrame = hrp.CFrame
    end
 
    stalking = true
    stalkTarget = pl
 
    setStalkerState(true)
 
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local fovCos = math.cos(math.rad(stalkFOVdeg * 0.5))
 
    if stalkConn then stalkConn:Disconnect() end
 
    stalkLoop = function()
        if destroyed or not stalking or not stalkTarget or not hrp or not hum then  
            stopStalk() 
            return 
        end
 
        if savedEmoteTrack and not savedEmoteTrack.IsPlaying then
             savedEmoteTrack:Play()
        end
 
        local char = stalkTarget.Character
        if not char then
            stopStalk()
            return
        end
 
        targHRP = char:FindFirstChild("HumanoidRootPart")
        targHum = char:FindFirstChildOfClass("Humanoid")
 
        if not (targHRP and targHum and targHum.Health > 0) then  
            stopStalk() 
            return 
        end
 
        local targetHeadPos = targHRP.Position + Vector3.new(0, 1.5, 0)
        local distance = (hrp.Position - targHRP.Position).Magnitude
 
        local rayCeilingParams = RaycastParams.new()
        rayCeilingParams.FilterType = Enum.RaycastFilterType.Exclude
        rayCeilingParams.FilterDescendantsInstances = {stalkTarget.Character, character} 
 
        local rayCeilingResult = Workspace:Raycast(
            targetHeadPos,  
            Vector3.new(0, CEILING_CHECK_HEIGHT, 0),  
            rayCeilingParams
        )
 
        if rayCeilingResult and distance < maxStalkDistance then
             return
        end
 
        if distance > maxStalkDistance then
            local desiredCFrame = targHRP.CFrame * CFrame.new(0, 0, stalkBehindDistance)
            teleportStalk(desiredCFrame, targHRP)  
            return
        end
 
        local lookAtTarget = Vector3.new(targHRP.Position.X, hrp.Position.Y, targHRP.Position.Z)
        local newCFrame = CFrame.new(hrp.Position, lookAtTarget)
        hrp.CFrame = newCFrame
 
        local dirToMe = hrp.Position - targHRP.Position
        if dirToMe.Magnitude > 0.001 then
 
            local lookVector = targHRP.CFrame.LookVector
            local targetDirection = dirToMe.Unit 
            local dot = lookVector:Dot(targetDirection)
 
            if dot >= fovCos then  
                local rayMaxRange = 30  
                if distance > rayMaxRange then return end 
 
                local headPosition = targHRP.Position + Vector3.new(0, 1.5, 0)  
                local rayDirection = hrp.Position - headPosition
 
                rayParams.FilterDescendantsInstances = {stalkTarget.Character, character} 
 
                local rayResult = Workspace:Raycast(headPosition, rayDirection, rayParams)
 
                local isStalkerHit = rayResult and rayResult.Instance:IsDescendantOf(character)
                local isClearPath = not rayResult
 
                if isStalkerHit or isClearPath then
                    task.spawn(function()
                        if destroyed or not stalking or not stalkTarget or not stalkTarget.Character or not hrp then return end
                        local currHRP = stalkTarget.Character:FindFirstChild("HumanoidRootPart")
                        if not currHRP then return end
 
                        pcall(function() stalkConn:Disconnect() end)
                        stalkConn = nil
 
                        local offset = Vector3.new(math.random(-escapeMaxDistance, escapeMaxDistance), 0, math.random(-escapeMaxDistance, escapeMaxDistance))
                        local desiredFugaPos = currHRP.Position + offset
 
                        hrp.CFrame = getSafeCFrame(desiredFugaPos, CFrame.new(desiredFugaPos))
 
                        setStalkerState(true) 
 
                        stalkConn = RunService.RenderStepped:Connect(stalkLoop)
                    end)
                    return  
                end
            end
        end
    end
 
    stalkConn = RunService.RenderStepped:Connect(stalkLoop)
 
    if updateButtonsState then updateButtonsState() end
end
 
local function stopShadowStalk()
    if not shadowStalking then return end
 
    shadowStalking = false
    stalkTarget = nil
 
    -- [CORREÇÃO] MESMA LÓGICA DO STALK NORMAL
    if savedEmoteTrack then
        savedEmoteTrack:Play() 
    else
        toggleAnimateScript(true)
    end
 
    if originalCFrame and hrp then
        hrp.CFrame = getSafeCFrame(originalCFrame.Position, originalCFrame)
        originalCFrame = nil 
    end
 
    setStalkerState(false)  
 
    if shadowConn then
        shadowConn:Disconnect()
        shadowConn = nil
    end
 
    if shadowAnchor and shadowAnchor.Parent then shadowAnchor:Destroy() end
    shadowAnchor = nil
    anchorOffsetY = 0
    isRising = false
 
    if mobileQBtn then
        mobileQBtn:Destroy()
        mobileQBtn = nil
    end
 
    -- HARD PHYSICS RESET
    if hum then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.Landed)
        hum.WalkSpeed = shadowOriginalWalkSpeed or 16
        hum.AutoRotate = shadowOriginalAutoRotate ~= nil and shadowOriginalAutoRotate or true
        hum.Sit = false
    end
    shadowOriginalWalkSpeed = nil
    shadowOriginalAutoRotate = nil
    if hrp then
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        local rx, ry, rz = hrp.CFrame:ToOrientation()
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.fromOrientation(0, ry, 0)
    end
 
    if updateButtonsState then updateButtonsState() end
end
 
local function shadowStalkLoop() end
 
local function startShadowStalk(pl)
    addToRecent(pl)
 
    if destroyed or not pl or not pl.Character or not hrp or not hum then return end
 
    if shadowStalking and stalkTarget == pl then  
        stopShadowStalk()
        return 
    end
 
    if shadowStalking and stalkTarget ~= pl then  
        stopShadowStalk() 
    end
 
    local targHRP = pl.Character:FindFirstChild("HumanoidRootPart")
    local targHum = pl.Character:FindFirstChildOfClass("Humanoid")
 
    if not (targHRP and targHum and targHum.Health > 0) then 
        if shadowStalkBtn and shadowStalkBtn.Parent then
            shadowStalkBtn.Text = "ERROR"
            task.wait(1.5)
            updateButtonsState()
        end
        return 
    end
 
    savedEmoteTrack = getActiveEmote()
    
    -- [FIX] DESATIVAR O SCRIPT DE ANIMAÇÃO PADRÃO
    toggleAnimateScript(false)
 
    if not shadowStalking then
        originalCFrame = hrp.CFrame
    end
 
    shadowStalking = true
    stalkTarget = pl
 
    if stalking then
        stopStalk()
    end
    setStalkerState(true)
 
    if UserInputService.TouchEnabled then
        if mobileQBtn then mobileQBtn:Destroy() end
 
        mobileQBtn = Instance.new("TextButton")
        mobileQBtn.Name = "MobileQButton"
        mobileQBtn.Size = UDim2.new(0, 60, 0, 60)
        mobileQBtn.Position = UDim2.new(0.8, -20, 0.7, 0) 
        mobileQBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        mobileQBtn.Text = "Q"
        mobileQBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mobileQBtn.TextScaled = true
        mobileQBtn.Font = Enum.Font.GothamBold
        mobileQBtn.BorderSizePixel = 0
        mobileQBtn.Parent = gui 
 
        local cornerQ = Instance.new("UICorner")
        cornerQ.CornerRadius = UDim.new(1, 0) 
        cornerQ.Parent = mobileQBtn
 
        local strokeQ = Instance.new("UIStroke")
        strokeQ.Color = Color3.fromRGB(255, 255, 255)
        strokeQ.Thickness = 2
        strokeQ.Parent = mobileQBtn
 
        local dragging, dragInput, dragStart, startPos
        mobileQBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mobileQBtn.Position
 
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
 
        mobileQBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
 
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                mobileQBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
 
        local toggledQ = false
        mobileQBtn.MouseButton1Click:Connect(function()
            toggledQ = not toggledQ
            if toggledQ then
                isRising = true
                shouldDescend = false
                mobileQBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) 
            else
                isRising = false
                shouldDescend = true
                mobileQBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) 
            end
        end)
    end
 
    if shadowAnchor and shadowAnchor.Parent then shadowAnchor:Destroy() end
    local anchor = Instance.new("Part")
    anchor.Name = "ShadowAnchor"
    anchor.Size = Vector3.new(2, 2, 2)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.CanQuery = false
    anchor.Anchored = true
    anchor.Parent = Workspace
    shadowAnchor = anchor
    anchorOffsetY = -shadowUndergroundDepth
    if hum then
        shadowOriginalWalkSpeed = hum.WalkSpeed
        shadowOriginalAutoRotate = hum.AutoRotate
        hum.PlatformStand = true 
        hum.AutoRotate = false
        pcall(function() hum.WalkSpeed = 0 end)
 
        if savedEmoteTrack then
            savedEmoteTrack:Play()
        end
    end
    if hrp then
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
 
    if shadowConn then shadowConn:Disconnect() end
 
    if shadowConn then shadowConn:Disconnect() end
    shadowConn = RunService.RenderStepped:Connect(function(delta)
        if destroyed or not shadowStalking or not stalkTarget or not hrp or not hum or not shadowAnchor then  
            stopShadowStalk() 
            return 
        end
 
        if savedEmoteTrack and not savedEmoteTrack.IsPlaying then
             savedEmoteTrack:Play()
        end
 
        local char = stalkTarget.Character
        if not char then
            stopShadowStalk()
            return
        end
 
        local targHRP = char:FindFirstChild("HumanoidRootPart")
        local targHum = char:FindFirstChildOfClass("Humanoid")
        if not (targHRP and targHum and targHum.Health > 0) then  
            stopShadowStalk() 
            return 
        end
 
        local behindPos = targHRP.Position - targHRP.CFrame.LookVector * stalkBehindDistance
 
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char, character, shadowAnchor}
        local rayOrigin = targHRP.Position - Vector3.new(0, 1, 0)
        local rayDirection = Vector3.new(0, -TP_RAY_LENGTH, 0)
        local rayResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
        local groundY = rayResult and rayResult.Position.Y or behindPos.Y
 
        if isRising then
            anchorOffsetY = math.min(anchorOffsetY + riseSpeed * (delta or 0), shadowMaxRise)
            if anchorOffsetY >= shadowMaxRise then isRising = false end
        elseif shouldDescend then
            anchorOffsetY = math.max(anchorOffsetY - descendSpeed * (delta or 0), -shadowUndergroundDepth)
            if anchorOffsetY <= -shadowUndergroundDepth then shouldDescend = false end
        end
        anchorOffsetY = math.clamp(anchorOffsetY, -shadowUndergroundDepth, shadowMaxRise)
        local newAnchorPos = Vector3.new(behindPos.X, groundY + anchorOffsetY, behindPos.Z)
        shadowAnchor.CFrame = CFrame.new(newAnchorPos)
 
        local focus = Vector3.new(targHRP.Position.X, newAnchorPos.Y, targHRP.Position.Z)
        hrp.CFrame = CFrame.new(newAnchorPos, focus)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if hum then hum.AutoRotate = false end
    end)
 
    if updateButtonsState then updateButtonsState() end
end
 
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q and shadowStalking and shadowAnchor and shadowAnchor.Parent then
        if anchorOffsetY < shadowMaxRise then
            isRising = true
            shouldDescend = false
        else
            isRising = false
            shouldDescend = false
        end
    end
end)
 
UserInputService.InputEnded:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Q and shadowStalking and shadowAnchor and shadowAnchor.Parent and stalkTarget and stalkTarget.Character then
        isRising = false
        shouldDescend = true
    end
end)
 
-- ========================================================================
-- VI. CLICK TP TOOL
-- ========================================================================
 
local function toggleClickTP()
    if TPToggle then
        if TPTool then
            TPTool:Destroy()
            TPTool = nil
        end
        TPToggle = false
 
        if clickTPBtn and clickTPBtn.Parent then
            clickTPBtn.Text = "CLICK TP"
            clickTPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
 
    else
        local mouse = player:GetMouse()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Tp tool(Equip to Click TP)"
 
        tool.Activated:Connect(function()
            if destroyed or not hrp or not hrp.Parent then return end 
 
            local desiredPos = mouse.Hit.Position
            local pos = getSafeCFrame(desiredPos, CFrame.new(desiredPos)) 
 
            hrp.CFrame = pos
        end)
 
        tool.AncestryChanged:Connect(function()
            if not tool.Parent or tool.Parent.Name ~= "Backpack" then
                if TPToggle then
                    task.spawn(function()
                        task.wait(0.1)
                        if tool and not tool.Parent then 
                             toggleClickTP() 
                        end
                    end)
                end
            end
        end)
 
        tool.Parent = player.Backpack
        TPTool = tool
        TPToggle = true
 
        if clickTPBtn and clickTPBtn.Parent then
            clickTPBtn.Text = "ACTIVE"
            clickTPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
end
 
-- ========================================================================
-- VII. GUI FUNCTIONS
-- ========================================================================
 
-- NOVA FUNÇÃO CENTRALIZADA PARA ATUALIZAR O TEXTO DOS BOTÕES
updateButtonsState = function()
    if not stalkBtn or not stalkBtn.Parent then return end
 
    -- Se não tiver player selecionado, reseta tudo
    if not selectedPlayer then
        stalkBtn.Text = "STALK"
        stalkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        shadowStalkBtn.Text = "SHADOW STALK"
        shadowStalkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        viewTargetBtn.Text = "VIEW"
        viewTargetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        return
    end
 
    -- LÓGICA UNIFICADA DE PARADA
    -- Se qualquer stalk (Normal ou Shadow) estiver ativo no jogador selecionado, AMBOS mostram STOP.
    local isStalkingActiveOnSelected = (stalking and stalkTarget == selectedPlayer) or (shadowStalking and stalkTarget == selectedPlayer)
 
    if isStalkingActiveOnSelected then
        stalkBtn.Text = "STOP"
        stalkBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
 
        shadowStalkBtn.Text = "STOP"
        shadowStalkBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        stalkBtn.Text = "STALK"
        stalkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
 
        shadowStalkBtn.Text = "SHADOW STALK"
        shadowStalkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
 
    -- VIEW BUTTON (Lógica separada pois View é independente)
    if viewingTarget and viewTarget == selectedPlayer then
        viewTargetBtn.Text = "STOP"
        viewTargetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        viewTargetBtn.Text = "VIEW"
        viewTargetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end
 
local function applySettings()
    local newFov = tonumber(fovInput.Text)
    local newFugaMax = tonumber(escapeInput.Text)
    local newTPMax = tonumber(tpMaxInput.Text)
    local newTPBehind = tonumber(tpBehindInput.Text)
    local newRiseSpeed = tonumber(riseSpeedInput.Text)
    local newDescendSpeed = tonumber(descendSpeedInput.Text)
    local newShadowMaxRise = tonumber(shadowMaxRiseInput.Text)
    local newUndergroundDepth = tonumber(undergroundDepthInput.Text)
 
    if newFov and newFov >= 1 and newFov <= 180 then
        stalkFOVdeg = newFov
    else
        fovInput.Text = "?"
    end
 
    if newFugaMax and newFugaMax >= 1 then
        escapeMaxDistance = newFugaMax
    else
        escapeInput.Text = "?"
    end
 
    if newTPMax and newTPMax >= 1 then
        maxStalkDistance = newTPMax
    else
        tpMaxInput.Text = "?"
    end
 
    if newTPBehind and newTPBehind >= 1 then
        stalkBehindDistance = newTPBehind
    else
        tpBehindInput.Text = "?"
    end
 
    if newRiseSpeed and newRiseSpeed >= 1 then
        riseSpeed = newRiseSpeed
    else
        riseSpeedInput.Text = "?"
    end
 
    if newDescendSpeed and newDescendSpeed >= 1 then
        descendSpeed = newDescendSpeed
    else
        descendSpeedInput.Text = "?"
    end
 
    if newShadowMaxRise and newShadowMaxRise >= 1 then
        shadowMaxRise = newShadowMaxRise
    else
        shadowMaxRiseInput.Text = "?"
    end
 
    if newUndergroundDepth and newUndergroundDepth >= 1 then
        shadowUndergroundDepth = newUndergroundDepth
    else
        undergroundDepthInput.Text = "?"
    end
 
    fovInput.Text = tostring(stalkFOVdeg)
    escapeInput.Text = tostring(escapeMaxDistance)
    tpMaxInput.Text = tostring(maxStalkDistance)
    tpBehindInput.Text = tostring(stalkBehindDistance)
    riseSpeedInput.Text = tostring(riseSpeed)
    descendSpeedInput.Text = tostring(descendSpeed)
    shadowMaxRiseInput.Text = tostring(shadowMaxRise)
    undergroundDepthInput.Text = tostring(shadowUndergroundDepth)
 
    if applyBtn and applyBtn.Parent then
        applyBtn.Text = "SAVED"
        task.wait(0.8)
        applyBtn.Text = "APPLY"
    end
end
 
local function toggleSettings()
    local isSettingsOpen = settingsFrame.Visible
 
    settingsFrame.Visible = not isSettingsOpen 
 
    for _, element in ipairs(mainElements) do
        element.Visible = isSettingsOpen 
    end
end
 
local function createPlayerItem(pl)
    local item = playerTemplate:Clone()
    item.Name = pl.Name
 
    local nameLabel = item:FindFirstChild("NameLabel")
    nameLabel.Text = string.format("%s\n(%s)", pl.DisplayName, pl.Name)
 
    local avatarImage = item:FindFirstChild("Avatar")
    if pl.UserId then
        local content = "rbxthumb://type=AvatarHeadShot&id=" .. pl.UserId .. "&w=48&h=48"
        avatarImage.Image = content
    end
 
    item.MouseButton1Click:Connect(function()
        if type(selectPlayer) == "function" then
            local ok = pcall(selectPlayer, pl, item)
            if not ok and item and item.Parent then
                item.BackgroundColor3 = DEFAULT_COLOR
            end
        else
            for _, child in ipairs(scrollingFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = DEFAULT_COLOR
                end
            end
            selectedPlayer = pl
            lastSelectedItem = item
            if item and item.Parent then
                item.BackgroundColor3 = SELECTED_COLOR
            end
        end
    end)
 
    item.Parent = scrollingFrame
    return item
end
 
selectPlayer = function(pl, item)
    if selectedPlayer == pl then
        -- Deselect
        selectedPlayer = nil
        if lastSelectedItem then lastSelectedItem.BackgroundColor3 = DEFAULT_COLOR end
        lastSelectedItem = nil
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = DEFAULT_COLOR
            end
        end
        updateButtonsState()
    else
        -- Select New
        if lastSelectedItem then
            lastSelectedItem.BackgroundColor3 = DEFAULT_COLOR
        end
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = DEFAULT_COLOR
            end
        end
        selectedPlayer = pl
        lastSelectedItem = item
        item.BackgroundColor3 = SELECTED_COLOR
        updateButtonsState()
    end
end
 
updatePlayerList = function()
    local currentlyStalked = stalkTarget
    local currentlyViewing = viewTarget
 
    if not scrollingFrame or not scrollingFrame.Parent then return end
 
    for _, item in ipairs(scrollingFrame:GetChildren()) do
        if item:IsA("TextButton") then
            item:Destroy()
        end
    end
 
    if selectedPlayer and not Players:FindFirstChild(selectedPlayer.Name) then
        selectedPlayer = nil
        lastSelectedItem = nil
    end
 
    local players = Players:GetPlayers()
    local playerList = {}
 
    for _, pl in ipairs(players) do
        if pl ~= player and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid") and pl.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            table.insert(playerList, pl)
        end
    end
 
    local searchText = searchBox.Text:lower()
 
    local filteredPlayers = {}
    for _, pl in ipairs(playerList) do
        if searchText == "" or string.find(pl.Name:lower(), searchText) or string.find(pl.DisplayName:lower(), searchText) then
            table.insert(filteredPlayers, pl)
        end
    end
 
    if sortMode == "Alphabet" then
 
        table.sort(filteredPlayers, function(a, b) return a.Name:lower() < b.Name:lower() end)
    elseif sortMode == "ShortDist" then
        table.sort(filteredPlayers, function(a, b)
            local distA = hrp and a.Character and a.Character:FindFirstChild("HumanoidRootPart") and (hrp.Position - a.Character.HumanoidRootPart.Position).Magnitude or math.huge
            local distB = hrp and b.Character and b.Character:FindFirstChild("HumanoidRootPart") and (hrp.Position - b.Character.HumanoidRootPart.Position).Magnitude or math.huge
            return distA < distB
        end)
    elseif sortMode == "LongDist" then
        table.sort(filteredPlayers, function(a, b)
            local distA = hrp and a.Character and a.Character:FindFirstChild("HumanoidRootPart") and (hrp.Position - a.Character.HumanoidRootPart.Position).Magnitude or math.huge
            local distB = hrp and b.Character and b.Character:FindFirstChild("HumanoidRootPart") and (hrp.Position - b.Character.HumanoidRootPart.Position).Magnitude or math.huge
            return distA > distB
        end)
    elseif sortMode == "RecentStalk" then
        filteredPlayers = {}
        for _, pl in ipairs(recentStalked) do
            if table.find(playerList, pl) then
                table.insert(filteredPlayers, pl)
            end
        end
    end
 
    local playerCount = 0
    for _, pl in ipairs(filteredPlayers) do
        createPlayerItem(pl)
        playerCount = playerCount + 1
    end
 
    if emptyLabel and emptyLabel.Parent then
        if playerCount == 0 then
            emptyLabel.Visible = true
        else
            emptyLabel.Visible = false
        end
    end
 
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, playerCount * 50) 
 
    if selectedPlayer then
        for _, item in ipairs(scrollingFrame:GetChildren()) do
             if item.Name == selectedPlayer.Name then
                lastSelectedItem = item
                item.BackgroundColor3 = SELECTED_COLOR
                break
             end
        end
    end
 
    updateButtonsState()
end
 
-- ========================================================================
-- VIII. CONNECTIONS (STATIC LIST = NO AUTO REFRESH)
-- ========================================================================
 
task.spawn(function()
    task.wait(1) 
    if updatePlayerList then updatePlayerList() end
    task.wait(2)
    if updatePlayerList then updatePlayerList() end
end)
 
-- LÓGICA DE CLIQUE ATUALIZADA
stalkBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        if stalkBtn and stalkBtn.Parent then
            stalkBtn.Text = "ERROR"
            task.wait(1.0)
            updateButtonsState()
        end
        return
    end
 
    local ok, err = pcall(function()
        -- Se já estiver stalkeando ESTE jogador (seja normal ou shadow), PARAR TUDO.
        if (stalking or shadowStalking) and selectedPlayer == stalkTarget then
            stopStalk()
            stopShadowStalk()
        else
            -- Se não estiver stalkeando ninguem, OU se estiver stalkeando OUTRO -> Iniciar normal
            startStalk(selectedPlayer)
        end
        updateButtonsState()
    end)
 
    if not ok then
        if stalkBtn and stalkBtn.Parent then
            stalkBtn.Text = "ERROR"
            task.wait(1.0)
            updateButtonsState()
        end
    end
end)
 
shadowStalkBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        if shadowStalkBtn and shadowStalkBtn.Parent then
            shadowStalkBtn.Text = "ERROR"
            task.wait(1.0)
            updateButtonsState()
        end
        return
    end
 
    local ok, err = pcall(function()
        -- Se já estiver stalkeando ESTE jogador (seja normal ou shadow), PARAR TUDO.
        if (shadowStalking or stalking) and selectedPlayer == stalkTarget then
            stopShadowStalk()
            stopStalk()
        else
            -- Iniciar Shadow
            startShadowStalk(selectedPlayer)
        end
        updateButtonsState()
    end)
 
    if not ok then
        if shadowStalkBtn and shadowStalkBtn.Parent then
            shadowStalkBtn.Text = "ERROR"
            task.wait(1.0)
            updateButtonsState()
        end
    end
end)
 
viewTargetBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        if viewTargetBtn and viewTargetBtn.Parent then
            viewTargetBtn.Text = "ERROR"
            task.wait(1.0)
            updateButtonsState()
        end
        return
    end
    local ok, err = pcall(function()
        if viewingTarget and selectedPlayer == viewTarget then
            stopView()
        else
            startView(selectedPlayer)
        end
        updateButtonsState()
    end)
    if not ok then
        if viewTargetBtn and viewTargetBtn.Parent then
            viewTargetBtn.Text = "ERROR"
            task.wait(1.0)
            updateButtonsState()
        end
    end
end)
 
refreshBtn.MouseButton1Click:Connect(function() if updatePlayerList then updatePlayerList() end end)
clickTPBtn.MouseButton1Click:Connect(toggleClickTP) 
 
configBtn.MouseButton1Click:Connect(toggleSettings) 
backBtnSettings.MouseButton1Click:Connect(toggleSettings) 
 
applyBtn.MouseButton1Click:Connect(applySettings)
 
local function setupInputListeners(inputField)
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            applySettings()
        end
    end)
end
 
setupInputListeners(fovInput)
setupInputListeners(escapeInput)
setupInputListeners(tpMaxInput)
setupInputListeners(tpBehindInput)
setupInputListeners(riseSpeedInput)
setupInputListeners(descendSpeedInput)
setupInputListeners(shadowMaxRiseInput)
setupInputListeners(undergroundDepthInput)
 
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if updatePlayerList then updatePlayerList() end
end)
 
filterBtn.MouseButton1Click:Connect(function()
    if filterOptionsFrame.Visible then
        filterOptionsFrame.Visible = false
    else
        filterOptionsFrame.Visible = true
    end
end)
 
destroyBtn.MouseButton1Click:Connect(function()
    destroyed = true
    stopStalk()
    stopView() 
    stopShadowStalk()
    if TPTool then 
        TPTool:Destroy() 
    end
    if gui and gui.Parent then
        gui:Destroy()
    end
end)
 
-- ========================================================================
-- IX. MINIMIZE (FIXED NIL ERROR)
-- ========================================================================
 
local function animateResize(target, startSize, endSize, duration)
    local startTime = tick()
 
    local connection = nil 
 
    connection = RunService.Heartbeat:Connect(function()
 
        if not target or not target.Parent or destroyed then 
            if connection and connection.Connected then 
                connection:Disconnect()
            end
            return
        end
 
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)
 
        local currentX = startSize.X.Scale + (endSize.X.Scale - startSize.X.Scale) * progress
        local currentY = startSize.Y.Offset + (endSize.Y.Offset - startSize.Y.Offset) * progress
 
        target.Size = UDim2.new(currentX, 0, 0, currentY)
 
        if progress >= 1 then
            if connection and connection.Connected then 
                connection:Disconnect()
            end
            target.Size = endSize
        end
    end)
end
 
minimizeBtn.MouseButton1Click:Connect(function()
    if not frame or not frame.Parent then return end -- Extra check for safety
 
    isMinimized = not isMinimized
 
    if isMinimized then
        minimizeBtn.Text = "+"
 
        local elementsToFade = {scrollingFrame, viewTargetBtn, stalkBtn, shadowStalkBtn, clickTPBtn, refreshBtn, destroyBtn, configBtn, searchBox, filterBtn}
 
        for _, elem in ipairs(elementsToFade) do
            if elem and elem.Parent then elem.Visible = false end
        end
        settingsFrame.Visible = false
 
        animateResize(frame, UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT), UDim2.new(0, GUI_WIDTH, 0, 30), 0.4)
    else
        minimizeBtn.Text = "−"
 
        animateResize(frame, UDim2.new(0, GUI_WIDTH, 0, 30), UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT), 0.4)
 
        task.wait(0.4)
        scrollingFrame.Visible = true
        viewTargetBtn.Visible = true
        stalkBtn.Visible = true
        shadowStalkBtn.Visible = true
        clickTPBtn.Visible = true
        refreshBtn.Visible = true
        destroyBtn.Visible = true
        configBtn.Visible = true
        searchBox.Visible = true
        filterBtn.Visible = true
    end
end)
 
-- ========================================================================
-- X. DISTANCE LOOP & ANTI-EMOTE GLITCH
-- ========================================================================
 
local function startDistanceLoop()
    task.spawn(function()
        while not destroyed do
            if scrollingFrame and scrollingFrame.Parent then
                for _, item in ipairs(scrollingFrame:GetChildren()) do
                    if item:IsA("TextButton") then
                        local plName = item.Name
                        local pl = Players:FindFirstChild(plName)
 
                        if pl and hrp and hrp.Parent and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                             local dist = math.floor((hrp.Position - pl.Character.HumanoidRootPart.Position).Magnitude)
                             local label = item:FindFirstChild("NameLabel")
                             if label then
                                 label.Text = string.format("%s\n(%s) (%d studs)", pl.DisplayName, pl.Name, dist)
                             end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end
 
startDistanceLoop()
 
-- ANTI-EMOTE GLITCH (SÓ LIMPA SE O JOGADOR ANDAR)
-- Se você sair do Stalk, o emote continua.
-- Se você apertar W/A/S/D, aí sim ele é cancelado para você não andar torto.
local wasMoving = false
RunService.Heartbeat:Connect(function()
    if destroyed or stalking or shadowStalking or not hum then return end
 
    local isMoving = hum.MoveDirection.Magnitude > 0.1
 
    -- Se começou a andar agora e antes estava parado
    if isMoving and not wasMoving then
        
        -- [FIX] REATIVA O ANIMATE SCRIPT
        toggleAnimateScript(true)
        
        -- Percorre todas as animações e para as que NÃO são do sistema (Core)
        -- Isso cancela o emote e permite que a animação de andar flua limpa
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            if track.Priority ~= Enum.AnimationPriority.Core then
                track:Stop()
            end
        end
    end
 
    wasMoving = isMoving
end)