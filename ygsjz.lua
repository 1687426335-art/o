-- ========== BS-过检测完整版 ==========
-- 所有功能保留 | 不需要OrionLib | 直接显示悬浮窗

local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- ==================== 过检测 ====================
local bypassActive = false
local bypassConnections = {}

local function startBypass()
    if bypassActive then return end
    bypassActive = true
    print("🛡️ 启动过检测...")

    pcall(function()
        local oldKick = player.Kick
        player.Kick = function(self, msg)
            print("🛡️ 拦截踢出: " .. tostring(msg))
            return nil
        end
        table.insert(bypassConnections, {Disconnect = function()
            player.Kick = oldKick
        end})
    end)

    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                local conn = hum.HealthChanged:Connect(function()
                    if hum.Health <= 0 then
                        task.wait(0.1)
                        if hum and hum.Parent then
                            hum.Health = hum.MaxHealth
                        end
                    end
                end)
                table.insert(bypassConnections, conn)
            end
        end
    end)

    pcall(function()
        local function antiTeleport()
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local lastPos = hrp.Position
                    local conn = RunService.Heartbeat:Connect(function()
                        if not hrp or not hrp.Parent then return end
                        if (hrp.Position - lastPos).Magnitude > 100 then
                            hrp.CFrame = CFrame.new(lastPos)
                        end
                        lastPos = hrp.Position
                    end)
                    table.insert(bypassConnections, conn)
                end
            end
        end
        antiTeleport()
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            antiTeleport()
        end)
    end)

    pcall(function()
        local conn = RunService.Heartbeat:Connect(function()
            if math.random(1, 100) > 95 then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
        table.insert(bypassConnections, conn)
    end)

    pcall(function()
        local conn = player:GetPropertyChangedSignal("Parent"):Connect(function()
            if not player.Parent then
                print("🔄 被踢出，重连中...")
                task.wait(2)
                TeleportService:Teleport(game.PlaceId, player)
            end
        end)
        table.insert(bypassConnections, conn)
    end)

    print("✅ 过检测已启动")
end

-- ==================== 反挂机 ====================
game:GetService("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- ==================== 功能变量 ====================
local flyEnabled = false
local flySpeed = 50
local flyBV = nil
local flyBG = nil
local flyConn = nil
local speedEnabled = false
local speedMultiplier = 1
local noclipEnabled = false
local jumpEnabled = false
local espEnabled = false
local rangeEnabled = false
local rangeSize = 30
local espHighlights = {}

-- ==================== 创建悬浮窗 ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui
screenGui.Name = "BS"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 280, 0, 500)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.Parent = mainFrame
mainCorner.CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Parent = mainFrame
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Transparency = 0.3

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.Parent = titleBar
titleCorner.CornerRadius = UDim.new(0, 14)

local titleText = Instance.new("TextLabel")
titleText.Parent = titleBar
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "BS 过检测版"
titleText.TextColor3 = Color3.fromRGB(0, 200, 255)
titleText.BackgroundTransparency = 1
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 1
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ========== 创建按钮函数 ==========
local function createBtn(text, y, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 230, 0, 35)
    btn.Position = UDim2.new(0.5, -115, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    corner.CornerRadius = UDim.new(0, 8)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

local y = 50
local gap = 8

-- ========== 飞行功能 ==========
local flyBtn = createBtn("✈️ 飞行: 关", y, Color3.fromRGB(60, 60, 80))
flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "✈️ 飞行: 开" or "✈️ 飞行: 关"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
    
    if flyEnabled then
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if hrp and hum then
                hum.PlatformStand = true
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                flyBV.Velocity = Vector3.new(0, 20, 0)
                flyBV.Parent = hrp
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                flyBG.D = 5000
                flyBG.P = 50000
                flyBG.CFrame = Camera.CFrame
                flyBG.Parent = hrp
                flyConn = RunService.Heartbeat:Connect(function()
                    if not flyEnabled or not hrp or not hrp.Parent then
                        if flyConn then flyConn:Disconnect(); flyConn = nil end
                        return
                    end
                    if flyBV and flyBG then
                        flyBV.Velocity = Camera.CFrame.LookVector * flySpeed
                        flyBG.CFrame = Camera.CFrame
                    end
                end)
            end
        end
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)

-- ========== 飞行速度输入 ==========
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Parent = mainFrame
flySpeedLabel.Size = UDim2.new(0, 80, 0, 25)
flySpeedLabel.Position = UDim2.new(0, 10, 0, y + 35 + gap)
flySpeedLabel.Text = "飞速:"
flySpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 210)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.TextSize = 13
flySpeedLabel.Font = Enum.Font.Gotham

