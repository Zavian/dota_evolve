function ChannelingShield(keys)
	-- Event fired when I channel the shield
	local caster = keys.caster
	local target = keys.target
	local spell = caster:FindAbilityByName("shield_target")
	local modifier = "modifier_abaddon_aphotic_shield"
	local n = 0
	local duration = 3
	local tick = 1.0
	
	-- A timer running every second that starts immediately on the next frame, respects pauses
  	Timers:CreateTimer(function()
			modifierData = {			--This will decide the modifier's behavior
				duration = 1.0,			--The duration of the shield
				damage_absorb = 1000,	--How much will absorb
				radius = 0				--The explosion radius
			}
			target:AddNewModifier(target, nil, modifier, modifierData)

			-- n will count how much times this timer will be fired
			-- duration will be the casting duration
	 		n = n + 1
	      	if(n == duration) then 
	      		return nil      		
	  		else -- This will make the timer restart after tick seconds
	  			return tick
	  		end
	    end
	)

end

function LeaveTrailTest(keys)
	local caster = keys.caster

	--Considering that I don't know how to rotate the model
	--it's better having a high frequency so the player
	--will be able to guess the direction
	local trailFrequency = 2.0
	local trailIndex = 1
	local trails = {}
	local trailMax = 20


	Timers:CreateTimer(function()
			--Here I reset whatever is in the slot where I'll place my entity
			if(trails[trailIndex]) then 
				trails[trailIndex]:Destroy() 
			end

			local location = caster:GetAbsOrigin() 	--The location of the player in that moment

			--Creating a unit which will be neutral (so will not give vision)
			local dummy_unit = CreateUnitByName("npc_evolve_trail", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
			--print("[TRAILS] Placed trail number "..trailIndex)
			trails[trailIndex] = dummy_unit	--Saving the entity for optimization purposes


			trailIndex = trailIndex + 1
			if(trailIndex == trailMax + 1) then -- +1 for code design purposes
				trailIndex = 1
			end
			local modifiers = { 
			"modifier_invulnerable", 						--The unit will be invulnerable
			"modifier_riki_permanent_invisibility", 		--The unit will be invisile
			"modifier_phased",								--The unit won't collide with others
			"MODIFIER_STATE_UNSELECTABLE"					--The unit won't be selectable
			}
			for i=1, table.getn(modifiers) do
				dummy_unit:AddNewModifier(dummy_unit, nil, modifiers[i], nil)
			end
			return trailFrequency
		end
	)
end

