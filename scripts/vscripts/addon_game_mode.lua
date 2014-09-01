require('evolve')
require('util')
require('timers') --Thank you BMD for the awesome library


if Evolve == nil then
	Evolve = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	for i=1, table.getn(ALL) do
		PrecacheUnitByNameSync(ALL[i], context)
		--print(ALL[i])
	end
	print("[EVOLVE] Precached everything")


end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = Evolve()
	GameRules.AddonTemplate:InitGameMode()
end

function Evolve:InitGameMode()
	print( "[EVOLVE] Game loaded" )
	print("")
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	ListenToGameEvent('entity_killed', Dynamic_Wrap(Evolve, 'OnEntityKilled'), self)
	print("[BRAIN] Looking for dead ppl")
end

-- Evaluate the state of the game
function Evolve:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function Evolve:OnEntityKilled(keys)
	local entity = keys.entindex_killed
	local npc = EntIndexToHScript(entity)
	if(npc and npc:GetUnitName() == "npc_evolve_arena_center") then
		t = Entities:FindAllByModel("models/heroes/rattletrap/rattletrap_cog.vmdl")
		local n = 0
		for i = 1, table.getn(t) do
			if(t[i]:GetUnitName() == "npc_evolve_arena_bound") then
				t[i]:Destroy()
			end
		end
		--print("Found "..n.." cogs")
	end
end