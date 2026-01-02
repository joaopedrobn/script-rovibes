local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScriptURL = "https://raw.githubusercontent.com/joaopedrobn/script-rovibes/main/main.lua"
local ConfigName = "JR_HUB_Config.json"

getgenv().Settings = table.clear(getgenv().Settings or {})
getgenv().Settings = {
    AutoFarm = false,
    TargetName = "LightTemplate",
    TPDelay = 1.0,
    AutoServerHop = false,
    ESP_Enabled = false,
    ESP_Highlight = true,
    ESP_Names = true,
    ESP_Face = true,
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedEnabled = false,
    JumpEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50,
    SpinBot = false,
    WalkMode = false,
    StickTarget = false,
    SpectateTarget = false,
    Fullbright = false,
    NoBlur = false
}

getgenv().AutoFarm_Rejoined = nil
getgenv().ChestIndex = 1
getgenv().BoneIndex = 1

local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(255, 60, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    ControlHover = Color3.fromRGB(50, 50, 50)
}

if CoreGui:FindFirstChild("JR_HUB") then CoreGui.JR_HUB:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JR_HUB"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Theme.Accent
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarFiller = Instance.new("Frame")
TitleBarFiller.Name = "Filler"
TitleBarFiller.Size = UDim2.new(1, 0, 0, 10)
TitleBarFiller.Position = UDim2.new(0, 0, 1, -10)
TitleBarFiller.BackgroundColor3 = Theme.Accent
TitleBarFiller.BorderSizePixel = 0
TitleBarFiller.Parent = TitleBar

local MiniFrame = Instance.new("TextButton")
MiniFrame.Name = "MiniFrame"
MiniFrame.Size = UDim2.new(0, 150, 0, 30)
MiniFrame.Position = UDim2.new(0.5, -75, 0.1, 0)
MiniFrame.BackgroundColor3 = Theme.Sidebar
MiniFrame.BorderSizePixel = 0
MiniFrame.Text = "HUB"
MiniFrame.TextColor3 = Theme.Accent
MiniFrame.Font = Enum.Font.GothamBold
MiniFrame.TextSize = 14
MiniFrame.Visible = false
MiniFrame.AutoButtonColor = true
MiniFrame.Parent = ScreenGui

local MiniDrag = Instance.new("UICorner")
MiniDrag.CornerRadius = UDim.new(0, 6)
MiniDrag.Parent = MiniFrame

local dragging, dragInput, dragStart, startPos
MiniFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MiniFrame.Position
    end
end)
MiniFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MiniFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MiniFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

MiniFrame.MouseButton1Click:Connect(function()
    MiniFrame.Visible = false
    MainFrame.Visible = true
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -32)
Sidebar.Position = UDim2.new(0, 0, 0, 32)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 6)
SidebarCorner.Parent = Sidebar

local SidebarFix = Instance.new("Frame")
SidebarFix.BorderSizePixel = 0
SidebarFix.BackgroundColor3 = Theme.Sidebar
SidebarFix.Size = UDim2.new(0, 10, 1, 0)
SidebarFix.Position = UDim2.new(1, -10, 0, 0)
SidebarFix.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Text = "HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.Accent
Title.TextSize = 22
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -60)
TabContainer.Position = UDim2.new(0, 0, 0, 60)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = TabContainer

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -150, 1, -52)
ContentArea.Position = UDim2.new(0, 150, 0, 42)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local WindowControls = Instance.new("Frame")
WindowControls.Name = "WindowControls"
WindowControls.Size = UDim2.new(0, 40, 1, 0)
WindowControls.Position = UDim2.new(1, -40, 0, 0)
WindowControls.BackgroundTransparency = 1
WindowControls.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(1, 0, 1, 0)
MinBtn.BackgroundColor3 = Theme.Accent
MinBtn.BackgroundTransparency = 0
MinBtn.BorderSizePixel = 0
MinBtn.Text = "-"
MinBtn.TextColor3 = Theme.Text
MinBtn.Font = Enum.Font.Gotham
MinBtn.TextSize = 24
MinBtn.Parent = WindowControls

MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniFrame.Position = MainFrame.Position
    MiniFrame.Visible = true
end)

local Pages = Instance.new("Folder")
Pages.Name = "Pages"
Pages.Parent = ContentArea

local currentTab = nil

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = false
    Page.Parent = Pages
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.Parent = Page
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingLeft = UDim.new(0, 5)
    Padding.Parent = Page
    
    return Page
end

local function CreateTabBtn(name, pageObj)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.BackgroundColor3 = Theme.Background
    Btn.Text = name
    Btn.TextColor3 = Theme.TextDim
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = TabContainer
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim, BackgroundColor3 = Theme.Background}):Play()
            end
        end
        for _, child in ipairs(Pages:GetChildren()) do
            child.Visible = false
        end
        
        TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Theme.Accent, BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        pageObj.Visible = true
    end)
    
    if currentTab == nil then
        currentTab = Btn
        Btn.TextColor3 = Theme.Accent
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        pageObj.Visible = true
    end
end

local function CreateToggle(parent, text, callback, default)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.98, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
    ToggleBtn.Position = UDim2.new(0.9, -24, 0.5, -12)
    ToggleBtn.Text = ""
    ToggleBtn.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(60, 60, 60)
    ToggleBtn.Parent = Frame
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 4)
    TCorner.Parent = ToggleBtn
    
    local toggled = default or false
    
    ToggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end
        callback(toggled)
    end)
    return ToggleBtn
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.98, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Theme.TextDim
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 14
    ValueLabel.Size = UDim2.new(1, -20, 0, 25)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Text = ""
    SliderBar.Size = UDim2.new(0.9, 0, 0, 6)
    SliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBar.AutoButtonColor = false
    SliderBar.Parent = Frame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.Parent = SliderBar
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.Parent = Fill
    
    local dragging = false
    
    local function update(input)
        local SizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local Value = math.floor(min + ((max - min) * SizeX))
        
        TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
        ValueLabel.Text = tostring(Value)
        callback(Value)
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.98, 0, 0, 35)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateInput(parent, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.98, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.9, 0, 1, 0)
    Box.Position = UDim2.new(0.05, 0, 0, 0)
    Box.BackgroundTransparency = 1
    Box.TextColor3 = Theme.Text
    Box.PlaceholderText = placeholder
    Box.PlaceholderColor3 = Theme.TextDim
    Box.Text = ""
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.Parent = Frame
    
    Box.FocusLost:Connect(function(enter)
        callback(Box.Text)
    end)
end

local function TPToName(name)
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name:lower():find(name:lower()) then
            if v:IsA("Model") and LocalPlayer.Character then
                LocalPlayer.Character:PivotTo(v:GetPivot() + Vector3.new(0,3,0))
                return true
            elseif v:IsA("BasePart") and LocalPlayer.Character then
                LocalPlayer.Character:PivotTo(v.CFrame + Vector3.new(0,3,0))
                return true
            end
        end
    end
    return false
end

local Connections = {}
local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "ESP_Cache"

local function getTargets()
    local targets = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == getgenv().Settings.TargetName then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                table.insert(targets, obj)
            end
        end
    end
    return targets
end

local function getSortedTargets(term1, term2)
    local t = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            if v.Name:find(term1) or (term2 and v.Name:find(term2)) then
                table.insert(t, v)
            end
        end
    end
    table.sort(t, function(a,b) return a.Name < b.Name end)
    return t
end

local function toggleNoclip(state)
    if state then
        local conn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        getgenv().NoclipConnection = conn
    else
        if getgenv().NoclipConnection then
            getgenv().NoclipConnection:Disconnect()
            getgenv().NoclipConnection = nil
        end
    end
end

