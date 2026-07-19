-- ========== BS-过检测完整版 ==========
-- 仿皮脚本UI风格 | 左边分类 | 右边内容

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
end)

-- ==================== 反挂机 ====================
game:GetService("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- ==================== 创建UI（仿皮脚本风格） ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui
screenGui.Name = "BS"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 500, 0, 350)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.Parent = mainFrame
mainCorner.CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Parent = mainFrame
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Transparency = 0.3

-- ========== 标题栏 ==========
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleBar.BackgroundTransparency = 0.15
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.Parent = titleBar
titleCorner.CornerRadius = UDim.new(0, 14)

local titleText = Instance.new("TextLabel")
titleText.Parent = titleBar
titleText.Size = UDim2.new(1, -70, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.Text = "⚡ BS 过检测版"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.BackgroundTransparency = 1
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 32, 1, 0)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 1
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local minBtn = Instance.new("TextButton")
minBtn.Parent = titleBar
minBtn.Size = UDim2.new(0, 32, 1, 0)
minBtn.Position = UDim2.new(1, -64, 0, 0)
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundTransparency = 1
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniBall.Visible = true
end)

-- ========== 最小化圆球 ==========
local miniBall = Instance.new("TextButton")
miniBall.Parent = screenGui
miniBall.Size = UDim2.new(0, 55, 0, 55)
miniBall.Position = UDim2.new(1, -75, 0.9, 0)
miniBall.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
miniBall.Text = "⚡"
miniBall.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBall.TextSize = 28
miniBall.Font = Enum.Font.GothamBold
miniBall.BorderSizePixel = 0
miniBall.Visible = false

local ballCorner = Instance.new("UICorner")
ballCorner.Parent = miniBall
ballCorner.CornerRadius = UDim.new(1, 0)

miniBall.MouseButton1Click:Connect(function()
    miniBall.Visible = false
    mainFrame.Visible = true
end)

-- ========== 左侧分类栏 ==========
local leftBar = Instance.new("Frame")
leftBar.Parent = mainFrame
leftBar.Size = UDim2.new(0, 120, 1, -35)
leftBar.Position = UDim2.new(0, 0, 0, 35)
leftBar.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
leftBar.BackgroundTransparency = 0.3
leftBar.BorderSizePixel = 0

local leftCorner = Instance.new("UICorner")
leftCorner.Parent = leftBar
leftCorner.CornerRadius = UDim.new(0, 0)

-- ========== 右侧内容区 ==========
local rightFrame = Instance.new("Frame")
rightFrame.Parent = mainFrame
rightFrame.Size = UDim2.new(1, -120, 1, -35)
rightFrame.Position = UDim2.new(0, 120, 0, 35)
rightFrame.BackgroundTransparency = 1
rightFrame.BorderSizePixel = 0

local contentScroller = Instance.new("ScrollingFrame")
contentScroller.Parent = rightFrame
contentScroller.Size = UDim2.new(1, 0, 1, 0)
contentScroller.BackgroundTransparency = 1
contentScroller.BorderSizePixel = 0
contentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroller.ScrollBarThickness = 4

-- ========== 分类列表 ==========
local categories = {"⚡ 加速", "✈️ 飞行", "🚪 穿墙", "🦘 跳跃", "👁️ 透视", "🎯 范围"}
local currentTab = "⚡ 加速"
local categoryBtns = {}

