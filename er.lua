--// Server Hop Script with 10-Second Delay
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

--// === Delay Section ===
-- Optional: notify player about the delay
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Server Hop",
        Text = "Waiting 60 seconds before starting...",
        Duration = 55
    })
end)

-- Wait 10 seconds before server hopping starts
task.wait(60)

-- Start server hopping
Teleport()
