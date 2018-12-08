-- ####################################################################################
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     CASUAL BANANAS CONFIDENTIAL                                                ##
-- ##                                                                                ##
-- ##     __________________________                                                 ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Copyright 2014 (c) Casual Bananas                                          ##
-- ##     All Rights Reserved.                                                       ##
-- ##                                                                                ##
-- ##     NOTICE:  All information contained herein is, and remains                  ##
-- ##     the property of Casual Bananas. The intellectual and technical             ##
-- ##     concepts contained herein are proprietary to Casual Bananas and may be     ##
-- ##     covered by U.S. and Foreign Patents, patents in process, and are           ##
-- ##     protected by trade secret or copyright law.                                ##
-- ##     Dissemination of this information or reproduction of this material         ##
-- ##     is strictly forbidden unless prior written permission is obtained          ##
-- ##     from Casual Bananas                                                        ##
-- ##                                                                                ##
-- ##     _________________________                                                  ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ##     Casual Bananas is registered with the "Kamer van Koophandel" (Dutch        ##
-- ##     chamber of commerce) in The Netherlands.                                   ##
-- ##                                                                                ##
-- ##     Company (KVK) number     : 59449837                                        ##
-- ##     Email                    : info@casualbananas.com                          ##
-- ##                                                                                ##
-- ##                                                                                ##
-- ####################################################################################


local function claimWarden(p,c,a)
	if not IsValid(p) or p:Team() ~= TEAM_GUARD or JB.State ~= STATE_SETUP or IsValid(JB:GetWarden()) then return end

	if p.wardenRounds and p.wardenRounds >= tonumber(JB.Config.maxWardenRounds) and (  CurTime() - JB.RoundStartTime ) < 20 then
		p:SendQuickNotification("You have to give others a chance to claim warden.");
		return;
	end
	for _,ply in ipairs( player.GetAll() ) do
		ply:SendLua( string.format( "surface.PlaySound( %q )", "otterjailbreak/lc_spawncount.mp3" ))
	end
	p:AddWardenStatus();

	if not p.wardenRounds then
		p.wardenRounds = 1;
	else
		p.wardenRounds = p.wardenRounds + 1;
	end

	for _,v in pairs(team.GetPlayers(TEAM_GUARD))do
		if IsValid(v) and v ~= p and p.wardenRounds then 
			p.wardenRounds = 0;
		end
	end

	hook.Call("JailBreakClaimWarden",JB.Gamemode,p,p.wardenRounds);
end

JB.Util.addChatCommand("warden",claimWarden)
concommand.Add("jb_claim_warden",claimWarden);

concommand.Add("jb_warden_changecontrol",function(p,c,a)
	if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not IsValid(JB.TRANSMITTER) then return end
	
	local opt = a[1];
	local val = a[2];
	
	if not opt or not val then 
		return	
	elseif opt == "PVP" then
		JB.TRANSMITTER:SetJBWarden_PVPDamage(tobool(val));
		JB:BroadcastNotification("Friendly fire is now "..(tobool(val) and "enabled" or "disabled"));
	elseif opt == "Pickup" then
		JB.TRANSMITTER:SetJBWarden_ItemPickup(tobool(val));
		JB:BroadcastNotification("Item pickup is now "..(tobool(val) and "enabled" or "disabled"));
	end

	hook.Call("JailBreakWardenControlChanged",JB.Gamemode,p,opt,val);
end);

local function spawnProp(p,typ,model)
	local spawned = 0;
	for k,v in pairs(ents.GetAll())do
		if v and IsValid(v) and v.wardenSpawned then
			spawned = spawned + 1;
		end
	end
	if spawned > tonumber(JB.Config.maxWardenItems) then
		p:SendQuickNotification("You can not spawn over "..tostring(JB.Config.maxWardenItems).." items.");
		return
	end

	local prop = ents.Create(typ);
	prop:SetAngles(p:GetAngles());
	prop:SetPos(p:EyePos() + p:GetAngles():Forward() * 60);
	
	if model then
		prop:SetModel(model)
	end
	prop:Spawn();
	prop:Activate();
	prop.wardenSpawned = true;

	hook.Call("JailBreakWardenSpawnProp",JB.Gamemode,p,typ,model);