local function updateContent(tab)
    for _, child in pairs(contentScroller:GetChildren()) do
        child:Destroy()
    end
    
    local y = 10
    local gap = 8
    
    if tab == "⚡ 加速" then
        -- 加速开关
        local speedBtn = Instance.new("TextButton")
        speedBtn.Parent = contentScroller
        speedBtn.Size = UDim2.new(0, 200, 0, 40)
        speedBtn.Position = UDim2.new(0.5, -100, 0, y)
        speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        speedBtn.Text = speedEnabled and "⚡ 加速: 开" or "⚡ 加速: 关"
        speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedBtn.TextSize = 16
        speedBtn.Font = Enum.Font.GothamBold
        speedBtn.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.Parent = speedBtn
        corner.CornerRadius = UDim.new(0, 8)
        speedBtn.MouseButton1Click:Connect(function()
            speedEnabled = not speedEnabled
            speedBtn.Text = speedEnabled and "⚡ 加速: 开" or "⚡ 加速: 关"
            speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    if speedEnabled then
                        originalWalkSpeed = hum.WalkSpeed
                        originalJumpPower = hum.JumpPower
                        hum.WalkSpeed = 16 * speedMultiplier
                        hum.JumpPower = 50 * speedMultiplier
                    else
                        hum.WalkSpeed = originalWalkSpeed
                        hum.JumpPower = originalJumpPower
                    end
                end
            end
        end)
        y = y + 40 + gap
        
        -- 倍率标签
        local label = Instance.new("TextLabel")
        label.Parent = contentScroller
        label.Size = UDim2.new(1, 0, 0, 25)
        label.Position = UDim2.new(0, 0, 0, y)
        label.Text = "倍率: " .. speedMultiplier .. "x"
        label.TextColor3 = Color3.fromRGB(180, 180, 210)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        y = y + 25 + gap
        
        -- 倍率按钮 1-5
        for i = 1, 5 do
            local btn = Instance.new("TextButton")
            btn.Parent = contentScroller
            btn.Size = UDim2.new(0, 45, 0, 35)
            btn.Position = UDim2.new(0, 10 + (i-1) * 52, 0, y)
            btn.BackgroundColor3 = (i == speedMultiplier) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 60)
            btn.Text = tostring(i)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 16
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            local corner = Instance.new("UICorner")
            corner.Parent = btn
            corner.CornerRadius = UDim.new(0, 8)
            btn.MouseButton1Click:Connect(function()
                speedMultiplier = i
                for _, b in pairs(contentScroller:GetChildren()) do
                    if b:IsA("TextButton") and b.Size == UDim2.new(0, 45, 0, 35) then
                        b.BackgroundColor3 = (tonumber(b.Text) == i) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 60)
                    end
                end
                if speedEnabled then
                    local char = player.Character
                    if char then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then
                            hum.WalkSpeed = 16 * i
                            hum.JumpPower = 50 * i
                        end
                    end
                end
                label.Text = "倍率: " .. i .. "x"
            end)
        end
        y = y + 35 + gap + 10
        
    elseif tab == "✈️ 飞行" then
        local flyBtn = Instance.new("TextButton")
        flyBtn.Parent = contentScroller
        flyBtn.Size = UDim2.new(0, 200, 0, 40)
        flyBtn.Position = UDim2.new(0.5, -100, 0, y)
        flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        flyBtn.Text = flyEnabled and "✈️ 飞行: 开" or "✈️ 飞行: 关"
        flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        flyBtn.TextSize = 16
        flyBtn.Font = Enum.Font.GothamBold
        flyBtn.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.Parent = flyBtn
        corner.CornerRadius = UDim.new(0, 8)
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
        y = y + 40 + gap
        
        local label = Instance.new("TextLabel")
        label.Parent = contentScroller
        label.Size = UDim2.new(0, 80, 0, 25)
        label.Position = UDim2.new(0, 10, 0, y)
        label.Text = "飞行速度:"
        label.TextColor3 = Color3.fromRGB(180, 180, 210)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        
        local input = Instance.new("TextBox")
        input.Parent = contentScroller
        input.Size = UDim2.new(0, 80, 0, 25)
        input.Position = UDim2.new(0, 120, 0, y)
        input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.Text = tostring(flySpeed)
        input.TextSize = 14
        input.Font = Enum.Font.Gotham
        input.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.Parent = input
        corner.CornerRadius = UDim.new(0, 6)
        input.FocusLost:Connect(function()
            local v = tonumber(input.Text)
            if v then flySpeed = math.clamp(v, 1, 200) end
        end)
        
    elseif tab == "🚪 穿墙" then
        local btn = Instance.new("TextButton")
        btn.Parent = contentScroller
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0.5, -100, 0, y)
        btn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        btn.Text = noclipEnabled and "🚪 穿墙: 开" or "🚪 穿墙: 关"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.Parent = btn
        corner.CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            noclipEnabled = not noclipEnabled
            btn.Text = noclipEnabled and "🚪 穿墙: 开" or "🚪 穿墙: 关"
            btn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        end)
        
    elseif tab == "🦘 跳跃" then
        local btn = Instance.new("TextButton")
        btn.Parent = contentScroller
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0.5, -100, 0, y)
        btn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        btn.Text = jumpEnabled and "🦘 无限跳: 开" or "🦘 无限跳: 关"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.Parent = btn
        corner.CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            jumpEnabled = not jumpEnabled
            btn.Text = jumpEnabled and "🦘 无限跳: 开" or "🦘 无限跳: 关"
            btn.BackgroundColor3 = jumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        end)
        
    elseif tab == "👁️ 透视" then
        local btn = Instance.new("TextButton")
        btn.Parent = contentScroller
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0.5, -100, 0, y)
        btn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        btn.Text = espEnabled and "👁️ 透视: 开" or "👁️ 透视: 关"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.Parent = btn
        corner.CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            espEnabled = not espEnabled
            btn.Text = espEnabled and "👁️ 透视: 开" or "👁️ 透视: 关"
            btn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
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
            end
        end)
        
    elseif tab == "🎯 范围" then
        local btn = Instance.new("TextButton")
        btn.Parent = contentScroller
        btn.Size = UDim2.new(0, 200, 0, 40)
        btn.Position = UDim2.new(0.5, -100, 0, y)
        btn.BackgroundColor3 = rangeEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        btn.Text = rangeEnabled and "🎯 范围: 开" or "🎯 范围: 关"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.Parent = btn
        corner.CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            rangeEnabled = not rangeEnabled
            btn.Text = rangeEnabled and "🎯 范围: 开" or "🎯 范围: 关"
            btn.BackgroundColor3 = rangeEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
        end)
        y = y + 40 + gap
        
        local label = Instance.new("TextLabel")
        label.Parent = contentScroller
        label.Size = UDim2.new(0, 80, 0, 25)
        label.Position = UDim2.new(0, 10, 0, y)
        label.Text = "范围大小:"
        label.TextColor3 = Color3.fromRGB(180, 180, 210)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        
        local input = Instance.new("TextBox")
        input.Parent = contentScroller
        input.Size = UDim2.new(0, 80, 0, 25)
        input.Position = UDim2.new(0, 120, 0, y)
        input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.Text = tostring(rangeSize)
        input.TextSize = 14
        input.Font = Enum.Font.Gotham
        input.BorderSizePixel = 0
        local corner2 = Instance.new("UICorner")
        corner2.Parent = input
        corner2.CornerRadius = UDim.new(0, 6)
        input.FocusLost:Connect(function()
            local v = tonumber(input.Text)
            if v then rangeSize = math.clamp(v, 1, 500) end
        end)
    end
    
    contentScroller.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- ========== 创建分类按钮 ==========
