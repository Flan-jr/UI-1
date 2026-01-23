-- Modern UI Script for Coordinates and Teleportation
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Lib/Main/main/Library.lua"))() -- مكتبة واجهة عصرية
local Window = Library:CreateWindow("Modern Navigator 2026", "التحكم بالإحداثيات", 10044538561)

-- صفحة الإحداثيات الشخصية
local MainTab = Window:CreateTab("الرئيسية")
local Section = MainTab:CreateSection("إحداثياتي")

local LabelX = MainTab:CreateLabel("X: 0")
local LabelY = MainTab:CreateLabel("Y: 0")
local LabelZ = MainTab:CreateLabel("Z: 0")

-- تحديث الإحداثيات تلقائياً
task.spawn(function()
    while task.wait(0.1) do
        local pos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        LabelX:SetText("X: " .. math.floor(pos.X))
        LabelY:SetText("Y: " .. math.floor(pos.Y))
        LabelZ:SetText("Z: " .. math.floor(pos.Z))
    end
end)

-- صفحة اللاعبين والانتقال
local PlayersTab = Window:CreateTab("اللاعبين")
local PSection = PlayersTab:CreateSection("انتقال سريع")

PlayersTab:CreateDropdown("اختر لاعب للانتقال", function(selectedPlayer)
    local target = game.Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        Library:Notify("تم الانتقال", "وصلت إلى " .. selectedPlayer, 3)
    end
end, (function()
    local names = {}
    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Name ~= game.Players.LocalPlayer.Name then table.insert(names, v.Name) end
    end
    return names
end)())

-- صفحة حفظ المواقع
local SaveTab = Window:CreateTab("المواقع المحفوظة")
local SavedPositions = {}

SaveTab:CreateInput("اسم الموقع", "ادخل اسم لحفظ مكانك", function(text)
    local pos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    SavedPositions[text] = pos
    Library:Notify("تم الحفظ", "تم حفظ موقع: " .. text, 3)
end)

SaveTab:CreateButton("عرض المواقع المحفوظة (Console)", function()
    for name, _ in pairs(SavedPositions) do
        print("موقع محفوظ: " .. name)
    end
end)

-- ملاحظة: يمكنك إضافة أزرار ديناميكية هنا لكل موقع يتم حفظه
