local vehicleData = {}
local lastVehicle = nil
local nextId = 1

local showHUD = false
local carName = "Нет данных"
local carID = 0

registerForEvent("onInit", function()
    print("[CarIdentifier] Мод загружен.")
end)

registerForEvent("onUpdate", function()
    local player = Game.GetPlayer()
    if not player then return end

    -- Получаем текущую машину, в которой сидит игрок
    local vehicle = Game.GetMountedVehicle(player)

    if vehicle and vehicle ~= lastVehicle then
        local entity = vehicle:GetEntityID()
        local hash = tostring(entity.hash)  -- Уникальный ID объекта

        if not vehicleData[hash] then
            local record = vehicle:GetRecord()
            local displayName = "Неизвестно"

            if record and record:DisplayName() then
                displayName = Game.GetLocalizedText(record:DisplayName())
            end

            vehicleData[hash] = {
                name = displayName,
                id = nextId
            }

            nextId = nextId + 1
        end

        -- Сохраняем данные для HUD
        local data = vehicleData[hash]
        carName = data.name
        carID = data.id
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
        ImGui.Text("🚘 Машина: " .. carName)
        ImGui.Text("🆔 Уникальный ID: " .. tostring(carID))
        ImGui.End()
    end
end)

