local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local PlaceID = game.PlaceId

getgenv().AutoSteal = false
getgenv().AutoFarm = false
getgenv().AutoServerScan = false

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,300,0,250)
Frame.Position = UDim2.new(0.3,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Visible = false

local function makeButton(text, posY, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0,200,0,40)
    btn.Position = UDim2.new(0,50,0,posY)
    btn.Text = text
    btn.MouseButton1Click:Connect(callback)
end

-- VALUE READER
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
        if getgenv().AutoSteal then
            for _,v in pairs(player.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") and string.lower(v.Text) == "steal" then
                    v:Activate()
                end
            end
        end
    end
end)

-- AUTO FARM (walk to brainrot)
task.spawn(function()
    while task.wait(2) do
        if getgenv().AutoFarm then
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

-- CHECK RICH SERVER
function serverHasRichBrainrot()
    for _,gui in pairs(workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") then
            for _,v in pairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and string.find(v.Text, "/sec") then
                    local value = parseValue(v.Text)
                    if value >= 250000000 then
                        return true, v.Text
                    end
                end
            end
        end
    end
    return false
end

-- SERVER HOP
function serverHop()
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
        if getgenv().AutoServerScan then
            local rich, value = serverHasRichBrainrot()
            if rich then
                print("Rich server found:", value)
                getgenv().AutoServerScan = false
            else
                print("Hopping server...")
                serverHop()
                task.wait(10)
            end
        end
    end
end)

-- BUTTONS
makeButton("Auto Steal", 20, function()
    getgenv().AutoSteal = not getgenv().AutoSteal
end)

makeButton("Auto Farm", 70, function()
    getgenv().AutoFarm = not getgenv().AutoFarm
end)

makeButton("Auto Server Scan", 120, function()
    getgenv().AutoServerScan = not getgenv().AutoServerScan
end)

makeButton("Server Hop", 170, function()
    serverHop()
end)

makeButton("Rejoin", 210, function()
    TeleportService:Teleport(PlaceID, player)
end)

-- OPEN/CLOSE MENU WITH X
UIS.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.X then
        Frame.Visible = not Frame.Visible
    end
end)