local function updateESP()
    ESP_Folder:ClearAllChildren()
    if not getgenv().Settings.ESP_Enabled then return end

    for _, obj in ipairs(getTargets()) do
        if obj then
            local h = Instance.new("Highlight")
            h.Adornee = obj
            h.FillColor = Color3.fromRGB(0, 255, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.5
            h.Parent = ESP_Folder
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if getgenv().Settings.ESP_Highlight then
                local h = Instance.new("Highlight")
                h.Adornee = plr.Character
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.5
                h.Parent = ESP_Folder
            end
            
            if getgenv().Settings.ESP_Names or getgenv().Settings.ESP_Face then
                local bb = Instance.new("BillboardGui")
                bb.Name = "Info"
                bb.Adornee = plr.Character.Head
                bb.Size = UDim2.new(0, 200, 0, 100)
                bb.StudsOffset = Vector3.new(0, 4, 0)
                bb.AlwaysOnTop = true
                bb.Parent = ESP_Folder
                
                local currentY = 0
                
                if getgenv().Settings.ESP_Face then
                    local icon = Instance.new("ImageLabel")
                    icon.Parent = bb
                    icon.BackgroundTransparency = 1
                    icon.Position = UDim2.new(0.5, -15, 0, currentY)
                    icon.Size = UDim2.new(0, 30, 0, 30)
                    task.spawn(function()
                        local content, isReady = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                        if isReady then icon.Image = content end
                    end)
                    currentY = currentY + 35
                end

                if getgenv().Settings.ESP_Names then
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Parent = bb
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Position = UDim2.new(0, 0, 0, currentY)
                    nameLabel.Size = UDim2.new(1, 0, 0, 20)
                    nameLabel.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
                    nameLabel.TextColor3 = Color3.new(1,1,1)
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 14
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        if getgenv().Settings.ESP_Enabled then pcall(updateESP) end
        task.wait(1)
    end
end)

local function StartFarmLogic()
    if getgenv().Settings.AutoFarm then
        toggleNoclip(true)
        task.spawn(function()
            while getgenv().Settings.AutoFarm do
                local lights = getTargets()
                if #lights == 0 and getgenv().Settings.AutoServerHop then
                    if queue_on_teleport then
                        queue_on_teleport([[
                            task.wait(2)
                            loadstring(game:HttpGet("]] .. ScriptURL .. [[?t="..tostring(math.random(1,1000000))))()
                        ]])
                    end
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    break
                end
                for _, obj in ipairs(lights) do
                    if not getgenv().Settings.AutoFarm then break end
                    local char = LocalPlayer.Character
                    if char then
                        local target = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
                        pcall(function() char:PivotTo(target + Vector3.new(0,3,0)) end)
                    end
                    task.wait(getgenv().Settings.TPDelay)
                end
                task.wait(0.1)
            end
            toggleNoclip(false)
        end)
    else
        toggleNoclip(false)
    end
end

local function SaveConfig()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(getgenv().Settings) end)
        if success then
            writefile(ConfigName, encoded)
        end
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigName) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigName)) end)
        if success then
            getgenv().Settings = decoded
        end
    end
end

local PageFarm = CreatePage("PageFarm")
CreateTabBtn("Farm", PageFarm)

CreateToggle(PageFarm, "Auto Farm Light (Evento)", function(val)
    getgenv().Settings.AutoFarm = val
    StartFarmLogic()
end, getgenv().Settings.AutoFarm)

CreateToggle(PageFarm, "Auto Server Hop", function(val)
    getgenv().Settings.AutoServerHop = val
end, getgenv().Settings.AutoServerHop)

CreateSlider(PageFarm, "Delay entre os TP's (Segundos)", 0, 2, 1.0, function(val)
    getgenv().Settings.TPDelay = val
end)

local PageVisuals = CreatePage("PageVisuals")
CreateTabBtn("Visual", PageVisuals)

