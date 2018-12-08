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

AddCSLuaFile()
SWEP.PrintName              = "Wunderwaffe"; 
SWEP.Slot				    = 3
SWEP.SlotPos			    = 1

SWEP.HoldType			    = "smg"
SWEP.Base				    = "weapon_jb_base"
SWEP.Category			    = "Jailbreak Weapons"
SWEP.Author                 = "Crudcakes"

SWEP.Spawnable			    = true
SWEP.AdminSpawnable		    = true

SWEP.ViewModel              = "models/weapons/tesla_gun/v_tesla_gun.mdl"
SWEP.WorldModel             = "models/wunderwaffe.mdl"

SWEP.Weight                 = 1000
SWEP.AutoSwitchTo		    = true
SWEP.AutoSwitchFrom		    = false

SWEP.Primary.Sound			= "weapons/tesla_gun/fire.wav"
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 22
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 4
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 18
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "AR2AltFire"
SWEP.Range = 2*GetConVarNumber( "sk_vortigaunt_zap_range",100)*12	

SWEP.Positions = {};
SWEP.Positions[1] = {pos = Vector(0,0,0), ang = Vector(0,0,0)};
SWEP.Positions[2] = {pos = Vector(-6.56, -10.08, 2.519), ang = Vector(2.4, 0.1, 0)};
SWEP.Positions[3] = {pos = Vector(6.534, -15.827, -5.277), ang = Vector(-3.58, 66.97, -26.733)};

function SWEP:BoxTrace() 
	local self = self.Owner 
	local tr = {} tr.start = self:EyePos() tr.endpos = tr.start + self:EyeAngles():Forward() * 1000000 tr.filter = self tr.mask = MASK_SHOT tr.mins = Vector(-5,-5,-5) tr.maxs = Vector(5,5,5) 
	local Trace = util.TraceHull(tr) return Trace
end

