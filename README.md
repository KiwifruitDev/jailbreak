# Just an otter JailBreak 7 fork

## Developers
### Scriptdays
Scriptdays are scripted free-days that wardens can choose to enable via the warden menu.

![Gang War Day](https://cdn.discordapp.com/attachments/513244749759512581/521099462995738648/gangwarday.png)

To add a scriptday, simply add a line near the end of cl_menu_scriptday.lua (there should already be a scriptday there) stating the following information:
``createScriptDayEntry("Title","Description","ActivationLine",Material("icon16/star.png"))``

``ActivationLine`` will be used in the second part, and the material line is to be an icon used in the warden menu.


After adding that line, add a line to sv_warden.lua under ``concommand.Add("jb_warden_scriptday",function(p,c,a)`` where the ``if (lr == "GangWarDay") then`` statement is. Add an ``elseif (lr == "ActivationLine") then`` above the ``end``, from there you are free to add anything at will!



### Pointshop support 
Pointshop support was added to support various powerups and models. ``[ply]`` refers to a player entity.

To set a model, add the model string to ``[ply]._prisonermodel`` for a prisoners-only model, or ``[ply]._guardmodel`` for a guards-only model.

The power-ups can be set by setting ``[ply]:SetNWString("powerup",[powerupstring])``, with ``[powerupstring]`` being the string for the selected power-up. The following power-ups are:

* "gunpunt"
	* Enables the 'Weapon Punt' power-up, which is activated once the player's current weapon clip has reached half it's amount, however their clip size is halved after reloading.
	
Here is an example power-up lua file:
```lua
	ITEM.Name = 'Weapon Punt'
	ITEM.Price = 500
	ITEM.Model = 'models/items/boxsrounds.mdl'
	ITEM.Description = "Shooting will punt you backwards, use wisely!\nActivated once your clip has reached half it's amount.\nCons: Your clip size is halved after reloading."
	ITEM.NoPreview = true

	function ITEM:OnEquip(ply, modifications)
		ply:SetNWString("powerup","gunpunt")
	end

	function ITEM:OnHolster(ply)
		ply:SetNWString("powerup","")
	end
```
And an example playermodel lua file:
```lua
	ITEM.Name = 'Combine Prison Guard'
	ITEM.Price = 300
	ITEM.Model = 'models/player/combine_soldier_prisonguard.mdl'
	ITEM.Team = TEAM_GUARD

	function ITEM:OnEquip(ply, modifications)
		timer.Simple(1, function()
			ply._guardmodel = self.Model
			if ply:Team() == self.Team then
				ply:SetModel(self.Model)
			end 
		end)
	end

	function ITEM:OnHolster(ply)
		ply._guardmodel = nil
		if ply:Team() == self.Team then
			print(self.Player._guardmodel)
			if self.Player._guardmodel then
				self.Player:SetModel(self.Player._guardmodel)
			else
				self.Player:SetModel(Model("models/player/Group01/male_09.mdl"))
			end
		end
	end

	function ITEM:PlayerSetModel(ply)
		ply._guardmodel = self.Model
		if ply:Team() == self.Team then
			ply:SetModel(self.Model)
		end
	end
```
It is recommended that you add support for the ``self.Team`` part in Pointshop itself.

### Last requests
This is how last requests are added. LR files have to put put in the lastrequests folder
```lua

	-- Initialize a new LR class
	local LR = JB.CLASS_LR();

	-- Give it a name and description
	LR:SetName("Knife Battle");
	LR:SetDescription("The guard and the prisoner both get a knife, all other weapons are stripped, and they must fight eachother until one of the two dies");

	-- Give it an Icon for in the LR-menu
	LR:SetIcon(Material("icon16/flag_blue.png"))

	-- Setup what happens after somebody picks this Last Request
	LR:SetStartCallback(function(prisoner,guard)
		for _,ply in ipairs{prisoner,guard} do
			ply:StripWeapons();
			ply:Give("weapon_jb_knife");
			ply:Give("weapon_jb_fists");
			
			ply:SetHealth(100);
			ply:SetArmor(0);
		end
	end)

	-- Tell JailBreak that this LR is ready for use.
	LR();
```

### Hooks

These are all custom hooks called by the gamemode.
Format: `hookname ( arguments[, optional argument] )`

```lua
-- JailBreakRoundStart
-- Called when the round starts
JailBreakRoundStart ( rounds_passed )

-- JailBreakRoundEnd 
-- Called when the round ends
JailBreakRoundEnd ( rounds_passed )

-- JailBreakPlayerSwitchTeam
-- Called on team switch
JailBreakPlayerSwitchTeam ( player, team )

-- JailBreakStartMapvote
-- Called when a mapvote should be started.
-- return true: Use custom mapvote system, return false: Use default system (normally; no mapvote).
JailBreakStartMapvote ( rounds_passed, extentions_passed ) 

-- JailBreakClaimWarden
-- Called when somebody claims warden
JailBreakClaimWarden ( player, warden_rounds_in_a_row )

-- JailBreakWardenControlChanged
-- Called when a warden control is changed
JailBreakWardenControlChanged	( player, option, value )

-- JailBreakWardenSpawnProp
-- Called when the warden spawns a prop
JailBreakWardenSpawnProp ( player, type[, model] )

-- JailBreakWardenPlacePointer
-- Called when a pointer is placed
JailBreakWardenPlacePointer ( player, type, position )

```

Implement a hook using the `hook.Add` function, example:

```lua
hook.Add("JailBreakRoundStart","JB.Examples.RoundStart",function(rounds_passed) 
	if rounds_passed > 5 then
		print "We are past round 5. Let's kill everyone!";
		
		for _,ply in ipairs( player.GetAll() ) do
			ply:Kill();
		end
	end
end);
```
