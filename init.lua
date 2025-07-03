local vehicleData = {}
local lastVehicle = nil
local nextId = 1

local showHUD = false
local carName = "Нет данных"
local carID = 0
local fuelPercent = 0.0

local fuelMaxPercent = 100

-- Случайное значение от 20% до 100%
local function randomFuelPercent()
    return math.random(20, 100) / 100.0
end

registerForEvent("onInit", function()
    print("[CarIdentifier] Мод загружен.")
end)

registerForEvent("onUpdate", function()
    local player = Game.GetPlayer()
    if not player then return end

    local vehicle = Game.GetMountedVehicle(player)

    if vehicle and vehicle ~= lastVehicle then
        local entity = vehicle:GetEntityID()
        local hash = tostring(entity.hash)

        if not vehicleData[hash] then
            local record = vehicle:GetRecord()
            local displayName = "Неизвестно"

            if record and record:DisplayName() then
                displayName = Game.GetLocalizedText(record:DisplayName())
            end

            local fuel = randomFuelPercent()

            vehicleData[hash] = {
                name = displayName,
                id = nextId,
                fuel = fuel -- от 0.2 до 1.0
            }

            nextId = nextId + 1
        end

        local data = vehicleData[hash]
        carName = data.name
        carID = data.id
        fuelPercent = data.fuel
        showHUD = true
        lastVehicle = vehicle

    elseif not vehicle then
        showHUD = false
        lastVehicle = nil
    end
end)

registerForEvent("onDraw", function()
    if showHUD then
        ImGui.SetNextWindowBgAlpha(0.4)
        ImGui.Begin("Информация о машине", nil, ImGuiWindowFlags.AlwaysAutoResize)
        ImGui.Text("Машина: " .. carName)
        ImGui.Text("Уникальный ID: " .. tostring(carID))
        ImGui.Text(string.format("Топливо: %d%% / %d%%", math.floor(fuelPercent * 100), fuelMaxPercent))
        ImGui.End()
    end
end)
