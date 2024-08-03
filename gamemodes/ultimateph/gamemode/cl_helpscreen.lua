local HELP = [[


== CONTROLS ==
LEFT CLICK - Disguises as the prop you are looking at
C - Locks your prop's rotation when disguised
R - Drag to rotate currently held prop
F3 - Taunt help_menu
F4 - Cycles view perspective (see command below)

== OBJECTIVES ==
The aim of the hunters is to find and kill all the props.
Don't shoot too many actual props, as guessing incorrectly costs health!
The aim of the props is to hide from the hunters and not get killed.

== COMMANDS ==
'ph_taunt <category> <name>' plays a taunt given a category and name.
  e.g. 'ph taunt talk just do it', 'ph_taunt noise long fart'
'ph_taunt_random' plays a random taunt.
'playermodel_selector' opens the player model selector.
'ph_cam_perspective <0,3>' changes the view perspective.
  0:First person, 1:Third person, 2:Left shoulder, 3:Right shoulder.
  e.g. 'ph_cam_perspective 1' changes the view to third person.
'bind x "<command>"' binds a command to X (or another key).
  e.g. 'bind del "kill"' creates a suicide key on Delete.
]]

local help_menu

hook.Add("OnGamemodeLoaded", "ph_createhelpmenu", function()
	help_menu = vgui.Create("DFrame", nil)

	help_menu:SetSize(ScrW() * 0.4, ScrH() * 0.6)
	help_menu:Center()
	help_menu:MakePopup()
	help_menu:SetKeyboardInputEnabled(false)
	help_menu:SetDeleteOnClose(false)
	help_menu:ShowCloseButton(true)
	help_menu:SetTitle("")
	help_menu:SetVisible(false)

	function help_menu:Paint(w, h)
		surface.SetDrawColor(40, 40, 40, 230)
		surface.DrawRect(0, 0, w, h)
		surface.SetFont("RobotoHUD-25")

		draw.ShadowText("Help", "RobotoHUD-25", 8, 2, Color(132, 199, 29), 0)
	end

	local text = vgui.Create("DLabel", help_menu)

	text:SetText(HELP)
	text:SetWrap(true)
	text:SetFont("RobotoHUD-10")
	text:Dock(FILL)

	function text:Paint(w, h)
	end
end)

net.Receive("ph_openhelpmenu", function()
	help_menu:SetVisible(not help_menu:IsVisible())
end)
