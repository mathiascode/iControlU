function HandleControlCommand(Split, Controller)
	if Split[3] == nil then
		Controller:SendMessageInfo("Usage: " .. Split[1] .. " " .. Split[2] .. " <player>")
	else
		local Control = function(Target)
			if Target:HasPermission("icu.exempt") then
				Controller:SendMessageFailure("You can't control this player")
			elseif Target == Controller then
				Controller:SendMessageFailure("You are already controlling yourself")
			elseif TargetFor[Controller:GetUniqueID()] then
				Controller:SendMessageFailure("You are already controlling \"" .. Target:GetName() .. "\"")
			elseif ControllerFor[Target:GetUniqueID()] then
				Controller:SendMessageFailure("Player \"" .. Target:GetName() .. "\" is already being controlled")
			elseif TargetFor[Target:GetUniqueID()] then
				Controller:SendMessageFailure("Player \"" .. Target:GetName() .. "\" is already controlling another player")
			else
				if Controller:GetWorld() ~= Target:GetWorld() then
					Controller:MoveToWorld(Target:GetWorld(), true, Vector3d(Target:GetPosX() + 0.5, Target:GetPosY(), Target:GetPosZ() + 0.5 ))
				else
					Controller:TeleportToEntity(Target)
				end

				ControllerPreferences[Controller:GetUniqueID()] =
				{
					CurrentXp = Controller:GetCurrentXp(),
					FlyingMaxSpeed = Controller:GetFlyingMaxSpeed(),
					FoodExhaustionLevel = Controller:GetFoodExhaustionLevel(),
					FoodLevel = Controller:GetFoodLevel(),
					FoodSaturationLevel = Controller:GetFoodSaturationLevel(),
					FoodTickTimer = Controller:GetFoodTickTimer(),
					Health = Controller:GetHealth(),
					InvulnerableTicks = Controller:GetInvulnerableTicks(),
					IsFireproof = Controller:IsFireproof(),
					MaxHealth = Controller:GetMaxHealth(),
					NormalMaxSpeed = Controller:GetNormalMaxSpeed(),
					SprintingMaxSpeed = Controller:GetSprintingMaxSpeed(),
				}

				for i=0,40 do
					Controller:GetInventory():SetSlot(i, Target:GetInventory():GetSlot(i))
				end

				Controller:SetCurrentExperience(Target:GetCurrentXp())
				Controller:SetFlying(Target:IsFlying())
				Controller:SetFlyingMaxSpeed(Target:GetFlyingMaxSpeed())
				Controller:SetFoodExhaustionLevel(Target:GetFoodExhaustionLevel())
				Controller:SetFoodLevel(Target:GetFoodLevel())
				Controller:SetFoodSaturationLevel(Target:GetFoodSaturationLevel())
				Controller:SetFoodTickTimer(Target:GetFoodTickTimer())
				Controller:SetHeadYaw(Target:GetHeadYaw())
				Controller:SetHealth(Target:GetHealth())
				Controller:SetInvulnerableTicks(Target:GetInvulnerableTicks())
				Controller:SetIsFireproof(Target:IsFireproof())
				Controller:SetMaxHealth(Target:GetMaxHealth())
				Controller:SetNormalMaxSpeed(Target:GetNormalMaxSpeed())
				Controller:SetPitch(Target:GetPitch())
				Controller:SetYaw(Target:GetYaw())
				Controller:SetSprintingMaxSpeed(Target:GetSprintingMaxSpeed())

				TargetFor[Controller:GetUniqueID()] = Target
				ControllerFor[Target:GetUniqueID()] = Controller

				Controller:SendMessageSuccess("You are now controlling \"" .. Target:GetName() .. "\"")
			end
		end
		if Split[3] == "" or not cRoot:Get():FindAndDoWithPlayer(Split[3], Control) then
			Controller:SendMessageFailure("Player \"" .. Split[3] .. "\" not found")
			return true
		end
	end
	return true
end

function HandleStopCommand(Split, Controller)
	local Target = TargetFor[Controller:GetUniqueID()]
	if Target then
		TargetFor[Controller:GetUniqueID()] = nil
                ControllerFor[Target:GetUniqueID()] = nil

		if Target:IsFrozen() then
			Target:Unfreeze()
		end

		ResetPlayerPreferences(Controller)

		Controller:GetWorld():ScheduleTask(200,
			function()
				Controller:SetVisible(true)
				Controller:RemoveEntityEffect(cEntityEffect.effInvisibility)
				Controller:SendMessageInfo("You are now visible")
			end
		)

		Controller:SendMessageSuccess("You are no longer controlling \"" .. Target:GetName() .. "\". You are invisible for 10 seconds.")
	else
		Controller:SendMessageFailure("You are not controlling anyone at the moment")
	end
	return true
end
