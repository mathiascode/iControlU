function OnChat(Player, Message)
	if ControllerFor[Player:GetUniqueID()] then
		return true
	end
	if TargetFor[Player:GetUniqueID()] then
		local Target = TargetFor[Player:GetUniqueID()]
		cRoot:Get():BroadcastChat("<" .. Target:GetName() .. "> " .. Message)
		return true
	end
end

function OnEntityChangingWorld(Controller, World)
        if Controller:IsPlayer() then
		local Target = TargetFor[Controller:GetUniqueID()]
		if Target then
			Target:MoveToWorld(World)
		end
        end
end

function OnExecuteCommand(Target, CommandSplit, EntireCommand)
	if Target and ControllerFor[Target:GetUniqueID()] then
		return true, cPluginManager.crExecuted
	end
end

function OnPlayerAnimation(Controller, Animation)
	local Target = TargetFor[Controller:GetUniqueID()]
	if Target then
		Controller:GetClientHandle():SendEntityAnimation(Target, Animation)
	end
end

function OnPlayerDestroyed(Player)
	cRoot:Get():ForEachPlayer(
		function(OtherPlayer)
			-- Target disconnects
			if ControllerFor[Player:GetUniqueID()] == OtherPlayer then
				TargetFor[OtherPlayer:GetUniqueID()] = nil
				ControllerFor[Player:GetUniqueID()] = nil

				ResetPlayerPreferences(OtherPlayer)

				OtherPlayer:GetWorld():ScheduleTask(200,
					function()
						OtherPlayer:SetVisible(true)
					end
				)
				OtherPlayer:SendMessageInfo("The player you were controlling has disconnected. You are invisible for 10 seconds.")
			end
			-- Controller disconnects
			if TargetFor[Player:GetUniqueID()] == OtherPlayer then
				TargetFor[Player:GetUniqueID()] = nil
				ControllerFor[OtherPlayer:GetUniqueID()] = nil
				if OtherPlayer:IsFrozen() then
					OtherPlayer:Unfreeze()
				end
			end
		end
	)
end

function OnPlayerLeftClick(Target, BlockX, BlockY, BlockZ, BlockFace, Action)
	if ControllerFor[Target:GetUniqueID()] then
		return true
	end
end

PlayerCoords = {}

function OnPlayerMoving(Target, OldPosition, NewPosition)
	if ControllerFor[Target:GetUniqueID()] then
		return true
	end
end

function OnPlayerRightClick(Target, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if ControllerFor[Target:GetUniqueID()] then
		return true
	end
end

function OnPlayerSpawned(Target)
	if ControllerFor[Target:GetUniqueID()] then
		local Controller = ControllerFor[Target:GetUniqueID()]
		Controller:TeleportToCoords(Target:GetPosX(), Target:GetPosY(), Target:GetPosZ())
	end
end

function OnPlayerTossingItem(Target)
	if ControllerFor[Target:GetUniqueID()] then
		return true
	end
end

function OnTakeDamage(Receiver, TDI)
	if Receiver:IsPlayer() and TargetFor[Receiver:GetUniqueID()] then
		return true
	end
end

function OnWorldTick(World, TimeDelta)
	local UpdatePreferences = function(Target)
		local Controller = ControllerFor[Target:GetUniqueID()]
		if Controller then
			for i=0,40 do
				if Controller:GetInventory():GetSlot(i) ~= Target:GetInventory():GetSlot(i) then
					Target:GetInventory():SetSlot(i, Controller:GetInventory():GetSlot(i))
				end
			end
			if Target:GetHealth() > 0 then
				Target:TeleportToEntity(Controller)
			end
			Target:Freeze(Target:GetPosition())
			Target:SendRotation(Controller:GetYaw(), Controller:GetPitch())
			Target:SetHeadYaw(Controller:GetHeadYaw())
			Target:SetCrouch(Controller:IsCrouched())
			Target:SetCurrentExperience(Controller:GetCurrentXp())
			Target:SetFlyingMaxSpeed(Target:GetFlyingMaxSpeed())
			Target:SetFoodExhaustionLevel(Controller:GetFoodExhaustionLevel())
			Target:SetFoodLevel(Controller:GetFoodLevel())
			Target:SetFoodSaturationLevel(Controller:GetFoodSaturationLevel())
			Target:SetFoodTickTimer(Controller:GetFoodTickTimer())
			Target:SetHealth(Controller:GetHealth())
			Target:SetInvulnerableTicks(Controller:GetInvulnerableTicks())
			Target:SetIsFireproof(Controller:IsFireproof())
			Target:SetMaxHealth(Controller:GetMaxHealth())
			Target:SetNormalMaxSpeed(Target:GetNormalMaxSpeed())
			Target:SetSprint(Controller:IsSprinting())
			Target:SetSprintingMaxSpeed(Target:GetSprintingMaxSpeed())

			Controller:SetVisible(false)
		end
	end
	World:ForEachPlayer(UpdatePreferences)
end
