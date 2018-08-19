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

JB.Gamemode.PlayerInitialSpawn = function(gm,ply)
	ply:SetTeam(TEAM_PRISONER) -- always spawn as prisoner;
	JB:DebugPrint(ply:Nick().." has successfully joined the server.");
	--ply:ConCommand("snd_restart") --if they join the server with the content addon, their sound may not work properly
end;


JB.Gamemode.PlayerSpawn = function(gm,ply)
		if (ply:Team() ~= TEAM_PRISONER and ply:Team() ~= TEAM_GUARD) or
			(not ply._jb_forceRespawn and (JB.State == STATE_LASTREQUEST or JB.State == STATE_PLAYING or (JB.State ~= STATE_IDLE and CurTime() - JB.RoundStartTime > 10)))
		then
			ply:KillSilent();
			gm:PlayerSpawnAsSpectator(ply);
			return;
		end

	ply._jb_forceRespawn=false
	ply:StripWeapons();
	ply:StripAmmo();

	gm.BaseClass.PlayerSpawn(gm,ply);
	ply:SetNWInt("killstreak",0) --ffs get rid of your killstreak
	ply.originalRunSpeed = ply:GetRunSpeed();
end;

JB.Gamemode.PlayerDeathThink = function( gm,ply )
	if ( ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_ATTACK2 ) || ply:KeyPressed( IN_JUMP ) ) and ply:GetObserverMode() == OBS_MODE_NONE then
		if JB.State == STATE_IDLE then
			ply:Spawn();
		else
			JB.Gamemode:PlayerSpawnAsSpectator(ply)
		end
	end
end

JB.Gamemode.PlayerCanPickupWeapon = function( gm, ply, entity )
	if not ply:Alive() then return false end

	if entity:GetClass() == "weapon_physgun" then
		return ply:IsSuperAdmin()
	end

	if not ply:CanPickupWeapon(entity) then return false end

	if entity.IsDropped and (not entity.BeingPickedUp or entity.BeingPickedUp ~= ply) then
		return false;
	end

	if JB:CheckWeaponReplacements(ply,entity) then entity:Remove(); return false end

	return true
end

JB.Gamemode.PlayerShouldTakeDamage = function(gm,a,b)
	if IsValid(a) and IsValid(b) and a:IsPlayer() and b:IsPlayer() and a:Team() == b:Team() and (JB.State == STATE_SETUP or JB.State == STATE_PLAYING or JB.State == STATE_LASTREQUEST) and (not IsValid(JB.TRANSMITTER) or a:Team() ~= TEAM_PRISONER or not JB.TRANSMITTER:GetJBWarden_PVPDamage()) then --or (not IsValid(JB.TRANSMITTER) or a:Team() ~= TEAM_GUARD or not JB.TRANSMITTER:GetJBWarden_PVPDamageGuards()) then
		return false
	end
	return true;
end

JB.Gamemode.IsSpawnpointSuitable = function()
    return true
end

