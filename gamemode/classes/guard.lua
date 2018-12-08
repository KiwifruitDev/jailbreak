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


DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Guard"
PLAYER.WalkSpeed 			= 260
PLAYER.RunSpeed				= 325
PLAYER.CrouchedWalkSpeed 	= 0.4
PLAYER.DuckSpeed			= 0.3
PLAYER.UnDuckSpeed			= 0.3
PLAYER.JumpPower			= 200
PLAYER.CanUseFlashlight     = true
PLAYER.MaxHealth			= 100
PLAYER.StartHealth			= 100
PLAYER.StartArmor			= 50
PLAYER.DropWeaponOnDie		= true
PLAYER.AvoidPlayers			= false

function PLAYER:Spawn()
	self.Player:SetPlayerColor(Vector(0,0,1));
	self.Player:SetWeaponColor(Vector(0,0,1));
end

local randomGuardSidearms = {"weapon_jb_deagle","weapon_jb_usp","weapon_jb_fiveseven"};
local randomGuardPrimary = {"weapon_jb_ak47","weapon_jb_aug","weapon_jb_galil","weapon_jb_m4a1","weapon_jb_mac10","weapon_jb_mp5navy","weapon_jb_p90","weapon_jb_scout","weapon_jb_sg552","weapon_jb_ump"};
function PLAYER:Loadout()
    local grapple = ents.Create( "sent_grapplehook_bpack" )
    grapple:SetSlotName( "sent_grapplehook_bpack" )
    grapple:Spawn()
	grapple:SetKey( 36 )
	print(grapple:GetKey().." 36")
    if not grapple:Attach( self.Player, true ) then
		print("removed grappling hook")
        grapple:Remove()
        return
	end
	self.Player:Give("weapon_jb_fists");
	if self.Player.GetNWString("guardweapon") then
		print(self.Player.GetNWString("guardweapon","None"))
		self.Player:Give(self.Player.GetNWString("guardweapon"));
		self.Player:GiveAmmo( self.Player.GetNWInt("guardammo"), self.Player.GetNWString("guardammotype"), true )
	end
	--self.Player:Give( table.Random( randomGuardSidearms ) )
	--self.Player:Give( table.Random( randomGuardPrimary ) );
	self.Player:GiveAmmo( 255, "Pistol", true )
	self.Player:GiveAmmo( 512, "SMG1", true )
end

function PLAYER:SetupDataTables()
	self.Player:NetworkVar( "Bool", 1, "InGuardZone" );
end


util.PrecacheModel( "models/player/police.mdl" )
function PLAYER:SetModel()
	print(self.Player._guardmodel)
	if self.Player._guardmodel then --after a rejoin or a map change/server restart, players need to re-equip the pointshop playermodel.
		self.Player:SetModel(self.Player._guardmodel)
	else
		self.Player:SetModel( "models/player/police.mdl" )
	end
end


player_manager.RegisterClass( "player_guard", PLAYER, "player_default" )
