-- ========== BS-圣奥里修复版 V2 ==========
-- 修复悬浮窗拦截按键问题

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
local originalWalkSpeed = 16
local originalJumpPower = 50

-- ==================== 创建悬浮窗（修复版：不拦截按键） ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui
screenGui.Name = "BS"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 280, 0, 530)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -265)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35