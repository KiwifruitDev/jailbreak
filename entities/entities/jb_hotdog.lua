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
		self:SetModel( "models/food/hotdog.mdl" );

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
	if IsValid(p) and p:Health() < 100 then
	
		p:SetHealth(p:Health()+15)
		
		p:SendQuickNotification("You ate a hot dog!");
		
		self:Remove();
	elseif IsValid(p) then
		p:SendQuickNotification("You're too full to eat a hot dog!");
	end
end

function ENT:Draw()
	self:DrawModel();
end