CreateToggle(PageVisuals, "Ativar Wall (Master)", function(val)
    getgenv().Settings.ESP_Enabled = val
    if not val then ESP_Folder:ClearAllChildren() end
    updateESP()
end, false)

CreateToggle(PageVisuals, "Wall Bonecos (Highlight)", function(val)
    getgenv().Settings.ESP_Highlight = val
    updateESP()
end, true)

CreateToggle(PageVisuals, "Wall Nomes (Texto)", function(val)
    getgenv().Settings.ESP_Names = val
    updateESP()
end, true)

CreateToggle(PageVisuals, "Wall Ícone (Foto)", function(val)
    getgenv().Settings.ESP_Face = val
    updateESP()
end, true)

local PageTeleport = CreatePage("PageTeleport")
CreateTabBtn("Teleporte", PageTeleport)

local tpTarget = ""
CreateInput(PageTeleport, "Player...", function(text)
    tpTarget = text
end)

CreateButton(PageTeleport, "Teleportar (Player)", function()
    local targetName = tpTarget:lower()
    local found = nil
    for _, v in ipairs(Players:GetPlayers()) do
        if v.Name:lower():match(targetName) or v.DisplayName:lower():match(targetName) then
            found = v
            break
        end
    end
    if found and found.Character and found.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = found.Character.HumanoidRootPart.CFrame
        end
    end
end)

CreateButton(PageTeleport, "Ir para Próximo Baú (Chest)", function()
    local list = getSortedTargets("Bau", "Chest")
    if #list > 0 then
        if getgenv().ChestIndex > #list then getgenv().ChestIndex = 1 end
        if list[getgenv().ChestIndex] and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(list[getgenv().ChestIndex]:GetPivot())
            getgenv().ChestIndex = getgenv().ChestIndex + 1
        end
    end
end)

CreateButton(PageTeleport, "Ir para Próximo Osso (Bone)", function()
    local list = getSortedTargets("Osso", "Bone")
    if #list > 0 then
        if getgenv().BoneIndex > #list then getgenv().BoneIndex = 1 end
        if list[getgenv().BoneIndex] and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(list[getgenv().BoneIndex]:GetPivot())
            getgenv().BoneIndex = getgenv().BoneIndex + 1
        end
    end
end)

CreateButton(PageTeleport, "Sacrifício (Altar)", function() 
    if not TPToName("Altar") then TPToName("Sacrif") end 
end)
CreateButton(PageTeleport, "Ponte (Bridge)", function() 
    if not TPToName("Bridge") then TPToName("Ponte") end 
end)
CreateButton(PageTeleport, "Ilha (Island)", function() 
    if not TPToName("Island") then TPToName("Ilha") end 
end)
CreateButton(PageTeleport, "Neve (Snow)", function() 
    if not TPToName("Snow") then TPToName("Neve") end 
end)
CreateButton(PageTeleport, "Céu (Sky)", function() 
    if LocalPlayer.Character then 
        LocalPlayer.Character:PivotTo(CFrame.new(0, 500, 0)) 
    end 
end)

local PageMove = CreatePage("PageMove")
CreateTabBtn("Movimentação", PageMove)

CreateToggle(PageMove, "Speed Hack", function(val)
    getgenv().Settings.SpeedEnabled = val
    task.spawn(function()
        while getgenv().Settings.SpeedEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Settings.WalkSpeed
            end
            task.wait()
        end
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end)
end, false)

CreateSlider(PageMove, "Velocidade", 16, 200, 16, function(val)
    getgenv().Settings.WalkSpeed = val
end)

CreateToggle(PageMove, "Super Pulo", function(val)
    getgenv().Settings.JumpEnabled = val
    task.spawn(function()
        while getgenv().Settings.JumpEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.UseJumpPower = true
                LocalPlayer.Character.Humanoid.JumpPower = getgenv().Settings.JumpPower
            end
            task.wait()
        end
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = 50 end
    end)
end, false)

