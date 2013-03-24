-- $Id: unit_noselfpwn.lua 3171 2008-11-06 09:06:29Z det $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mod statistics",
    desc      = "Gathers mod statistics",
    author    = "Licho",
    date      = "29.3.2009",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if VFS.FileExists("mission.lua") then
  -- stats are meaningless in missions
  return
end

  
if (not gadgetHandler:IsSyncedCode()) then
  return false  --  silent removal
end

local damages = {}     -- damages[attacker][victim] = { damage, emp} 
local unitCounts = {}  -- unitCounts[defID] = { created, destroyed}
local lastPara = {}


local Echo = Spring.Echo
local spGameOver = Spring.IsGameOver
local spGetUnitHealth = Spring.GetUnitHealth
local spAreTeamsAllied = Spring.AreTeamsAllied

local gaiaTeamID = Spring.GetGaiaTeamID()
  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- drones are counted as parent for damage done, ignored for damage received
-- key = drone, value = parent
local drones = {
	carrydrone = "armcarry",
	wolverine_mine = "corgarp",
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, 
                            weaponID, attackerID, attackerDefID, attackerTeam)

	if unitTeam == gaiaTeamID then
		return
	end	
							
	if (attackerID == nil or  unitDefID == nil or damage == nil) or (not attackerTeam) or (attackerTeam == unitTeam) or (damage < 0)  or spAreTeamsAllied(attackerTeam, unitTeam) then 
		if (paralyzer) then 
			local hp, maxHp, paraDam = spGetUnitHealth(unitID)	
			local paraHp = maxHp - paraDam
			if paraHp < 0 then paraHp = 0 end
			lastPara[unitID] = paraHp
		end
		return
	end
	
	
	-- treat as different unit as needed
	if drones[UnitDefs[unitDefID].name] then
		return
	end
	if drones[UnitDefs[attackerDefID].name] then
		local name = drones[UnitDefs[attackerDefID].name]
		attackerDefID = (UnitDefNames[name] and UnitDefNames[name].id) or attackerDefID
	end	
	local attackerAlias = UnitDefs[attackerDefID].customParams.statsname
	if attackerAlias and UnitDefNames[attackerAlias] then
		attackerDefID = UnitDefNames[attackerAlias].id
	end
	local defenderAlias = UnitDefs[unitDefID].customParams.statsname
	if defenderAlias and UnitDefNames[defenderAlias] then
		unitDefID = UnitDefNames[defenderAlias].id
	end
	
	
	local hp, maxHp, paraDam, capture, build = spGetUnitHealth(unitID)		
	
	if build >= 1 then 

		local tab = damages[attackerDefID]
		if (tab == nil) then 
			tab = {}
			damages[attackerDefID] = tab
		end
		local dam = tab[unitDefID] 
		if (dam == nil) then
			dam = {0,0}
			tab[unitDefID] = dam
		end

		local h
		if (paralyzer)  then h = lastPara[unitID] or maxHp
		else h = hp + damage end 
	
		if h < 0 then h = 0 end
		if h > maxHp then h = maxHp end
		if (damage > h) then damage = h end

		if (paralyzer) then
			dam[2] = dam[2] + damage 
		else 
			dam[1] = dam[1] + damage  
		end
	end

	local paraHp = maxHp - paraDam
	if paraHp < 0 then paraHp = 0 end	
	lastPara[unitID] = paraHp
end


function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	lastPara[unitID] = nil

	local unitAlias = UnitDefs[unitDefID].customParams.statsname
	if unitAlias and UnitDefNames[unitAlias] then
		unitDefID = UnitDefNames[unitAlias].id
	end	
	
	if (builderID == nil) then 
		local tab = unitCounts[unitDefID]
		if (tab == nil) then
			tab = {0,0}
			unitCounts[unitDefID] = tab
		end
		tab[1] = tab[1] + 1
	end
end


function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	lastPara[unitID] = nil

	local unitAlias = UnitDefs[unitDefID].customParams.statsname
	if unitAlias and UnitDefNames[unitAlias] then
		unitDefID = UnitDefNames[unitAlias].id
	end	
	
	local tab = unitCounts[unitDefID]
	if (tab == nil) then
		tab = {0,0}
		unitCounts[unitDefID] = tab
	end
	tab[1] = tab[1] + 1
end


function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	lastPara[unitID] = nil	

	local unitAlias = UnitDefs[unitDefID].customParams.statsname
	if unitAlias and UnitDefNames[unitAlias] then
		unitDefID = UnitDefNames[unitAlias].id
	end
	
	local tab = unitCounts[unitDefID]
	if (tab == nil) then
		tab = {0,0}
		unitCounts[unitDefID] = tab
	end
	tab[2] = tab[2] + 1
end

function SendData(statsData) 
	Spring.SendCommands("wbynum 255 SPRINGIE:stats,".. statsData)
end 

function gadget:GameOver()
	if GG.Chicken then
		Spring.Log(gadget:GetInfo().name, LOG.INFO, "Chicken game; unit stats disabled")
		return	-- don't report stats in chicken
	end
	Spring.Echo("Submitting stats")
	for atk, victims in pairs(damages) do
		for victim, dam in pairs(victims) do
			SendData("dmg,"..UnitDefs[atk].name .. ",".. UnitDefs[victim].name .. "," .. dam[1] .. "," .. dam[2])
		end
	end

	for unit, counts in pairs(unitCounts) do
		SendData("unit,"..UnitDefs[unit].name .. ",".. UnitDefs[unit].metalCost ..",".. counts[1] .. "," .. counts[2] .. "," .. UnitDefs[unit].health)
	end

	local teams = Spring.GetTeamList()
	local humanAlly = {}
	local players = 0
	gaiaTeam = Spring.GetGaiaTeamID()
	for _, teamID in ipairs(teams) do

		local teamLuaAI = Spring.GetTeamLuaAI(teamID)
		if ((teamLuaAI == nil or teamLuaAI == "") and teamID ~= gaiaTeam) then
			local _,_,_,ai,side,ally = Spring.GetTeamInfo(teamID)
			if (not ai) then 
				humanAlly[ally] = 1
				players = players + 1
			end	
		end
	end
	local allycount = 0
	for _,_ in pairs(humanAlly) do allycount = allycount + 1 end

	SendData("teams,"..players .. ",".. allycount)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
