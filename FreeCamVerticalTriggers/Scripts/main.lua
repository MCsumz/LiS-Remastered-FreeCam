-- Adds Xbox RT/LT vertical motion to Unreal's debug camera.
-- FreeCamHotkey remains responsible for the 1 and L3+R3 toggles.

local POLL_MS = 16
local queued = false
local failed = false
local loggedInput = false
local keys

local function log(message)
    print("[LiS FreeCamVerticalTriggers] " .. tostring(message) .. "\n")
end

local function valid(object)
    return object ~= nil and object:IsValid()
end

local function key(name)
    -- Add the name if needed. FNAME_Find can return None for an axis the game
    -- has not used yet, which would make trigger reads silently return zero.
    return { KeyName = FName(name) }
end

local function poll()
    local controller = FindFirstOf("DebugCameraController")
    if not valid(controller) then
        loggedInput = false
        return
    end

    local pawn = controller:GetSpectatorPawn()
    if not valid(pawn) then
        loggedInput = false
        return
    end

    if not keys then
        keys = {
            rtAxis = key("Gamepad_RightTriggerAxis"),
            ltAxis = key("Gamepad_LeftTriggerAxis"),
            rtButton = key("Gamepad_RightTrigger"),
            ltButton = key("Gamepad_LeftTrigger"),
        }
    end

    local rightAxis = tonumber(controller:GetInputAnalogKeyState(keys.rtAxis)) or 0
    local leftAxis = tonumber(controller:GetInputAnalogKeyState(keys.ltAxis)) or 0
    local rightButton = controller:IsInputKeyDown(keys.rtButton) == true
    local leftButton = controller:IsInputKeyDown(keys.ltButton) == true
    local up = math.max(rightAxis, rightButton and 1 or 0)
    local down = math.max(leftAxis, leftButton and 1 or 0)

    if up <= 0.05 and down <= 0.05 then
        return
    end

    if not loggedInput then
        loggedInput = true
        log(string.format("Trigger input: RT axis %.2f, button %s; LT axis %.2f, button %s",
            rightAxis, tostring(rightButton), leftAxis, tostring(leftButton)))
    end

    pawn:MoveUp_World(up - down)
end

log("Loaded. RT = camera up, LT = camera down while debug camera is active.")

LoopAsync(POLL_MS, function()
    if not queued and not failed then
        queued = true
        ExecuteInGameThread(function()
            local ok, err = pcall(poll)
            queued = false
            if not ok then
                failed = true
                log("Trigger movement disabled after error: " .. tostring(err))
            end
        end)
    end
    return false
end)
