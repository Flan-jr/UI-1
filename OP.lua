local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Modern Navigator 2026", "DarkScene")

-- الإعدادات العامة
local MainTab = Window:NewTab("الرئيسية")
local PlayerTab = Window:NewTab("اللاعبين")
local FlyTab = Window:NewTab("الطيران (Fly)")
local SaveTab = Window:NewTab("المواقع المحفوظة")

-- [1] صفحة الإحداثيات
local MainSection = MainTab:NewSection("إحداثياتك الحالية")
local LabelPos = MainSection:NewLabel("X: 0 | Y: 0 | Z: 0")

task.spawn(function()
    while task.wait(0.2) do
        local lp = game.Players.LocalPlayer.Character
        if lp and lp:FindFirstChild("HumanoidRootPart") then
            local pos = lp.HumanoidRootPart.Position
            LabelPos:UpdateLabel(string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z))
        end
    end
end)

-- [2] ميزة الطيران (Fly) مع Shift
local FlySection = FlyTab:NewSection("التحكم بالطيران")
local flying = false
local speed = 50
local normalSpeed = 50
local fastSpeed = 150 -- السرعة عند ضغط Shift

FlySection:NewToggle("تفعيل الطيران", "طيران بضغطة زر", function(state)
    flying = state
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0.1, 0)
        bv.Name = "FlyVelocity"
        
        task.spawn(function()
            while flying do
                task.wait()
                -- التحقق من ضغط Shift لزيادة السرعة
                local currentSpeed = game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) and fastSpeed or speed
                
                bv.Velocity = mouse.Hit.LookVector * currentSpeed
                if not flying then bv:Destroy() break end
            end
        end)
    else
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    end
end)

FlySection:NewSlider("السرعة العادية", "تعديل سرعة الطيران", 200, 10, function(s)
    speed = s
end)

-- [3] قائمة اللاعبين
local PlayerSection = PlayerTab:NewSection("قائمة اللاعبين")
local players = {}
for _, v in pairs(game.Players:GetPlayers()) do
    if v ~= game.Players.LocalPlayer then table.insert(players, v.Name) end
end

PlayerSection:NewDropdown("اختر لاعب للانتقال له", "انتقل لأي شخص", players, function(selected)
    local target = game.Players:FindFirstChild(selected)
    if target and target.Character then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)

-- [4] حفظ المواقع
local SavedPosSection = SaveTab:NewSection("إدارة المواقع")
local savedLocations = {}

SavedPosSection:NewTextBox("اسم الموقع", "اكتب الاسم هنا واضغط Enter", function(txt)
    local char = game.Players.LocalPlayer.Character
    if char then
        savedLocations[txt] = char.HumanoidRootPart.CFrame
        SavedPosSection:NewButton("انتقل إلى: "..txt, "العودة للموقع", function()
            char.HumanoidRootPart.CFrame = savedLocations[txt]
        end)
    end
end)
