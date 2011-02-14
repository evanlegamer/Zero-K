local function lowerkeys(t)
  local tn = {}
  for i,v in pairs(t) do
    local typ = type(i)
    if type(v)=="table" then
      v = lowerkeys(v)
    end
    if typ=="string" then
      tn[i:lower()] = v
    else
      tn[i] = v
    end
  end
  return tn
end

local function noFunc()
end

--------------------------------------------------------------------------------
-- system functions
--------------------------------------------------------------------------------
mapWeaponToCEG = {
	[3] = {3,4},
	[5] = {1,2},
}

function ApplyWeapon(unitDef, weapon)
	local wcp = weapons[weapon].customparams or {}
	local slot = tonumber(wcp and wcp.slot) or 4
	unitDef.weapons[slot] = {
		def = weapon,
		badtargetcategory = wcp.badtargetcategory or [[FIXEDWING]],
		onlytargetcategory = wcp.onlytargetcategory or [[FIXEDWING LAND SINK SHIP SWIM FLOAT GUNSHIP HOVER]],
	}
	unitDef.weapondefs[weapon] = CopyTable(weapons[weapon], true)
	-- clear other weapons
	if slot > 3 then
		for i=4,6 do	-- subject to change
			if unitDef.weapons[i] and i ~= slot then
				unitDef.weapons[i] = nil
			end
		end
	end
	-- add CEGs
	if mapWeaponToCEG[slot] and unitDef.sfxtypes and unitDef.sfxtypes.explosiongenerators then
		unitDef.sfxtypes.explosiongenerators[mapWeaponToCEG[slot][1]] = wcp.muzzleeffect or unitDef.sfxtypes.explosiongenerators[mapWeaponToCEG[slot][1]] or [[custom:NONE]]
		unitDef.sfxtypes.explosiongenerators[mapWeaponToCEG[slot][2]] = wcp.misceffect or unitDef.sfxtypes.explosiongenerators[mapWeaponToCEG[slot][2]] or [[custom:NONE]]
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
commTypes = {
	recon = {
		[1] = CopyTable(UnitDefs.commrecon),
		[2] = CopyTable(UnitDefs.commadvrecon),
	},
	strike = {
		[1] = CopyTable(UnitDefs.armcom),
		[2] = CopyTable(UnitDefs.armadvcom),
	},
	battle = {
		[1] = CopyTable(UnitDefs.corcom),
		[2] = CopyTable(UnitDefs.coradvcom),
	},
	support = {
		[1] = CopyTable(UnitDefs.commsupport),
		[2] = CopyTable(UnitDefs.commadvsupport),
	},
}
]]--

weapons = {}

local weaponsList = VFS.DirList("gamedata/modularcomms/weapons", "*.lua") or {}
for i=1,#weaponsList do
	local name, array = VFS.Include(weaponsList[i])
	weapons[name] = lowerkeys(array)
end

