-- LOAD GUARD + AUTO EXECUTE
if getgenv().StarHubLoaded then return end
getgenv().StarHubLoaded = true

queue_on_teleport('loadstring(game:HttpGet("YOUR_LINK_HERE"))()')

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

-- SETTINGS FILE
local fileName = "StarHubSettings.json"
local Settings = {
    AutoSteal = false,
    AutoFarm = false,
    AutoServerScan = false
}

-- LOAD SETTINGS
pcall(function()
    if readfile(fileName) then
        Settings = HttpService:JSONDecode(readfile(fileName))
    end
end)

-- SAVE SETTINGS
function saveSettings()
    writefile(fileName, HttpService:JSONEncode(Settings))
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,300,0,260)
Frame.Position = UDim2.new(0.3,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true

local UIListLayout = Instance.new("UIListLayout", Frame)

local function createToggle(name, settingKey)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1,0,0,40)

    local function updateText()
        btn.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    end

    updateText()

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        updateText()
        saveSettings()
    end)
end

local function createButton(name, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Text = name
    btn.MouseButton1Click:Connect(callback)
end

-- VALUE PARSER
function parseValue(text)
    local num = tonumber(string.match(text, "%d+"))
    if not num then return 0 end

    if string.find(text, "B") then
        return num * 1000000000
    elseif string.find(text, "M") then
        return num * 1000000
    elseif string.find(text, "K") then
        return num * 1000
    else
        return num
    end
end

-- AUTO STEAL
task.spawn(function()
    while task.wait(0.2) do
        if Settings.AutoSteal then
            for _,v in pairs(player.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") and string.lower(v.Text) == "steal" then
                    v:Activate()
                end
            end
        end
    end
end)

-- AUTO FARM
task.spawn(function()
    while task.wait(2) do
        if Settings.AutoFarm then
            for _,gui in pairs(workspace:GetDescendants()) do
                if gui:IsA("BillboardGui") then
                    local part = gui.Parent
                    if part and part:IsA("BasePart") then
                        player.Character.Humanoid:MoveTo(part.Position)
                        task.wait(1)
                    end
                end
            end
        end
    end
end)

-- SERVER CHECK
function hasRich()
    for _,gui in pairs(workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") then
            for _,v in pairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and string.find(v.Text, "/sec") then
                    if parseValue(v.Text) >= 250000000 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- SERVER HOP
function hop()
    local servers = HttpService:JSONDecode(
        game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Desc&limit=100")
    )
    for _,v in pairs(servers.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceID, v.id)
        end
    end
end

-- AUTO SERVER SCAN
task.spawn(function()
    while task.wait(5) do
        if Settings.AutoServerScan then
            if hasRich() then
                Settings.AutoServerScan = false
                saveSettings()
            else
                hop()
                task.wait(10)
            end
        end
    end
end)

-- UI
createToggle("Auto Steal", "AutoSteal")
createToggle("Auto Farm", "AutoFarm")
createToggle("Auto Server Scan", "AutoServerScan")

createButton("Server Hop", hop)
createButton("Rejoin", function()
    TeleportService:Teleport(PlaceID, player)
end)

-- TOGGLE MENU (X)
UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.X then
        Frame.Visible = not Frame.Visible
    end
end)
