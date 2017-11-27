ControllerPreferences = {}
ControllerFor = {}
TargetFor = {}

function Initialize(Plugin)
	Plugin:SetName(g_PluginInfo.Name)
	Plugin:SetVersion(g_PluginInfo.Version)

	cPluginManager:AddHook(cPluginManager.HOOK_CHAT, OnChat)
	cPluginManager:AddHook(cPluginManager.HOOK_ENTITY_CHANGING_WORLD, OnEntityChangingWorld)
	cPluginManager:AddHook(cPluginManager.HOOK_EXECUTE_COMMAND, OnExecuteCommand)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_ANIMATION, OnPlayerAnimation)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK, OnPlayerLeftClick)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, OnPlayerSpawned)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_TOSSING_ITEM, OnPlayerTossingItem)
	cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE, OnTakeDamage)
	cPluginManager:AddHook(cPluginManager.HOOK_WORLD_TICK, OnWorldTick)

	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function ResetPlayerPreferences(Controller)
	local OriginalController = ControllerPreferences[Controller:GetUniqueID()]

	Controller:GetInventory():Clear()
	Controller:SetCurrentExperience(OriginalController.CurrentXp)
	Controller:SetFlyingMaxSpeed(OriginalController.FlyingMaxSpeed)
	Controller:SetFoodExhaustionLevel(OriginalController.FoodExhaustionLevel)
	Controller:SetFoodLevel(OriginalController.FoodLevel)
	Controller:SetFoodSaturationLevel(OriginalController.FoodSaturationLevel)
	Controller:SetFoodTickTimer(OriginalController.FoodTickTimer)
	Controller:SetHealth(OriginalController.Health)
	Controller:SetInvulnerableTicks(OriginalController.InvulnerableTicks)
	Controller:SetIsFireproof(OriginalController.IsFireproof)
	Controller:SetMaxHealth(OriginalController.MaxHealth)
	Controller:SetNormalMaxSpeed(OriginalController.NormalMaxSpeed)
	Controller:SetSprintingMaxSpeed(OriginalController.SprintingMaxSpeed)

	ControllerPreferences[Controller:GetUniqueID()] = nil
end

function OnDisable()
        cRoot:Get():ForEachPlayer(
		function(Controller)
			local Target = TargetFor[Controller:GetUniqueID()]
			if Target then
				if Target:IsFrozen() then
					Target:Unfreeze()
				end

				ResetPlayerPreferences(Controller)
				Controller:SetVisible(true)
				Controller:SendMessageInfo("You are no longer controlling \"" .. Target:GetName() .. "\" due to server reload")
			end
		end
	)
	LOG("Disabled " .. cPluginManager:GetCurrentPlugin():GetName() .. "!")
end