JB.Gamemode.PlayerDeath = function(gm, victim, weapon, killer)
	if victim == killer and victim:GetNWInt("killstreak") >=4 then
		if victim:Team() == 1 then --accounce death sfx for those who have killstreaks
			for _,ply in ipairs( player.GetAll() ) do
				ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_01_death.wav" ))
			end
		elseif victim.GetWarden and victim:GetWarden() then
			for _,ply in ipairs( player.GetAll() ) do
				ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_04_death.wav" ))
			end
		else 
			for _,ply in ipairs( player.GetAll() ) do
				ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_03_death.wav" ))
			end
		end
	elseif victim:Team() == 1 then --death sfx
		victim:EmitSound("/misc/ks_tier_01_death.wav")
	elseif victim.GetWarden and victim:GetWarden() then
		victim:EmitSound("/misc/ks_tier_04_death.wav")
	else 
		victim:EmitSound("/misc/ks_tier_03_death.wav")
	end

	if victim:Team() == 0 and JB:AliveGuards() > 1 then --bg music, shouldn't be activated if it's the end of the round otherwise it will overlay the round end music
		victim:SendLua( string.format( "surface.PlaySound( %q )", "otterjailbreak/lc_ghost01.mp3" ))
	elseif victim:Team() == 1 and JB:AlivePrisoners() > 1 then --bg music, shouldn't be activated if it's the end of the round otherwise it will overlay the round end music
		victim:SendLua( string.format( "surface.PlaySound( %q )", "otterjailbreak/lc_ghost01.mp3" ))
	end
	if victim:GetNWInt("killstreak") >= 4 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." ENDED "..string.upper(victim:Nick()).."'s KILLSTREAK OF "..victim:GetNWInt("killstreak").."!");
	elseif victim:GetNWInt("killstreak") >= 4 and killer == victim then
		JB:BroadcastNotification(string.upper(killer:Nick()).." HAS ENDED THEIR OWN KILLSTREAK OF "..victim:GetNWInt("killstreak").."!");
	end
	if killer ~= victim and killer:IsValid() and killer:GetNWInt("killstreakkit") == 1 and killer:Alive() then killer:SetNWInt("killstreak", (killer:GetNWInt("killstreak")+1)) end --killstreaks
	if killer:IsValid() and killer:GetNWInt("killstreak") == 2 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS ON A KILLING SPREE! - "..killer:GetNWInt("killstreak").." KILLS"); --2
		for _,ply in ipairs( player.GetAll() ) do
			ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_01.wav" ))
		end
	elseif killer:IsValid() and killer:GetNWInt("killstreak") > 2 and killer:GetNWInt("killstreak") < 4 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS STILL ON A KILLING SPREE! - "..killer:GetNWInt("killstreak").." KILLS"); --3
		for _,ply in ipairs( player.GetAll() ) do
			ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_01_kill.wav" ))
		end
	elseif killer:IsValid() and killer:GetNWInt("killstreak") == 4 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS UNSTOPPABLE! - "..killer:GetNWInt("killstreak").." KILLS"); --4
		for _,ply in ipairs( player.GetAll() ) do
			ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_02.wav" ))
		end
	elseif killer:IsValid() and killer:GetNWInt("killstreak") > 4 and killer:GetNWInt("killstreak") < 7 and killer ~= victim and killer:Alive() then
		local ks = killer:GetNWInt("killstreak")
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS STILL UNSTOPPABLE! - "..ks); --5/6
		for _,ply in ipairs( player.GetAll() ) do
			if ks >= 6 then
				ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_02_kill_02.wav" ))
			else --5
				ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_02_kill_01.wav" ))
			end
		end
	elseif killer:IsValid() and killer:GetNWInt("killstreak") == 7 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS ON A RAMPAGE! - "..killer:GetNWInt("killstreak").." KILLS"); --7
		for _,ply in ipairs( player.GetAll() ) do
			ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_03.wav" ))
		end
	elseif killer:IsValid() and killer:GetNWInt("killstreak") > 7 and killer:GetNWInt("killstreak") < 9 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS STILL ON A RAMPAGE! - "..killer:GetNWInt("killstreak").." KILLS"); --8
		for _,ply in ipairs( player.GetAll() ) do
			ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_03_kill_01.wav" ))
		end
	elseif killer:IsValid() and killer:GetNWInt("killstreak") == 9 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS GOD-LIKE! - "..killer:GetNWInt("killstreak").." KILLS"); --9
		for _,ply in ipairs( player.GetAll() ) do
			ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_04.wav" ))
		end
	elseif killer:IsValid() and killer:GetNWInt("killstreak") > 9 and killer ~= victim and killer:Alive() then
		JB:BroadcastNotification(string.upper(killer:Nick()).." IS STILL GOD-LIKE! - "..killer:GetNWInt("killstreak").." KILLS"); --10+
		for _,ply in ipairs( player.GetAll() ) do
			ply:SendLua( string.format( "surface.PlaySound( %q )", "/misc/ks_tier_04_kill_01.wav" ))
		end
	end
	if IsValid(killer) and killer:Alive() then
		JB:DebugPrint(killer:Nick().." has a killstreak of "..killer:GetNWInt("killstreak"))
	end
	victim:SendNotification("You are muted until the round ends")
	
	if victim.GetWarden and IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBWarden() == victim:GetWarden() then
		JB:BroadcastNotification("The warden has died")
		timer.Simple(.5,function()
			for k,v in pairs(team.GetPlayers(TEAM_GUARD))do
				if v:Alive() and v ~= victim then
					JB:BroadcastNotification("Prisoners get freeday");
					break;
				end
			end
		end);
	end

	if IsValid(killer) and killer.IsPlayer and killer:IsPlayer()
	and	killer:Team() == TEAM_PRISONER and victim:Team() == TEAM_GUARD
	and killer.AddRebelStatus
	and not killer:GetRebel()
	and tonumber(JB.Config.rebelSensitivity) >= 1
	and JB.State ~= STATE_LASTREQUEST then
		JB:DebugPrint(killer:Nick().. "  is now a rebel!!");
		killer:AddRebelStatus();
	end

	if IsValid(killer) and killer.IsPlayer and killer:IsPlayer() and (killer:Team() == TEAM_GUARD or killer:Team() == TEAM_PRISONER) and killer:Alive() then
		JB:BroadcastQuickNotification(victim:Nick().." was killed by "..killer:Nick());
	else
		JB:BroadcastQuickNotification(victim:Nick().." has died");
	end

	if JB.State == STATE_PLAYING and victim:Team() == TEAM_GUARD and JB:AliveGuards() == 2 and JB:AlivePrisoners() > 3 and not IsValid(JB:GetWarden()) and not JB.ThisRound.notifiedLG and tobool(JB.Config.notifyLG) then
		JB.ThisRound.notifiedLG = true;
		JB:BroadcastNotification("Last guard kills all");
	end

	if JB.State == STATE_PLAYING and victim:Team() == TEAM_PRISONER and JB:AlivePrisoners() == 2 and not JB.ThisRound.notifiedLR then
		JB.ThisRound.notifiedLR = true;
		JB:BroadcastNotification("The last prisoner now select a last request from the menu (F4).");
		JB:BroadcastNotification("Custom last requests may only affect the current round!");
	end

	if JB.State == STATE_LASTREQUEST then
		local guard,prisoner = unpack(JB.LastRequestPlayers);
		if IsValid(guard) and guard == victim then
			JB.LastRequest = "0";
		end
	end

	JB:DamageLog_AddPlayerDeath(victim, weapon, killer)