CreateSlider(PageMove, "Altura", 50, 500, 50, function(val)
    getgenv().Settings.JumpPower = val
end)

local PageTroll = CreatePage("PageTroll")
CreateTabBtn("Troll", PageTroll)

local trollTarget = ""
CreateInput(PageTroll, "Player...", function(text)
    trollTarget = text
end)

CreateToggle(PageTroll, "Grudar (Stick)", function(val)
    getgenv().Settings.StickTarget = val
    if val then
        task.spawn(function()
            while getgenv().Settings.StickTarget do
                local targetName = trollTarget:lower()
                if targetName ~= "" then
                    for _, v in ipairs(Players:GetPlayers()) do
                        if v.Name:lower():match(targetName) or v.DisplayName:lower():match(targetName) then
                            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                                LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                            end
                            break
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end, false)

CreateToggle(PageTroll, "Assistir (Spectate)", function(val)
    getgenv().Settings.SpectateTarget = val
    if val then
        task.spawn(function()
            while getgenv().Settings.SpectateTarget do
                local targetName = trollTarget:lower()
                if targetName ~= "" then
                    for _, v in ipairs(Players:GetPlayers()) do
                        if v.Name:lower():match(targetName) or v.DisplayName:lower():match(targetName) then
                            if v.Character and v.Character:FindFirstChild("Humanoid") then
                                Camera.CameraSubject = v.Character.Humanoid
                            end
                            break
                        end
                    end
                end
                task.wait(0.2)
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end)
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end, false)

local PageGraphics = CreatePage("PageGraphics")
CreateTabBtn("Gráficos", PageGraphics)

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local disabledEffects = {}

CreateToggle(PageGraphics, "Fullbright (Luz Infinita)", function(val)
    getgenv().Settings.Fullbright = val
    if val then
        originalLighting.Brightness = Lighting.Brightness
        originalLighting.ClockTime = Lighting.ClockTime
        originalLighting.FogEnd = Lighting.FogEnd
        originalLighting.GlobalShadows = Lighting.GlobalShadows
        originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        
        task.spawn(function()
            while getgenv().Settings.Fullbright do
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                task.wait(1)
            end
        end)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end, false)

CreateToggle(PageGraphics, "Remover Blur/Efeitos", function(val)
    getgenv().Settings.NoBlur = val
    if val then
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                if v.Enabled then
                    v.Enabled = false
                    table.insert(disabledEffects, v)
                end
            end
        end
    else
        for _, v in pairs(disabledEffects) do
            v.Enabled = true
        end
        disabledEffects = {}
    end
end, false)

CreateSlider(PageGraphics, "Horário (Hora)", 0, 24, 14, function(val)
    Lighting.ClockTime = val
end)

local PageSettings = CreatePage("PageSettings")
CreateTabBtn("Configurações", PageSettings)

CreateButton(PageSettings, "Salvar Config", function()
    SaveConfig()
end)

CreateButton(PageSettings, "Carregar Config", function()
    LoadConfig()
end)

CreateButton(PageSettings, "Rejoin Server (Reentrar)", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(PageSettings, "Resetar Personagem", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

CreateButton(PageSettings, "Fechar HUB", function()
    ScreenGui:Destroy()
    ESP_Folder:Destroy()
    getgenv().Settings.AutoFarm = false
    getgenv().Settings.StickTarget = false
    getgenv().Settings.SpectateTarget = false
    getgenv().Settings.Fullbright = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end)

local Credits = Instance.new("TextLabel")
Credits.Text = "Criado por JR"
Credits.TextColor3 = Theme.TextDim
Credits.BackgroundTransparency = 1
Credits.TextSize = 14
Credits.Font = Enum.Font.Gotham
Credits.Size = UDim2.new(1, 0, 0, 20)
Credits.Position = UDim2.new(0, 0, 1, -25)
Credits.Parent = PageSettings

print("HUB CARREGADO")