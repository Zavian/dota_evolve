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
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
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