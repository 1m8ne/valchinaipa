--// Server Hop Script with 60-Second Countdown GUI
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false

-- Try to read saved server IDs
local File = pcall(function()
    AllIDs = game:GetService("HttpService"):JSONDecode(readfile("NotSameServers.json"))
end)

-- If no file, create one
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(AllIDs))
end

-- Function to find a server and teleport
function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/126884695634066/servers/Public?sortOrder=Asc&limit=100")
        )
    else
        Site = game.HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/126884695634066/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything)
        )
    end

    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    local num = 0
    for i, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                task.wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(AllIDs))
                    task.wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                task.wait(4)
            end
        end
    end
end

-- Loop for teleporting
function Teleport()
    while task.wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

-- === Create Countdown GUI ===
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CountdownGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.3, 0, 0.1, 0)
label.Position = UDim2.new(0.35, 0, 0.45, 0)
label.BackgroundTransparency = 0.3
label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Text = "Starting in 60 seconds..."
label.Parent = screenGui

-- === Countdown Loop ===
for i = 60, 1, -1 do
	label.Text = "Starting in " .. i .. " seconds..."
	task.wait(1)
end

-- Remove countdown GUI
screenGui:Destroy()

-- Start server hopping after 60 seconds
Teleport()