end
concommand.Add("jb_warden_grapplinghooks",function(p,c,a)
	if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
	JB:BroadcastNotification("All prisoners now have grappling hooks!");
	for _,ply in ipairs(team.GetPlayers(TEAM_PRISONER)) do
		local grapple = ents.Create( "sent_grapplehook_bpack" )
		grapple:SetSlotName( "sent_grapplehook_bpack" )
		grapple:Spawn()
		grapple:SetKey( 36 )
		print(grapple:GetKey().." 36")
		if not grapple:Attach( ply, true ) then
			print("removed grappling hook")
			grapple:Remove()
			return
		end
	end
end);
concommand.Add("jb_warden_spawn",function(p,c,a)
	if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
	
	local opt = a[1];
	
	if not opt then 
		return
	elseif opt == "HotDog" then
		spawnProp(p,"jb_hotdog")
	elseif opt == "Crate" then
		spawnProp(p,"prop_physics_multiplayer","models/props_junk/wood_crate001a.mdl")
	elseif opt == "Blockade" then
		spawnProp(p,"prop_physics_multiplayer","models/props_trainstation/TrackSign02.mdl")
	elseif opt == "AmmoBox" then
		spawnProp(p,"jb_ammobox")
	end
end);
concommand.Add("jb_warden_scriptday",function(p,c,a)
	if not IsValid(p) or not p.GetWarden or not p:GetWarden() or not tobool(JB.Config.wardenControl) then return end
	if (IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBScriptday() == "") then	
		local lr = a[1];
		JB.TRANSMITTER:SetJBScriptday(lr)
		for k,v in ipairs(ents.FindByClass("func_door"))do
			v:Fire("Open",1)
		end
		for k,v in ipairs(ents.FindByClass("func_door_rotating"))do
			v:Fire("Open",1)
		end
		for k,v in ipairs(ents.FindByClass("func_movelinear"))do
			v:Fire("Open",1)
		end
		
		--ADD SCRIPTDAYS HERE AND IN SV_MENU_SCRIPTDAY.LUA--

		if (lr == "GangWarDay") then
			JB:BroadcastNotification("The warden has initiated Gang War Day!");
			JB:BroadcastNotification("All prisoners now have grappling hooks!");
			print("Gang War Day has started.")
			for _,ply in ipairs( player.GetAll() ) do
				ply:SendLua( string.format( "surface.PlaySound( %q )", "otterjailbreak/gangwarday.wav" ))
				ply:StripWeapons();
				ply:Give("weapon_jb_fists");
				ply:Give("weapon_jb_knife");
				ply:Give("weapon_jb_usp")
				ply:Give("weapon_jb_mac10")
				ply:SelectWeapon("weapon_jb_mac10")
			end
			for _,ply in ipairs(team.GetPlayers(TEAM_PRISONER)) do
				ply:SetModel( "models/player/bloodz/slow_3.mdl" )
				local grapple = ents.Create( "sent_grapplehook_bpack" )
				grapple:SetSlotName( "sent_grapplehook_bpack" )
				grapple:Spawn()
				grapple:SetKey( 36 )
				print(grapple:GetKey().." 36")
				if not grapple:Attach( ply, true ) then
					print("removed grappling hook")
					grapple:Remove()
					return
				end
			end
			for _,ply in ipairs(team.GetPlayers(TEAM_GUARD)) do
				ply:SetModel( "models/player/cripz/slow_3.mdl" )
			end
		end
	end
end)

local pointerRemove = -1;
concommand.Add("jb_warden_placepointer",function(p,c,a)
	if not IsValid(p) or not p.GetWarden or not p:GetWarden() then return end

	local typ = tostring(a[1]);
	if not typ then return end;
	local pos = p:GetEyeTrace().HitPos;
	if typ ~= "0" then
		JB:DebugPrint("Warden "..p:Nick().." has placed a marker at "..tostring(pos));
		JB:BroadcastQuickNotification("The warden has placed a marker");
		for _,ply in ipairs( player.GetAll() ) do
			if typ == "generic" then
				ply:SendLua( string.format( "surface.PlaySound( %q )", "coach/coach_go_here.wav" ))
			elseif typ == "exclamation" then
				ply:SendLua( string.format( "surface.PlaySound( %q )", "coach/coach_attack_here.wav" ))
			elseif typ == "question" then
				ply:SendLua( string.format( "surface.PlaySound( %q )", "coach/coach_look_here.wav" ))
			elseif typ == "line" then
				ply:SendLua( string.format( "surface.PlaySound( %q )", "coach/coach_go_here.wav" ))
			elseif typ == "cross" then
				ply:SendLua( string.format( "surface.PlaySound( %q )", "coach/coach_defend_here.wav" ))
			end
		end
	end

	pointerRemove = CurTime()+120;

	JB.TRANSMITTER:SetJBWarden_PointerPos(pos);
	JB.TRANSMITTER:SetJBWarden_PointerType(typ);

	hook.Call("JailBreakWardenPlacePointer",JB.Gamemode,p,typ,pos);
end);

hook.Add("Think","JB.Think.PointerTimeout",function()
	if CurTime() > pointerRemove and pointerRemove ~= -1 then
		JB.TRANSMITTER:SetJBWarden_PointerType("0");
	end
end);