function SWEP:PrimaryAttack()
	if self:GetNWMode() == MODE_SPRINT then return end

	local delay = self.Primary.Burst > 0 and self.Primary.Delay * (self.Primary.Burst + 1) or self.Primary.Delay;

	if self:Clip1() <= 0 then
		self:SetNextPrimaryFire(CurTime()+delay);
		self:EmitSound( "Weapon_Pistol.Empty" )
		return;
	end

	self:SetNextPrimaryFire(CurTime()+delay);

	self:JB_ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetNWLastShoot(), self.Primary.NumShots)
	self:Shoot()

	self.LastShoot = CurTime();

	if SERVER then
		self.Owner:EmitSound(self.Primary.Sound, 100, math.random(95, 105))
		if self.Owner:GetNWString("powerup") == "gunpunt" and self:Clip1() <= (self.Primary.ClipSize/2) then --punting should only be allowed once your clip size is appropriate
			self.Owner:SetVelocity( self.Owner:GetAimVector() * -150 )
		end
		local dmginfo = DamageInfo()
		local eyetrace = self:BoxTrace(); 
		local maxzaprange = 150
		dmginfo:SetDamage( 1000 )
		dmginfo:SetDamageType( DMG_SHOCK )
		dmginfo:SetAttacker( self.Owner )
		dmginfo:SetInflictor( self.Owner:GetActiveWeapon() )
		dmginfo:SetDamageForce( Vector( 0, 0, 1000 ) )
		

		if eyetrace.Entity:IsValid() then
			eyetrace.Entity:TakeDamageInfo( dmginfo )
			nent = self:FindNearestEntity( eyetrace.Entity:GetPos(), maxzaprange, null )
			if nent != null and nent:IsValid() then
				util.ParticleTracerEx( self.ArcEffect, eyetrace.Entity:GetPos(), nent:GetPos(), true, 1, 1 );
				nent:TakeDamageInfo( dmginfo )
				nent2 = self:FindNearestEntity( nent:GetPos(), maxzaprange, eyetrace.Entity )
				if nent2 != null and nent2:IsValid() then
					util.ParticleTracerEx( self.ArcEffect, nent:GetPos(), nent2:GetPos(), true, 1, 1 );				
					nent2:TakeDamageInfo( dmginfo )
					nent3 = self:FindNearestEntity( nent2:GetPos(), maxzaprange, nent, eyetrace.Entity )
					if nent3 != null and nent3:IsValid() then
						util.ParticleTracerEx( self.ArcEffect, nent2:GetPos(), nent3:GetPos(), true, 1, 1 );				
						nent3:TakeDamageInfo( dmginfo )
						nent4 = self:FindNearestEntity( nent3:GetPos(), maxzaprange, nent2, nent, eyetrace.Entity )
						if nent4 != null and nent4:IsValid() then
							util.ParticleTracerEx( self.ArcEffect, nent3:GetPos(), nent4:GetPos(), true, 1, 1 );				
							nent4:TakeDamageInfo( dmginfo )
							nent5 = self:FindNearestEntity( nent4:GetPos(), maxzaprange, nent3, nent2, nent, eyetrace.Entity )
							if nent5 != null and nent5:IsValid() then
								util.ParticleTracerEx( self.ArcEffect, nent4:GetPos(), nent5:GetPos(), true, 1, 1 );				
								nent5:TakeDamageInfo( dmginfo )
								nent6 = self:FindNearestEntity( nent5:GetPos(), maxzaprange, nent4, nent3, nent2, nent, eyetrace.Entity )
								if nent6 != null and nent6:IsValid() then
									util.ParticleTracerEx( self.ArcEffect, nent5:GetPos(), nent6:GetPos(), true, 1, 1 );				
									nent6:TakeDamageInfo( dmginfo )
									nent7 = self:FindNearestEntity( nent6:GetPos(), maxzaprange, nent5, nent4, nent3, nent2, nent, eyetrace.Entity )
									if nent7 != null and nent7:IsValid() then
										util.ParticleTracerEx( self.ArcEffect, nent6:GetPos(), nent7:GetPos(), true, 1, 1 );				
										nent7:TakeDamageInfo( dmginfo )
										nent8 = self:FindNearestEntity( nent7:GetPos(), maxzaprange, nent6, nent5, nent4, nent3, nent2, nent, eyetrace.Entity )
										if nent8 != null and nent8:IsValid() then
											util.ParticleTracerEx( self.ArcEffect, nent7:GetPos(), nent8:GetPos(), true, 1, 1 );				
											nent8:TakeDamageInfo( dmginfo )
											nent9 = self:FindNearestEntity( nent8:GetPos(), maxzaprange, nent7, nent6, nent5, nent4, nent3, nent2, nent, eyetrace.Entity )
											if nent9 != null and nent9:IsValid() then
												util.ParticleTracerEx( self.ArcEffect, nent8:GetPos(), nent9:GetPos(), true, 1, 1 );				
												nent9:TakeDamageInfo( dmginfo )
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	self:TakePrimaryAmmo(1);
	if self:Clip1() <= 0 and tobool(self.Owner:GetInfoNum( "jb_cl_option_autoreload", "0" )) then
		self:Reload();
	end
end

function SWEP:ShootEffect(EFFECTSTR,startpos,endpos)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
	if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
		util.ParticleTracerEx( EFFECTSTR, self.Weapon:GetAttachment( self.Weapon:LookupAttachment( "muzzle" ) ).Pos,endpos, true, pPlayer:GetViewModel():EntIndex(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
	else
		util.ParticleTracerEx( EFFECTSTR, pPlayer:GetAttachment( pPlayer:LookupAttachment( "anim_attachment_rh" ) ).Pos,endpos, true,pPlayer:EntIndex(), pPlayer:LookupAttachment( "anim_attachment_rh" ) );
	end
end
				
function SWEP:Shoot(dmg,effect)
	local pPlayer=self.Owner
	if !pPlayer then return end
	local traceres=util.QuickTrace(self.Owner:EyePos(),self.Owner:GetAimVector()*self.Range,self.Owner)
	self:ShootEffect(effect or "tesla_beam",pPlayer:EyePos(),traceres.HitPos)
end

function SWEP:FindNearestEntity( pos, range, Ent, Ent2, Ent3, Ent4, Ent5, Ent6, Ent7, Ent8 )
	local nearestEnt;

	for _, entity in pairs( ents.FindByClass("npc_*") ) do
		local distance = pos:Distance( entity:GetPos() );
		if entity != Ent and entity != Ent2 and entity != Ent3 and entity != Ent4 and entity != Ent5 and entity != Ent6 and entity != Ent7 and entity != Ent8 then
			if ( distance <= range and distance != 0 ) then
				nearestEnt = entity;
				range = distance; 
			end
		end
	end
	return nearestEnt;
end