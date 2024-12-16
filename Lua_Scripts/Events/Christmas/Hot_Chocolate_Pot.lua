-- 🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾
-- 🐾 🕹️ Script: Christmas - Hot Chocolate Pot (Cooking)
-- 🐾 📅 Version: 1.0 (2024-12-16)
-- 🐾 🐈 GitHub: <https://github.com/Sophie-Williams>
-- 🐾 📜 Released under The Unlicense: <https://unlicense.org>
-- 🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾🐾

-- 🔗 Dependencies
local API = require("api")

-- 🛠️ Settings
API.Write_fake_mouse_do(false)
API.SetDrawTrackedSkills(true)
API.SetMaxIdleTime(math.random(3, 5))
local ENABLE_BREAKS = true -- AFK while cooking, ignores ingredients for X minutes.
local MIN_BREAK_SECONDS = 480 -- 8 mins
local MAX_BREAK_SECONDS = 1440 -- 24 mins

-- 📡 Listener
API.GatherEvents_chat_check()

-- 🐞 Debug
local DEBUG = true
local MSG = nil
local function log(text)
	if DEBUG and MSG ~= text then print(text) MSG = text end
end

-- 🌱 Seed the random number generator
math.randomseed(os.time())

-- ⚡ Action Control
local MAX_ACTIONS_PER_SECOND = 5
local lastActionTime = os.time() * 1000
local actionCount = 0
local function resetActionCount()
    local currentTime = os.time() * 1000
    if (currentTime > (lastActionTime + 1000)) then
        actionCount = 0
        lastActionTime = currentTime
    end
end

-- ⏳ Idle Detection
local lastAnimationCheckTime = 0
local idleStartTime = nil
local idleTimeRequired = math.random(2222, 4444)

-- 💤 Break Management
local takingBreak = false
local breakEndTime = os.time()
local breakChance = 100
local triggerThreshold = math.random(100, 300)
local lastBreakCheckTime = os.time()
local lastBreakPrintTime = os.time()
local function handleTakeBreak()
    if ENABLE_BREAKS and os.time() - lastBreakCheckTime > 2 then
        lastBreakCheckTime = os.time()
        local triggerRoll = math.random(1, 10000)
        if triggerRoll <= triggerThreshold then
            log(string.format("Break check triggered! Roll: %.2f%% / Required: %.2f%%", triggerRoll / 100, triggerThreshold / 100))
            local breakRoll = math.random(1, 10000)
            if breakRoll <= breakChance then
                log(string.format("Break activated! Rolled: %.2f%% (Needed: %.2f%%)", breakRoll / 100, breakChance / 100))
                breakChance = 100
				breakEndTime = os.time() + math.random(MIN_BREAK_SECONDS, MAX_BREAK_SECONDS)
				log(string.format("Taking a break for %d mins.", math.floor(os.difftime(breakEndTime, os.time()) / 60)))
				takingBreak = true
            else
                local increment = math.random(5, 20)
                breakChance = math.min(10000, breakChance + increment)
                log(string.format("No break. Chance increased to: %.2f%% (+%.2f%%)", breakChance / 100, increment / 100))
            end
        end
    end
    return false
end

-- 🍫️ Ingredients List
local INGREDIENTS = {
    ["firewood"] = { object = 131821, item = 57932, text = "<col=FFFF00>Aoife</col>: <col=99FF99>Oh no, it's barely simmering anymore. Could you fetch some more firewood?</col>" },
    ["chocolate"] = { object = 131823, item = 57933, text = "<col=FFFF00>Aoife</col>: <col=99FF99>Tastes a tad weak. I think we need another handful of chocolate chunks.</col>" },
    ["sugar"] = { object = 131822, item = 57934, text = "<col=FFFF00>Aoife</col>: <col=99FF99>That's good but slightly too bitter. We need a sprinkle of sugar to sweeten it up.</col>" },
    ["milk"] = { object = 131824, item = 57935, text = "<col=FFFF00>Aoife</col>: <col=99FF99>It's starting to thicken up. Let's add a splash of milk.</col>" },
    ["spice"] = { object = 131825, item = 57936, text = "<col=FFFF00>Aoife</col>: <col=99FF99>Flavour's a little plain. I reckon we're ready to add another dash of spice.</col>" }
}

