
if SERVER then
    util.AddNetworkString("sethealth")
    
    net.Receive( 'sethealth', function( hp, ply )
        if(ply.PS_Points >= 15) then
            ply:SetHealth( 100 )
            ply:SetArmor( 100 )
            ply:PS_TakePoints( 15 )
            ply:SendNotification("Bought 100% Health/Ammo for 15 Pennies",NOTICE_GENERIC);
        end
    end )
    
    util.AddNetworkString("givewep")
    
    net.Receive( 'givewep', function( wep, ply )
        if(ply:GetNWBool("boughtweapon") == false or ply:GetNWBool("boughtweapon") == nil) then
            if(ply.PS_Points >= __roundweapon[2]) then
                for k,v in pairs(ply:GetWeapons()) do
                    if v:GetSlot() == __roundweapon[4] then
                        ply:StripWeapon(v:GetPrintName())
                    end
                end
                ply:Give(__roundweapon[3])
                ply:SelectWeapon(__roundweapon[3])
                ply:PS_TakePoints( __roundweapon[2]) 
                ply:SetNWBool("boughtweapon",true)
                ply:SendNotification("Bought "..__roundweapon[1].." for "..__roundweapon[2].." Pennies",NOTICE_GENERIC);
            end
        end
    end )

    return
end