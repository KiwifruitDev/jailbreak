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

AddCSLuaFile();

ENT.Type             = "anim"
ENT.Base             = "base_anim"

function ENT:Initialize()    
	if SERVER then
		self:SetModel( "models/detective.mdl" );
		timer.Simple(0, function() self:SetSequence( "pose_standing_01" ) end)
		self:SetUseType(SIMPLE_USE);
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);

		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()	
		end
	end
end

function ENT:Use(p)
	local randomHealth = {"I got just the right thing for you.","Need a patch? I got something for ya.","Your health is low, I can patch ya up if you want.","Don't get me wrong but I believe you need medical assistance, correct?","Need a medic quick? I can help you with that."}
	local randomGuns = {"Got somethings for ya to try, willing to buy?","Guns, guns, guns, I got some guns","While not drugs, I could hook you up with some guns", "Want some guns, you've come to the right place.","Totally legal gun exchange, right here in Jailbreak."}
	local randomOfficer = {"Everything is under control, officer!","Totally disarmed here, officer!","Nothing illegal going on here, officer!","Nothing suspicious going on here, officer!","No crimes have been committed here, officer!","Officer, I must say it is a beautiful day outside.","Officer, how's the weather like?"}
	if IsValid(p) and p:Health() < 100 and p:Team() != TEAM_GUARD then
		p:ChatPrint( table.Random( randomHealth ) )
		p:SendLua( "JB.MENU_HEAL()" )
	elseif IsValid(p) and p:Health() >= 100 and p:Team() != TEAM_GUARD then
		if(p:GetNWBool("boughtweapon") == false or p:GetNWBool("boughtweapon") == nil) then
			p:ChatPrint( table.Random( randomGuns ) )
			p:SendLua( "JB.MENU_GUNMENU()" )
		end
	elseif IsValid(p) and p:Team() == TEAM_GUARD then
		p:ChatPrint( table.Random( randomOfficer ) )
	end
end

function ENT:Draw()
	self:DrawModel();
end