-- 🔍 Ingredient Detection
local function CheckForIngredients()
    local count = 0
    for _, v in pairs(API.GatherEvents_chat_check() or {}) do
        count = count + 1
        if count > 5 then break end
        for name, data in pairs(INGREDIENTS) do
            if string.find(v.text or "", data.text, 1, true) then
                API.RandomSleep2(math.random(888, 1444), 345, 876)
                log("Ingredient detected: " .. name)
				local clickCount = (math.random(1, 100) <= math.random(4, 8)) and 2 or ((math.random(1, 100) <= math.random(1, 5)) and 3 or 1)
                log("Clicking " .. clickCount .. " time(s) on " .. name)
                for i = 1, clickCount do
                    resetActionCount()
                    if actionCount < MAX_ACTIONS_PER_SECOND then
                        API.DoAction_Object1(0x2d, API.OFF_ACT_GeneralObject_route0, { data.object }, 20)
                        actionCount = actionCount + 1
                        log("Click " .. i .. " on " .. name)
                        API.RandomSleep2(math.random(84, 149), 12, 19)
                    end
                end
				log("Waiting for pickup animation then idle...")
				local idleStartTime_Ingredients = os.time() * 1000
				local retryPerformed = false
				while true do
					if API.InvItemFound2({ data.item }) then
						log("Item detected. Returning to cooking pot..")
						API.RandomSleep2(math.random(124, 364), 71, 103)
						API.DoAction_Object1(0x40, API.OFF_ACT_GeneralObject_route0, { 131826 }, 20)
						state = "cooking"
						handleTakeBreak()
						return true
					end
					local idleDuration_Ingredients = (os.time() * 1000) - idleStartTime_Ingredients
					if idleDuration_Ingredients > math.random(3000, 5000) then
						if not retryPerformed then
							log("Idle detected. Retrying item pickup action...")
							API.DoAction_Object1(0x2d, API.OFF_ACT_GeneralObject_route0, { data.object }, 50)
							retryPerformed = true
							idleStartTime_Ingredients = os.time() * 1000
						else
							log("Still idle after retry. Returning to cooking pot.")
							API.RandomSleep2(math.random(124, 364), 71, 103)
							API.DoAction_Object1(0x40, API.OFF_ACT_GeneralObject_route0, { 131826 }, 20)
							state = "cooking"
							return true
						end
					end
					API.RandomSleep2(10, 3, 5)
				end
            end
        end
    end
    return false
end

-- 🤖 Bot State
local state = "idle"
local firstLoop = true

print("Running Script: Christmas - Hot Chocolate Pot (Cooking)")

-- 🐈 *slaps tummy* it fit many loop, brother 🍩🍪🍘🥮🍥
while API.Read_LoopyLoop() do
	if API.InvFull_() then
		print("Inventory is full. Please ensure at least one empty slot before starting the script.")
		break
	end
    API.DoRandomEvents()
    local currentTime = os.time() * 1000
    local playerAnim = API.ReadPlayerAnim() or 0
    local timeSinceLastAnimationCheck = currentTime - lastAnimationCheckTime
    if timeSinceLastAnimationCheck > 1000 then
        log("Current playerAnim: " .. playerAnim)
        lastAnimationCheckTime = currentTime
    end
	if not takingBreak and not firstLoop then
		handleTakeBreak()
	else
		local breakTimeLeft = os.difftime(breakEndTime, os.time())
		if os.time() - lastBreakPrintTime >= 5 then
			log(string.format("Break time remaining: %02d:%02d..", math.floor(breakTimeLeft / 60), breakTimeLeft % 60))
			lastBreakPrintTime = os.time()
		end
		if breakTimeLeft > 0 then
			API.RandomSleep2(250, 50, 100)
		else
			log("Break over. Resuming.")
			takingBreak = false
		end
		goto continue
	end
	if state == "cooking" then
		if playerAnim == 0 then
			if not idleStartTime then
				idleStartTime = currentTime
				idleTimeRequired = math.random(2222, 4444)
				log(string.format("Idle timer started. Waiting for %d ms of idle.", idleTimeRequired))
			else
				local idleDuration = currentTime - idleStartTime
				if idleDuration >= idleTimeRequired then
					log("Idle detected. Attempting to interact with the hot chocolate pot...")
					resetActionCount()
					if actionCount < MAX_ACTIONS_PER_SECOND then
						API.DoAction_Object1(0x40, API.OFF_ACT_GeneralObject_route0, { 131826 }, 20)
						actionCount = actionCount + 1
						log("Hot chocolate pot interaction successful.")
						handleTakeBreak()
					else
						log("Rate limit reached. Skipping action.")
					end
					idleStartTime = nil
				end
			end
		else
			if idleStartTime then
				log("Animation changed. Resetting idle timer.")
			end
			idleStartTime = nil
		end
		if CheckForIngredients() then
			log("Ingredient collected. Returned to cooking.")
			idleStartTime = nil
		end
	end
    if state == "idle" and not API.InvFull_() then
        log("Switching to cooking state.")
        state = "cooking"
    end
    ::continue::
	firstLoop = false
    resetActionCount()
    API.RandomSleep2(math.random(30, 60), 20, 50)
end

print("Script stopped.")

-- 🛑 🐾🐾🐾 End of Script 🐾🐾🐾 🛑