end

JB.Gamemode.ScalePlayerDamage = function( gm, ply, hitgroup, dmginfo )
	if ( hitgroup == HITGROUP_HEAD ) then
        dmginfo:ScaleDamage( 3 )
    elseif ( hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM ) then
        dmginfo:ScaleDamage( 0.8 )
    elseif ( hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG ) then
     	dmginfo:ScaleDamage( 0.4 )
    end
end

JB.Gamemode.GetFallDamage = function() return 0 end

local fallsounds = {
   Sound("player/damage1.wav"),
   Sound("player/damage2.wav"),
   Sound("player/damage3.wav")
};
JB.Gamemode.OnPlayerHitGround = function(gm,ply, in_water, on_floater, speed)
   if in_water or speed < 460 or not IsValid(ply) then return end

   local damage = math.pow(0.05 * (speed - 420), 1.30)

   if on_floater then damage = damage / 2 end

   if math.floor(damage) > 0 then
      local dmg = DamageInfo()
      dmg:SetDamageType(DMG_FALL)
      dmg:SetAttacker(game.GetWorld())
      dmg:SetInflictor(game.GetWorld())
      dmg:SetDamageForce(Vector(0,0,1))
      dmg:SetDamage(damage)

      ply:TakeDamageInfo(dmg)

      if damage > 5 then
			sound.Play(table.Random(fallsounds), ply:GetShootPos(), 55 + math.Clamp(damage, 0, 50), 100)
      end
   end
end

JB.Gamemode.PlayerCanHearPlayersVoice = function( gm, listener, talker )
	if (not talker:Alive() )
		or (talker:Team() == TEAM_PRISONER and ((CurTime() - JB.RoundStartTime) < 30)) then return false,false; end

	if(talker.GetWarden and talker:GetWarden()) then
		return true,false;
	end
	return true,false;
end

JB.Gamemode.EntityTakeDamage = function ( gm, ent, dmg )
	JB:DamageLog_AddEntityTakeDamage( ent,dmg )
end

