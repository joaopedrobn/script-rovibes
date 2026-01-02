local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "HUB - by jr", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest", IntroEnabled = true})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

getgenv().Settings = {
    AutoFarm = false,
    TargetName = "LightTemplate",
    TPDelay = 0.5,
    AutoServerHop = false,
    
    ESP_Enabled = false,
    ESP_Highlight = true,
    ESP_Names = true,
    
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedEnabled = false,
    JumpEnabled = false,
    
    FlyEnabled = false,
    FlySpeed = 50,
    
    SpinBot = false,
    WalkMode = false
}

local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MovementTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "ESP_Storage"

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
            
            if getgenv().Settings.ESP_Highlight then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = plr.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.Parent = ESP_Folder
            end

            if getgenv().Settings.ESP_Names then
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
end

task.spawn(function()
    while true do
        if getgenv().Settings.ESP_Enabled then
            updateESP()
        end
        task.wait(1)
    end
end)

FarmTab:AddToggle({
    Name = "Auto Farm Light",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.AutoFarm = Value
        if Value then
            toggleNoclip(true)
            task.spawn(function()
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
                            local targetCFrame = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
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
        else
            toggleNoclip(false)
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Server Hop",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.AutoServerHop = Value
    end    
})

FarmTab:AddTextbox({
    Name = "TP para Player",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        local targetName = Value:lower()
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
    end
})

VisualsTab:AddToggle({
    Name = "Master ESP Switch",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.ESP_Enabled = Value
        if not Value then ESP_Folder:ClearAllChildren() end
        updateESP()
    end    
})

VisualsTab:AddToggle({
    Name = "Show Highlights (Wall)",
    Default = true,
    Callback = function(Value)
        getgenv().Settings.ESP_Highlight = Value
        updateESP()
    end    
})

VisualsTab:AddToggle({
    Name = "Show Names",
    Default = true,
    Callback = function(Value)
        getgenv().Settings.ESP_Names = Value
        updateESP()
    end    
})

MovementTab:AddToggle({
    Name = "Enable Fly",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.FlyEnabled = Value
        
        if Value then
            local BodyGyro = Instance.new("BodyGyro")
            BodyGyro.P = 9e4
            BodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart
            
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not getgenv().Settings.FlyEnabled or not LocalPlayer.Character then
                    BodyVelocity:Destroy()
                    BodyGyro:Destroy()
                    connection:Disconnect()
                    return
                end
                
                LocalPlayer.Character.Humanoid.PlatformStand = true
                BodyGyro.CFrame = Workspace.CurrentCamera.CFrame
                
                local speed = getgenv().Settings.FlySpeed
                local moveDir = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                BodyVelocity.Velocity = moveDir * speed
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
        end
    end    
})

MovementTab:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        getgenv().Settings.FlySpeed = Value
    end    
})

MovementTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.SpeedEnabled = Value
        while getgenv().Settings.SpeedEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Settings.WalkSpeed
            end
            task.wait()
        end
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end    
})

MovementTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 300,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        getgenv().Settings.WalkSpeed = Value
    end    
})

MovementTab:AddToggle({
    Name = "Super Jump",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.JumpEnabled = Value
        while getgenv().Settings.JumpEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.UseJumpPower = true
                LocalPlayer.Character.Humanoid.JumpPower = getgenv().Settings.JumpPower
            end
            task.wait()
        end
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = 50 end
    end    
})

MovementTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        getgenv().Settings.JumpPower = Value
    end    
})

MovementTab:AddToggle({
    Name = "SpinBot",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.SpinBot = Value
        if Value then
            task.spawn(function()
                while getgenv().Settings.SpinBot do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
                    end
                    task.wait()
                end
            end)
        end
    end    
})

MovementTab:AddToggle({
    Name = "Walk Mode (PC)",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.WalkMode = Value
        if Value then
             getgenv().Settings.SpeedEnabled = false 
             task.spawn(function()
                while getgenv().Settings.WalkMode do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.WalkSpeed = 8
                    end
                    task.wait()
                end
                if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
             end)
        else
            if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
        end
    end    
})

SettingsTab:AddButton({
    Name = "Unload GUI",
    Callback = function()
        OrionLib:Destroy()
        ESP_Folder:Destroy()
        getgenv().Settings.AutoFarm = false
        toggleNoclip(false)
    end    
})

OrionLib:Init()