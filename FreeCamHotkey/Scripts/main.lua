-- Life is Strange Remastered / UE4SS FreeCamHotkey v7
-- Keyboard 1: toggle free camera (existing, proven v2 logic)
-- Xbox controller: hold BOTH LS click (L3) + RS click (R3) for >= 1.5 seconds.
-- One toggle per hold; release both stick buttons before trying again.
-- Controller support experimental: uses reflected PlayerController input APIs.

local UEHelpers = require("UEHelpers")
local cameraEnabledByMod = false

local GAMEPAD_HOLD_SECONDS = 1.5
local GAMEPAD_POLL_MS = 75
local GAMEPAD_RELEASE_POLLS = 5
local gamepadLatched = false
local gamepadReleasePolls = 0
local gamepadPollQueued = false
local gamepadErrorLogged = false
local lastInputControllerLabel = nil

local function log(message)
    print("[LiS FreeCamHotkey v7] " .. tostring(message) .. "\n")
end

local function valid(object)
    return object ~= nil and object:IsValid()
end

-- Unchanged from the user's working v2 script.
local function ensureCheatManager(controller)
    if not valid(controller) then
        error("Player controller unavailable")
    end

    local cheatManager = controller.CheatManager
    if valid(cheatManager) then
        return cheatManager
    end

    local cheatManagerClass = StaticFindObject("/Script/Engine.CheatManager")
    if not valid(cheatManagerClass) then
        error("Cannot find /Script/Engine.CheatManager")
    end

    cheatManager = StaticConstructObject(cheatManagerClass, controller)
    if not valid(cheatManager) then
        error("Failed to construct CheatManager for controller")
    end

    controller.CheatManager = cheatManager
    log("Constructed CheatManager for camera/controller")
    return cheatManager
end

-- Same proven v2 toggle logic, callable by both inputs.
-- This MUST execute on the Unreal game thread.
local function toggleCamera(source)
    local ok, errorMessage = pcall(function()
        if cameraEnabledByMod then
            local debugController = FindFirstOf("DebugCameraController")
            if not valid(debugController) then
                cameraEnabledByMod = false
                log("DebugCameraController no longer exists; state reset. Try toggling again.")
                return
            end

            local debugCheatManager = ensureCheatManager(debugController)
            debugCheatManager:DisableDebugCamera()
            cameraEnabledByMod = false
            log("DisableDebugCamera() invoked via " .. source)
        else
            local playerController = UEHelpers.GetPlayerController()
            local playerCheatManager = ensureCheatManager(playerController)
            playerCheatManager:EnableDebugCamera()
            cameraEnabledByMod = true
            log("EnableDebugCamera() invoked via " .. source)
        end
    end)

    if not ok then
        log("ERROR during " .. source .. ": " .. tostring(errorMessage))
    end
end

-- Keep the original keyboard hotkey unchanged in behavior.
RegisterKeyBind(Key.ONE, function()
    -- After a keyboard toggle the other controller's stale held-key time can
    -- still exceed 1.5 seconds. Require a fresh physical release first.
    gamepadLatched = true
    gamepadReleasePolls = 0
    ExecuteInGameThread(function()
        toggleCamera("keyboard 1")
    end)
end)

-- Unreal FKey values are plain structures with an FName KeyName field.
-- Do NOT use UE4SS Key table here: its bindings only cover keyboard/mouse.
local function makeFKey(name)
    local keyName
    if EFindName and EFindName.FNAME_Find then
        keyName = FName(name, EFindName.FNAME_Find)
    else
        keyName = FName(name)
    end
    return { KeyName = keyName }
end

-- The debug camera is itself a PlayerController. While it is enabled,
-- UEHelpers.GetPlayerController() can still return the old gameplay controller,
-- which stops receiving gamepad input. Poll the *active debug controller*.
local function getGamepadInputController()
    if cameraEnabledByMod then
        local debugController = FindFirstOf("DebugCameraController")
        if valid(debugController) then
            return debugController, "debug camera controller"
        end
        -- Do not silently fall back to the now-inactive gameplay controller.
        -- The script logs this once on each transition and keyboard 1 can
        -- still switch off via the working v2 method.
        return nil, "debug camera controller missing"
    end
    return UEHelpers.GetPlayerController(), "gameplay controller"
end

local function pollGamepad()
    local pc, label = getGamepadInputController()
    if label ~= lastInputControllerLabel then
        lastInputControllerLabel = label
        log("Polling gamepad input from: " .. label)
    end
    if not valid(pc) then
        return
    end

    local leftKey = makeFKey("Gamepad_LeftThumbstick")
    local rightKey = makeFKey("Gamepad_RightThumbstick")
    local leftDown = pc:IsInputKeyDown(leftKey) == true
    local rightDown = pc:IsInputKeyDown(rightKey) == true

    if not leftDown and not rightDown then
        -- Controller transfer can briefly report released buttons. Wait for
        -- five consecutive released samples on the active controller.
        if gamepadLatched then
            gamepadReleasePolls = gamepadReleasePolls + 1
            if gamepadReleasePolls >= GAMEPAD_RELEASE_POLLS then
                gamepadLatched = false
                gamepadReleasePolls = 0
            end
        end
        return
    end

    gamepadReleasePolls = 0
    if not (leftDown and rightDown) then
        return
    end

    if gamepadLatched then
        return
    end

    -- Unreal tracks the physical hold duration for each input separately.
    -- Both must have been held for the full threshold.
    local leftHeld = tonumber(pc:GetInputKeyTimeDown(leftKey)) or 0
    local rightHeld = tonumber(pc:GetInputKeyTimeDown(rightKey)) or 0

    if leftHeld >= GAMEPAD_HOLD_SECONDS and rightHeld >= GAMEPAD_HOLD_SECONDS then
        gamepadLatched = true
        log("L3 + R3 held >= 1.5s on " .. label .. "; toggling once")
        toggleCamera("gamepad L3+R3")
    end
end

log("Loaded v7. Keyboard 1 = toggle; hold gamepad L3+R3 for 1.5s = toggle.")

-- UE4SS v3 supports LoopAsync; all Unreal UObject access is dispatched to
-- the game thread. Keep the keyboard binding working if polling throws.
LoopAsync(GAMEPAD_POLL_MS, function()
    if not gamepadPollQueued then
        gamepadPollQueued = true
        ExecuteInGameThread(function()
            local ok, err = pcall(pollGamepad)
            gamepadPollQueued = false
            if not ok and not gamepadErrorLogged then
                gamepadErrorLogged = true
                log("GAMEPAD POLL ERROR: " .. tostring(err))
                log("Keyboard 1 remains available; if needed restore v2 main.lua.")
            elseif ok and gamepadErrorLogged then
                gamepadErrorLogged = false
                log("Gamepad polling recovered")
            end
        end)
    end
    return false
end)
