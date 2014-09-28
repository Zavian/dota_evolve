function itemRessurecting(keys)
	local target = keys.target
	--local target_entity = keys.target_entities[1]
	if(target:GetUnitName() == "npc_evolve_tombstone") then
		local owner = target:GetPlayerOwner()
		local hero = owner:GetAssignedHero()
		local spawner = Entities:FindAllByClassname("info_player_start_goodguys")[1]
		spawner:SetAbsOrigin(target:GetAbsOrigin())
		target:Destroy()
		hero:RespawnHero(false, false, false)
		spawner:Destroy()
	end
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

local shotSucceded = false
local savingTime = 0.0
local timeSpent 

--HEALER
	--HEAL SHOT
		local toHeal = 0
		local HealShot_maxCast = 15

		function StartedHealShot(keys)
			savingTime = Time()
			print(savingTime)
		end

		function InterruptedHealShot(keys)
			caster = keys.caster
			ability = keys.ability
			maxHeal = keys.MaxHeal
			local currentTime = Time()	
			timeSpent = math.floor(currentTime - savingTime)
			local percentage = math.floor((timeSpent*100) / HealShot_maxCast)
			toHeal = (percentage * maxHeal) / 100
		end

		function SuccededHealShot(keys)
			toHeal = keys.MaxHeal
		end

		function HitHealShot(keys)
			target  = keys.target	
			target:Heal(toHeal, nil)
		end
	--SHIELD TARGET
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
--END HEALER

--TRAPPER
	--SLOW SHOT
		local toSlow = 0

		function StartedSlowShot(keys)
			savingTime = Time()
			print(savingTime)
		end

		function InterruptedSlowShot(keys)
			caster = keys.caster
			ability = keys.ability
			local currentTime = Time()	
			timeSpent = math.floor(currentTime - savingTime)
			local percentage = math.floor((timeSpent*100) / keys.MaxCast)
			toSlow = (percentage * keys.MaxSlow) / 100
		end

		function SuccededSlowShot(keys)
			toSlow = keys.MaxSlow
		end

		function HitSlowShot(keys)
			target  = keys.target
			local modifier = "modifier_item_orb_of_venom_slow"
			print(toSlow)
			local modifierSlow = -math.floor(toSlow)
			local modifierData = {
				damage = 0, 
				slow = modifierSlow, 
				duration = 5
			}
			target:AddNewModifier(target, nil, modifier, modifierData)
		end
	--USE NET
		local spellCooldown = 4.0
		local netCounted = 0
		local maxNets = 4

		function UseNetCasted(keys)
			print("Casted use_net")
			local caster = keys.caster
			local abilityLevel = caster:FindAbilityByName("use_net"):GetLevel()
			caster:RemoveAbility("use_net")

			caster:AddAbility("use_net_counting")
			caster:FindAbilityByName("use_net_counting"):SetLevel(abilityLevel)
			local spellDuration = keys.SpellDuration
			

			Timers:CreateTimer({
				  	endTime = spellDuration,
				  	callback = function()
					  	--This if will trigger if the caster hasn't finished the nets
					  	if(caster:FindAbilityByName("use_net_counting")) then
					  	  	caster:RemoveAbility("use_net_counting")
					  	  	caster:AddAbility("use_net")
					  	  	caster:FindAbilityByName("use_net"):SetLevel(abilityLevel)
					  	  	caster:FindAbilityByName("use_net"):StartCooldown(keys.SpellCooldown)
					  	end
				  	end
			  	})
		end


		function UseNetCountingCasted(keys)
			--print("Casted use_net_counting")
			netCounted = netCounted + 1
			print(netCounted)
			if(netCounted == 4) then
				netCounted = 0
				local caster = keys.caster
				local abilityLevel = caster:FindAbilityByName("use_net_counting"):GetLevel()
				caster:RemoveAbility("use_net_counting")
		  	  	caster:AddAbility("use_net")
		  	  	caster:FindAbilityByName("use_net"):SetLevel(abilityLevel)
		  	  	caster:FindAbilityByName("use_net"):StartCooldown(keys.SpellCooldown)
			end
		end
	--ARENA
		function PlaceArena(keys)
			print("Placing arena")
			local center = keys.target
			local centerLocation = center:GetAbsOrigin()
			--print("X: "..centerLocation.x)
			--print("Y: "..centerLocation.y)
			
			local boundLocation = centerLocation
			local cog = {}
			local cogDuration = 5
			local cogNumber = 30

			local modifiers = { 
				"modifier_invulnerable", 						--The unit will be invulnerable
				"MODIFIER_STATE_UNSELECTABLE"					--The unit won't be selectable
			}	
			local x = centerLocation.x
			local y = centerLocation.y
			local r = 400

			--Here I create a circle with these properties:
			--x and y are the center location of the circle
			--r it's the radius of the circle
			--cogNumber is how many cogs I want in the circle
			--cogDuration is how much will last the cog (see the summon_arena in npc_abilities)
			--cog it's just the array which will contain all the cogs that I'm going to create	
			for i = 1, cogNumber do
			  local angle = i * math.pi / (cogNumber/2)
			  local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )
			  boundLocation.x = ptx
			  boundLocation.y = pty
			  cog[i] = CreateUnitByName("npc_evolve_arena_bound", boundLocation, false, nil, nil, TEAM_RADIANT)
			  for j=1,table.getn(modifiers) do
			  	cog[i]:AddNewModifier(cog[i], nil, modifiers[j], nil)
			  end
			end

			Timers:CreateTimer({					-- This timer determines when the arena will be destroyed
				  	endTime = cogDuration,
				  	callback = function()
				  		for i=1,table.getn(cog) do
					  		cog[i]:Destroy()
					  	end		  	
				  	end
		  	})
		end