for i, cat in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Parent = leftBar
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (i-1) * 38)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 60)
    btn.Text = cat
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    corner.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        currentTab = cat
        for _, b in pairs(categoryBtns) do
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        updateContent(cat)
    end)
    table.insert(categoryBtns, btn)
end

-- ========== 状态标签 ==========
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = leftBar
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -25)
statusLabel.Text = "🛡️ 已启动"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham

-- ========== 范围循环 ==========
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

-- ========== 穿墙循环 ==========
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

-- ========== 无限跳 ==========
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

-- ========== 角色重生 ==========
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyEnabled then
        flyEnabled = false
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if flyConn then flyConn:Disconnect(); flyConn = nil end
    end
    if speedEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 16 * speedMultiplier
                hum.JumpPower = 50 * speedMultiplier
            end
        end
    end
end)

-- ========== 快捷键 ==========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        for _, btn in pairs(categoryBtns) do
            if btn.Text == "✈️ 飞行" then
                btn.MouseButton1Click:Fire()
                break
            end
        end
        updateContent(currentTab)
    end
    if input.KeyCode == Enum.KeyCode.G then
        for _, btn in pairs(categoryBtns) do
            if btn.Text == "⚡ 加速" then
                btn.MouseButton1Click:Fire()
                break
            end
        end
        updateContent(currentTab)
    end
end)

-- ========== 启动 ==========
updateContent("⚡ 加速")
task.wait(0.5)
startBypass()

print("========================================")
print("  ✅ BS-过检测版 加载成功")
print("  🛡️ 过检测已启动")
print("  F键 开关飞行 | G键 开关加速")
print("========================================")