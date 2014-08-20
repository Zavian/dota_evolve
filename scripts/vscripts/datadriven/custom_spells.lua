function CastingHeal(keys) --DEPRECATED
	--Fired when someone casts the "heal_target" spell.
	PrintTable(keys)
	print(keys.caster:GetName())
	print(keys.target:GetName())
	
end

function ChannelingShield(keys)
	-- Event fired when I channel the shield
	local caster = keys.caster
	local spell = caster:FindAbilityByName("shield_target")
	local n = 0
	-- A timer running every second that starts immediately on the next frame, respects pauses
  	local t = Timers:CreateTimer(function()
		modifierData = {
			duration = 1.0,
			damage_absorb = 1000,
			radius = 0
		}
		caster:AddNewModifier(caster, nil, "modifier_abaddon_aphotic_shield", modifierData)

 		n = n + 1
		
      	if(n == 3) then 
      		return nil      		
  		else 
  			return 1.0
  		end

    end
  )

end