--END TRAPPER

--TRACKER
	--TRACKING MINE
		function MineLanded(keys)
			local target = keys.target
			spell = target:FindAbilityByName("trigger_mine")
			if(spell) then
				spell:SetLevel(1)
			end
		end

		function MineTriggered(keys)
			local caster = keys.caster
			local casterName = caster:GetName()
			if (string.match(casterName, "bounty")) then
				--Gotta do the trigger mine from the hero
			else
				local location = caster:GetAbsOrigin()
				local dummy_unit = CreateUnitByName("npc_evolve_vision", location, false, nil, nil, caster:GetTeam())
				local modifiers = { 
				"modifier_invulnerable", 						--The unit will be invulnerable
				"modifier_riki_permanent_invisibility", 		--The unit will be invisile
				"modifier_phased",								--The unit won't collide with others
				"MODIFIER_STATE_UNSELECTABLE"					--The unit won't be selectable
				}
				for i=1, table.getn(modifiers) do
					dummy_unit:AddNewModifier(dummy_unit, nil, modifiers[i], nil)
				end
				caster:Destroy()
				
				--Here I created a vision unit, which will give us vision for a certain time
			  	Timers:CreateTimer({
				  	endTime = keys.VisionDuration,
				  	callback = function()
				  	  dummy_unit:Destroy()
				  	end
			  	})
			end
		end
--END TRACKER

--BRAWLER	
	--DEVASTATING FIST
		function DevastatingFistCasted(keys)
			local caster = keys.caster
			local target = keys.target
			local level = caster:FindAbilityByName("devastating_fist"):GetLevel()
			local percentageDamage = keys.Percentage
			local enemyHP = target:GetHealth()
			local damage = math.floor((percentageDamage * enemyHP) / 100)
				local damageTable = {
				victim = target,
				attacker = keys.caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_PURE
			}
			ApplyDamage(damageTable)
		end
--END BRAWLER

--GOLIATH
	--LEAPING SMASH
		function LeapingSmashRotationCasted(keys)
			local rotation = "leaping_smash_rotation"
			local leap = "mirana_leap"
			local smash = "leaping_smash_damage"
			local caster = keys.caster
			local level = caster:FindAbilityByName(rotation):GetLevel()

			targetPosition = keys.target_points[1]
			caster:MoveToPosition(targetPosition)
			caster:Hold()
			caster:RemoveAbility(rotation)

			caster:AddAbility(leap)
			caster:FindAbilityByName(leap):SetLevel(1)
			caster:CastAbilityImmediately(caster:FindAbilityByName(leap), caster:GetEntityIndex())
			caster:RemoveAbility(leap)

			caster:AddAbility(rotation)
			caster:FindAbilityByName(rotation):SetLevel(level)

			Timers:CreateTimer({
			  	endTime = .35,
			  	callback = function()
				  	caster:AddAbility(smash)
					caster:FindAbilityByName(smash):SetLevel(level)
					caster:CastAbilityImmediately(caster:FindAbilityByName(smash), caster:GetEntityIndex())
					caster:RemoveAbility(smash)
			  	end
		  	})			
		end
--END GOLIATH












