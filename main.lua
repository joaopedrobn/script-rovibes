local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().Settings = {
    AutoFarm = false,
    ESPEnabled = false,
    TargetName = "LightTemplate",
    TPDelay = 0.5,
    AutoServerHop = false
}

local Connections = {}
local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "ESP_Storage"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Hub"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end 
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 385)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "HUB - by jr"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Container = Instance.new("UIListLayout", MainFrame)
Container.FillDirection = Enum.FillDirection.Vertical
Container.Padding = UDim.new(0, 5)
Container.HorizontalAlignment = Enum.HorizontalAlignment.Center

local PaddingTop = Instance.new("Frame", MainFrame)
PaddingTop.Size = UDim2.new(1, 0, 0, 45)
PaddingTop.BackgroundTransparency = 1

local function createButton(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

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

local function toggleNoclip(state)
    if state then
        local conn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        table.insert(Connections, conn)
    else
        for i, v in pairs(Connections) do v:Disconnect() end
        Connections = {}
    end
end

local function updateESP()
    ESP_Folder:ClearAllChildren()
    
    if not getgenv().Settings.ESPEnabled then return end

    for _, obj in ipairs(getTargets()) do
        if obj then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = obj
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = ESP_Folder
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            
            local highlight = Instance.new("Highlight")
            highlight.Adornee = plr.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = ESP_Folder

            local bb = Instance.new("BillboardGui")
            bb.Name = "ESP_NameTag"
            bb.Adornee = plr.Character.Head
            bb.Size = UDim2.new(0, 100, 0, 50)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.AlwaysOnTop = true
            bb.Parent = ESP_Folder

            local txt = Instance.new("TextLabel")
            txt.Parent = bb
            txt.BackgroundTransparency = 1
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.Text = plr.Name
            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
            txt.TextStrokeTransparency = 0
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 14
        end
    end
end

task.spawn(function()
    while true do
        if getgenv().Settings.ESPEnabled then
            updateESP()
        end
        task.wait(2)
    end
end)

local tpInput = Instance.new("TextBox", MainFrame)
tpInput.Size = UDim2.new(0.9, 0, 0, 35)
tpInput.PlaceholderText = "Nome do Player (Parcial)"
tpInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tpInput.TextColor3 = Color3.fromRGB(255, 255, 255)

createButton("Teleportar para Player", function()
    local targetName = tpInput.Text:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():match(targetName) or plr.DisplayName:lower():match(targetName) then
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    myRoot.CFrame = plr.Character.HumanoidRootPart.CFrame
                end
            end
            break
        end
    end
end)

local function startFarm()
    task.spawn(function()
        toggleNoclip(true)
        
        while getgenv().Settings.AutoFarm do
            local lights = getTargets()
            
            if #lights == 0 and getgenv().Settings.AutoServerHop then
                if queue_on_teleport then
                    queue_on_teleport([[
                        wait(5)
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/joaopedrobn/script-rovibes/refs/heads/main/main.lua"))()
                    ]])
                end
                
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
                break
            end

            for _, obj in ipairs(lights) do
                if not getgenv().Settings.AutoFarm then break end
                
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local targetCFrame
                    if obj:IsA("Model") then
                        targetCFrame = obj:GetPivot()
                    else
                        targetCFrame = obj.CFrame
                    end
                    
                    pcall(function()
                        char:PivotTo(targetCFrame + Vector3.new(0, 3, 0))
                    end)
                end
                task.wait(getgenv().Settings.TPDelay)
            end
            task.wait(0.1)
        end
        
        toggleNoclip(false)
    end)
end

createButton("Toggle AutoFarm: OFF", function(btn)
    getgenv().Settings.AutoFarm = not getgenv().Settings.AutoFarm
    if getgenv().Settings.AutoFarm then
        btn.Text = "Toggle AutoFarm: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        startFarm()
    else
        btn.Text = "Toggle AutoFarm: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

createButton("AutoServer Hop: OFF", function(btn)
    getgenv().Settings.AutoServerHop = not getgenv().Settings.AutoServerHop
    if getgenv().Settings.AutoServerHop then
        btn.Text = "AutoServer Hop: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        btn.Text = "AutoServer Hop: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

createButton("Toggle ESP: OFF", function(btn)
    getgenv().Settings.ESPEnabled = not getgenv().Settings.ESPEnabled
    if getgenv().Settings.ESPEnabled then
        btn.Text = "Toggle ESP: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        updateESP()
    else
        btn.Text = "Toggle ESP: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ESP_Folder:ClearAllChildren()
    end
end)

createButton("Destruir GUI", function()
    ScreenGui:Destroy()
    ESP_Folder:Destroy()
    getgenv().Settings.AutoFarm = false
    toggleNoclip(false)
end)

print("HUB CARREGADO COM SUCESSO")