hook.Add("PlayerDisconnected","JB.PlayerDisconnected.CheckDisconnect",function(p)
	if JB.State == STATE_LASTREQUEST then
		local guard,prisoner = unpack(JB.LastRequestPlayers);
		if IsValid(guard) and guard == p then
			JB.LastRequest = "0";
		end
	end
end)

hook.Add("DoPlayerDeath", "JB.DoPlayerDeath.DropWeapon", function(ply)
	if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "jb_fists" then
		local wep = ply:GetActiveWeapon();
		wep.IsDropped = true;
		wep.BeingPickedUp = false;
		ply:DropWeapon(wep)
	end
end)

hook.Add("EntityTakeDamage", "JB.EntityTakeDamage.WeaponScale", function(ent, d)
	local att = d:GetInflictor()

	if att:IsPlayer() then
		local wep = att:GetActiveWeapon()

		if IsValid(wep) and not wep.NoDistance and wep.EffectiveRange then
			local dist = ent:GetPos():Distance(att:GetPos())

			if dist >= wep.EffectiveRange * 0.5 then
				dist = dist - wep.EffectiveRange * 0.5
				local mul = math.Clamp(dist / wep.EffectiveRange, 0, 1)

				d:ScaleDamage(1 - wep.DamageFallOff * mul)
			end
		end
	end
end)

hook.Add("PlayerHurt", "JB.PlayerHurt.MakeRebel", function(victim, attacker)
	if !IsValid(attacker) or !IsValid(victim) or !attacker:IsPlayer() or !victim:IsPlayer() or tonumber(JB.Config.rebelSensitivity) ~= 2 then return end
	if attacker:Team() == TEAM_PRISONER and victim:Team() == TEAM_GUARD and attacker.SetRebel
	and not attacker:GetRebel()
	and JB.State ~= STATE_LASTREQUEST then
		attacker:AddRebelStatus();
	end
end)

local painSounds = {
	"vo/npc/male01/ow01.wav",
	"vo/npc/male01/ow02.wav",
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav"
}
local femalePainSounds = {
	"vo/npc/female01/ow01.wav",
	"vo/npc/female01/ow02.wav",
	"vo/npc/female01/pain01.wav",
	"vo/npc/female01/pain02.wav",
	"vo/npc/female01/pain03.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain05.wav",
	"vo/npc/female01/pain06.wav",
	"vo/npc/female01/pain07.wav",
	"vo/npc/female01/pain08.wav",
	"vo/npc/female01/pain09.wav"
}

hook.Add("EntityTakeDamage", "JB.EntityTakeDamage.SayOuch", function(victim)
	local dothemath = math.random(1,6)
	if IsValid(victim) and victim:IsPlayer() and victim:GetModel():find("/male") and dothemath == 1 then
		victim:EmitSound(painSounds[math.random(#painSounds)],math.random(100,140),math.random(90,110))
	elseif IsValid(victim) and victim:IsPlayer() and victim:GetModel():find("/female") and dothemath == 1 then
		victim:EmitSound(femalePainSounds[math.random(#femalePainSounds)],math.random(100,140),math.random(90,110))
	end
end)

concommand.Remove("changeteam");

function JB:BroadcastNotification(text,omit)
	net.Start("JB.SendNotification");
	net.WriteString(text);
	if omit then
		net.SendOmit(omit);
		return;
	end
	net.Broadcast();
end

function JB:BroadcastQuickNotification(text)
	net.Start("JB.SendQuickNotification");
	net.WriteString(text);
	net.Broadcast();
end


function JB.Gamemode:AllowPlayerPickup( ply, object )
    return (ply:Alive() and (JB.State == STATE_PLAYING or JB.State == STATE_SETUP or JB.State == STATE_LASTREQUEST) and IsValid(JB.TRANSMITTER) and JB.TRANSMITTER:GetJBWarden_ItemPickup());
end

function JB.Gamemode:PlayerUse( ply, ent )
	if not ply:Alive() or not (ply:Team() == TEAM_GUARD or ply:Team() == TEAM_PRISONER) then
		return false
	end
	return true
end



JB.Gamemode.ShowHelp = function() end
JB.Gamemode.ShowTeam = function() end
JB.Gamemode.ShowSpare1 = function() end
JB.Gamemode.ShowSpare2 = function() end
