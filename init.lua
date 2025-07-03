fuelLevel = 0.0
local maxFuel = 50.0
local usageRate = 0.015
local vehicleModel = ""
local isStalled = false

local fuelData = {
    ["Vehicle.v_sport1_quadra_type66"] = {tank = 60, usage = 0.02},
    ["Vehicle.v_sport2_arch_nemesis"]  = {tank = 30, usage = 0.012},
    ["Vehicle.v_standard_makigai_maimai"] = {tank = 20, usage = 0.008},
    ["default"] = {tank = 45, usage = 0.015}
}

local fuelStations = {
    { x = -1815.1484, y = -4279.305, z = 74.013214}, -- примеры, замени на реальные координаты
    { x = -1691.2699, y = -4992.2637, z = 80.20087},
    { x = -1143.5033, y = -5593.301, z = 93.201355},
    { x = -150.86494, y = -1975.8818, z = 5.8980026},
    { x = -265.55054, y = -1884.5828, z = 8.612251},
    { x = 742.8937, y = -1026.6295, z = 27.927948}

}

function getVehicleModel()
    local veh = Game.GetMountedVehicle()
    if veh then
        local record = veh:GetRecordID()
        if record then
            return TDBID.ToStringDEBUG(record)
        end
    end
    return "unknown"
end

function isNearFuelStation(pos)
    for _, station in ipairs(fuelStations) do
        local dx = station.x - pos.x
        local dy = station.y - pos.y
        local dz = station.z - pos.z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
        if dist < 6.0 then return true end
    end
    return false
end

registerForEvent("onUpdate", function(delta)
    vehSys = Game.GetMountedVehicle(Game.GetPlayer())

    if vehSys then
        local modelNow = getVehicleModel()
        if modelNow ~= vehicleModel then
            vehicleModel = modelNow
            local fuelConf = fuelData[vehicleModel] or fuelData["default"]
            maxFuel = fuelConf.tank
            usageRate = fuelConf.usage
            fuelLevel = maxFuel * 0.8 -- старт при входе
            print("[FuelSystem] Машина: " .. vehicleModel .. ", Топливо: " .. fuelLevel .. "/" .. maxFuel)
        end

        if fuelLevel > 0 then
            if vehSys:IsEngineOn() then
                fuelLevel = fuelLevel - (delta * usageRate)
                if fuelLevel <= 0 then
                    fuelLevel = 0
                    isStalled = true
                    vehSys:TurnEngineOff()
                    print("[FuelSystem] Машина заглохла.")
                end
            end
        else
            if not isStalled then
                vehSys:TurnEngineOff()
                isStalled = true
            end
        end

        local playerPos = Game.GetPlayer():GetWorldPosition()
        if isNearFuelStation(playerPos) and fuelLevel < maxFuel then
            fuelLevel = fuelLevel + delta * 3.0
            if fuelLevel > maxFuel then fuelLevel = maxFuel end
        end
    else
        isStalled = false
    end
end)

registerHotkey("refuel_test", "Заправить вручную", function()
    fuelLevel = maxFuel
    print("[FuelSystem] Заправлено вручную.")
end)

registerForEvent("onDraw", function()
    if fuelLevel and maxFuel then
        local percent = math.floor((fuelLevel / maxFuel) * 100)
        ImGui.SetNextWindowBgAlpha(0.3)
        ImGui.Begin("Топливо", true, ImGuiWindowFlags.AlwaysAutoResize)
        ImGui.Text("Топливо: " .. string.format("%.1f", fuelLevel) .. " / " .. maxFuel .. " (" .. percent .. "%)")
        ImGui.End()
    end
end)