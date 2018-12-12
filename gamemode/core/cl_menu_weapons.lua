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

local color_text = Color(230,230,230,200);

local frame;
local randomHealed = {"All patched up and ready to go!","Thank you for doing business with me!","You're all set, don't tell anyone you saw me.","You're healed up. This never happened, head out now!","Body armor is in place and you're healed up. You're free to go!"}

function JB.MENU_GUNMENU()
	if IsValid(frame) then frame:Remove() end
	net.Receive("roundweapon", function() __roundweapon = net.ReadTable();PrintTable(__roundweapon) end)
	frame = vgui.Create("JB.Frame");
	frame:SetTitle("Detective Dickhead");
	
	local yBottom = 30;
	frame:SetWide(500);
	--print(table.ToString(__roundweapon))
	local lbl = Label("Purchase "..__roundweapon[1].." for "..__roundweapon[2].." Pennies?",frame);
		lbl:SetFont("JBLarge");
		lbl:SetColor(JB.Color["#EEE"]);
		lbl:SizeToContents();
		lbl:SetPos(15,yBottom + 15);
	yBottom = lbl.y + lbl:GetTall();
	local function addButton(name,click)
		local btn = frame:Add("JB.Button");
		btn:SetPos(15,yBottom+15);
		btn:SetSize(frame:GetWide() - 30, 32);
		btn:SetText(name);
		btn.OnMouseReleased = click;
		
		yBottom = btn.y + btn:GetTall();
	end
	if (LocalPlayer().PS_Points >= __roundweapon[2]) then
		local function SetHP( hp )
			LocalPlayer():ChatPrint( table.Random( randomHealed ) )
			net.Start 'givewep'
			net.WriteInt( hp, 32 )
			net.SendToServer()
		end
		addButton("Yes, make purchase!",function() frame:Remove();SetHP(100); end);
		addButton("No, don't",function() frame:Remove(); end);
	else
		addButton("No, I don't have enough pennies!",function() frame:Remove(); end);
	end
    frame:SetTall(yBottom+15);
	frame:Center();
	frame:MakePopup();
end