local flySpeedInput = Instance.new("TextBox")
flySpeedInput.Parent = mainFrame
flySpeedInput.Size = UDim2.new(0, 60, 0, 25)
flySpeedInput.Position = UDim2.new(0, 60, 0, y + 35 + gap)
flySpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
flySpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedInput.Text = "50"
flySpeedInput.PlaceholderText = "速度"
flySpeedInput.TextSize = 14
flySpeedInput.Font = Enum.Font.Gotham
flySpeedInput.BorderSizePixel = 0
local fsiCorner = Instance.new("UICorner")
fsiCorner.Parent = flySpeedInput
fsiCorner.CornerRadius = UDim.new(0, 6)
flySpeedInput.FocusLost:Connect(function()
    local v = tonumber(flySpeedInput.Text)
    if v then flySpeed = math.clamp(v, 1, 200) end
end)

y = y + 35 + gap + 30

-- ========== 加速功能 ==========
local speedBtn = createBtn("⚡ 加速: 关", y, Color3.fromRGB(60, 60, 80))
speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and "⚡ 加速: 开" or "⚡ 加速: 关"
    speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = speedEnabled and (16 * speedMultiplier) or 16
            hum.JumpPower = speedEnabled and (50 * speedMultiplier) or 50
        end
    end
end)

-- ========== 倍率按钮 1-5 ==========
local by = y + 35 + gap
for i = 1, 5 do
    local val = i
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 30, 0, 25)
    btn.Position = UDim2.new(0, 10 + (i-1) * 38, 0, by)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 60)
    btn.Text = tostring(val)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    corner.CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        speedMultiplier = val
        for _, b in pairs(mainFrame:GetChildren()) do
            if b:IsA("TextButton") and b.Size == UDim2.new(0, 30, 0, 25) then
                b.BackgroundColor3 = (tonumber(b.Text) == val) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 60)
            end
        end
        if speedEnabled then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = 16 * val
                    hum.JumpPower = 50 * val
                end
            end
        end
        print("⚡ 倍率: " .. val .. "x")
    end)
end

y = y + 35 + gap + 30

-- ========== 穿墙 ==========
local noclipBtn = createBtn("🚪 穿墙: 关", y, Color3.fromRGB(60, 60, 80))
noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "🚪 穿墙: 开" or "🚪 穿墙: 关"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

y = y + 35 + gap

-- ========== 无限跳跃 ==========
local jumpBtn = createBtn("🦘 无限跳: 关", y, Color3.fromRGB(60, 60, 80))
jumpBtn.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    jumpBtn.Text = jumpEnabled and "🦘 无限跳: 开" or "🦘 无限跳: 关"
    jumpBtn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
end)

UserInputService.JumpRequest:Connect(function()
    if jumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState("Jumping")
            end
        end
    end
end)

y = y + 35 + gap

-- ========== 透视 ==========
local espBtn = createBtn("👁️ 透视: 关", y, Color3.fromRGB(60, 60, 80))

local function toggleESP(p)
    if espEnabled then
        if not espHighlights[p.UserId] then
            local highlight = Instance.new("Highlight")
            highlight.Parent = p.Character
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineTransparency = 0
            espHighlights[p.UserId] = highlight
        end
    else
        if espHighlights[p.UserId] then
            espHighlights[p.UserId]:Destroy()
            espHighlights[p.UserId] = nil
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "👁️ 透视: 开" or "👁️ 透视: 关"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            toggleESP(p)
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        toggleESP(p)
    end)
end)

y = y + 35 + gap

-- ========== 范围 ==========
local rangeBtn = createBtn("🎯 范围: 关", y, Color3.fromRGB(60, 60, 80))
rangeBtn.MouseButton1Click:Connect(function()
    rangeEnabled = not rangeEnabled
    rangeBtn.Text = rangeEnabled and "🎯 范围: 开" or "🎯 范围: 关"
    rangeBtn.BackgroundColor3 = rangeEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
end)

RunService.RenderStepped:Connect(function()
    if rangeEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                pcall(function()
                    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(rangeSize, rangeSize, rangeSize * 0.5)
                        hrp.Transparency = 0.5
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    end
                end)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                pcall(function()
                    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 0
                        hrp.Material = Enum.Material.Plastic
                    end
                end)
            end
        end
    end
end)

-- 范围大小输入
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Parent = mainFrame
rangeLabel.Size = UDim2.new(0, 80, 0, 25)
rangeLabel.Position = UDim2.new(0, 10, 0, y + 35 + gap)
rangeLabel.Text = "范围大小:"
rangeLabel.TextColor3 = Color3.fromRGB(180, 180, 210)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextSize = 13
rangeLabel.Font = Enum.Font.Gotham

local rangeInput = Instance.new("TextBox")
rangeInput.Parent = mainFrame
rangeInput.Size = UDim2.new(0, 60, 0, 25)
rangeInput