-- name and description don't actually matter ATM, only the keyname and function do
upgrades = {
	-- weapons
	-- it is important that they are prefixed with "commweapon_" in order to get the special handling!
	commweapon_autoflechette = {
		name = "Autoflechette",
		description = "For when a regular shotgun isn't enough",
		func = noFunc,	
	},
	commweapon_beamlaser = {
		name = "Beam Laser",
		description = "An effective short-range cutting tool",
		func = noFunc,	
	},
	commweapon_disruptor = {
		name = "Disruptor Beam",
		description = "Damages and slows a target",
		func = noFunc,	
	},
	commweapon_heavymachinegun = {
		name = "Heavy Machine Gun",
		description = "Close-in weapon with AoE",
		func = noFunc,	
	},
	commweapon_heatray = {
		name = "Heat Ray",
		description = "Rapidly melts anything at short range; loses damage over distance",
		func = noFunc,	
	},
	commweapon_gaussrifle = {
		name = "Gauss Rifle",
		description = "Precise armor-piercing weapon",
		func = noFunc,	
	},
	commweapon_riotcannon = {
		name = "Riot Cannon",
		description = "The weapon of choice for crowd control",
		func = noFunc,	
	},
	commweapon_rocketlauncher = {
		name = "Rocket Launcher",
		description = "Medium-range low-velocity hitter",
		func = noFunc,	
	},
	commweapon_shockrifle = {
		name = "Shock Rifle",
		description = "A sniper weapon that inflicts heavy damage to a single target",
		func = noFunc,	
	},
	commweapon_shotgun = {
		name = "Shotgun",
		description = "Can hammer a single large target or shred many small ones",
		func = noFunc,
	},
	commweapon_slowbeam = {
		name = "Slowing Beam",
		description = "Slows an enemy's movement and firing rate; non-lethal",
		func = noFunc,	
	},
	
	-- modules
	module_ablative_armor = {
		name = "Ablative Armor Plates",
		description = "Adds 600 HP",
		func = function(unitDef)
				unitDef.maxdamage = unitDef.maxdamage + 600
			end,
	},	
	module_high_power_servos = {
		name = "High Power Servos",
		description = "More powerful leg servos increase speed by 15% (cumulative)",
		func = function(unitDef)
				unitDef.customparams = unitDef.customparams or {}
				unitDef.customparams.basespeed = unitDef.customparams.basespeed or tostring(unitDef.maxvelocity)
				unitDef.maxvelocity = (unitDef.maxvelocity or 0) + unitDef.customparams.basespeed*0.15
			end,
	},	
	module_fieldradar = {
		name = "Field Radar Module",
		description = "Basic radar system with 1800 range",
		func = function(unitDef)
				unitDef.radardistance = (unitDef.radardistance or 0)
				if unitDef.radardistance < 1800 then unitDef.radardistance = 1800 end
			end,
	},
	module_autorepair = {
		name = "Autorepair System",
		description = "Self-repairs 10 HP/s",
		func = function(unitDef)
				unitDef.autoheal = (unitDef.autoheal or 0) + 10
			end,
	},
	module_adv_nano = {
		name = "CarRepairer's Nanolathe",
		description = "Used by a mythical mechanic/coder, this improved nanolathe adds +3 metal/s build speed",
		func = function(unitDef)
				if unitDef.workertime then unitDef.workertime = unitDef.workertime + 3 end
			end,
	},
	module_energy_cell = {
		name = "Energy Cell",
		description = "Compact fuel cells that produce +4 energy",
		func = function(unitDef)
				unitDef.energymake = (unitDef.energymake or 0) + 4
			end,
	},		
	
	module_cloak_field = {
		name = "Cloaking Field",
		description = "Cloaks all friendly units within 350 elmos",
		func = function(unitDef)
				unitDef.customparams = unitDef.customparams or {}
				unitDef.customparams.cloakshield_preset = "module_cloakfield"
			end,
	},
	module_repair_field = {
		name = "Repair Field",
		description = "Passively repairs all friendly units within 450 elmos",
		func = function(unitDef)
				unitDef.customparams = unitDef.customparams or {}
				unitDef.customparams.repairaura_preset = "module_repairfield"
			end,
	},
	module_jammer = {
		name = "Radar Jammer",
		description = "Masks radar signals of all units within 600 elmos",
		func = function(unitDef)
				unitDef.radardistancejam = 600
				unitDef.activatewhenbuilt = true
				unitDef.onoffable = true
			end,
	},
	module_areashield = {
		name = "Area Shield",
		description = "Bubble shield that protects surrounding units within 300 elmos",
		func = function(unitDef)
				ApplyWeapon(unitDef, "commweapon_areashield")
				unitDef.activatewhenbuilt = true
				unitDef.onoffable = true
			end,
	},
	
	-- some old stuff
	adv_composite_armor = {
		name = "Advanced Composite Armor",
		description = "Improved armor increases commander health by 20%",
		func = function(unitDef)
				unitDef.maxdamage = unitDef.maxdamage * 1.2
			end,
	},
	focusing_prism = {
		name = "Focusing Prism",
		description = "Reduces laser attenuation - increases primary weapon range by 20%",
		func = function(unitDef)
				if not (unitDef.weapons and unitDef.weapondefs) then return end
				local wepName = (unitDef.weapons[4] and unitDef.weapons[4].def) or (unitDef.weapons[1] and unitDef.weapons[1].def)
				wepName = string.lower(wepName)
				unitDef.weapondefs[wepName].range = unitDef.weapondefs[wepName].range * 1.2
			end,
	},
}

