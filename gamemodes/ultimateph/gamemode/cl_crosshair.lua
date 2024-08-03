--[[
  The implementation is adapted from the crosshair customization menu. Credit for original code goes to robotboy655 (Rubat).
  https://github.com/Facepunch/garrysmod/blob/430fc8a2cf4c25873766b1d1a0df1cb94c68d5b7/garrysmod/lua/menu/crosshair_setup.lua
]]

local STYLE = GetConVar("cl_crosshairstyle")
local QUICKINFO = GetConVar("hud_quickinfo")

local COLOR_R = GetConVar("cl_crosshaircolor_r")
local COLOR_G = GetConVar("cl_crosshaircolor_g")
local COLOR_B = GetConVar("cl_crosshaircolor_b")
local COLOR_A = GetConVar("cl_crosshairalpha")

local USE_ALPHA = GetConVar("cl_crosshairusealpha")
local SIZE = GetConVar("cl_crosshairsize")
local THICKNESS = GetConVar("cl_crosshairthickness")
local DRAW_OUTLINE = GetConVar("cl_crosshair_drawoutline")
local OUTLINE_THICKNESS = GetConVar("cl_crosshair_outlinethickness")
local GAP = GetConVar("cl_crosshairgap")
local T_STYLE = GetConVar("cl_crosshair_t")
local DOT = GetConVar("cl_crosshairdot")

local ADDITIVE_MAT = Material("vgui/white_additive")
local CROSSHAIR_MAT = Material("gui/crosshair.png")

local HALFLIFE2_STYLE = 0
local DOT_IMAGE_STYLE = 1
local CLASSIC_STYLE = 2

local HALFLIFE2_COLOR = Color(255, 208, 64, 255)
local QUICKINFO_COLOR = Color(255, 208, 64, 200)

local function GetColor()
  return Color(COLOR_R:GetInt(), COLOR_G:GetInt(), COLOR_B:GetInt(), COLOR_A:GetInt())
end

local function DrawRect(color, x0, y0, x1, y1, additive, outline, o_thickness)
  if outline then
    local o_x0 = x0 - o_thickness
    local o_y0 = y0 - o_thickness
    local o_x1 = (x1 + o_thickness) - (x0 + o_thickness)
    local o_y1 = (y1 + o_thickness) - (y0 + o_thickness)

    surface.SetDrawColor(0, 0, 0, color.a)
    surface.DrawRect(o_x0, o_y0, o_x1, o_y1)
  end

  surface.SetDrawColor(color.r, color.g, color.b, color.a)

  if additive then
    surface.DrawTexturedRect(x0, y0, x1 - x0, y1 - y0)
  else
    surface.DrawRect(x0, y0, x1 - x0, y1 - y0)
  end
end

local function DrawText(x, y, font, text, color)
  surface.SetFont(font)
  surface.SetTextColor(color)

  local w, h = surface.GetTextSize(text)

  surface.SetTextPos(x - (w / 2), y - (h / 2))
  surface.DrawText(text)
end

local function DrawHalfLife2(x, y)
  DrawText(x, y, "Crosshairs", "Q", HALFLIFE2_COLOR)
end

local function DrawDotImage(x, y)
  surface.SetDrawColor(GetColor())
  surface.SetMaterial(CROSSHAIR_MAT)
  surface.DrawTexturedRect(x - 32, y - 32, 64, 64)
end

local function DrawClassic(x, y)
  local color = GetColor()
  local additive = USE_ALPHA:GetBool()
  local size = math.Round(ScreenScaleH(SIZE:GetInt()))
  local thickness = math.max(1, math.Round(ScreenScaleH(THICKNESS:GetInt())))
  local outline = DRAW_OUTLINE:GetBool() 
  local o_thickness = OUTLINE_THICKNESS:GetFloat()
  local gap = GAP:GetInt()

  if additive then
    surface.SetMaterial(ADDITIVE_MAT)
    color.a = 200
  end

  local inner_left = x - gap - thickness / 2
  local inner_right = inner_left + 2 * gap + thickness
  local outer_left = inner_left - size
  local outer_right = inner_right + size
  local y0 = y - thickness / 2
  local y1 = y0 + thickness

  DrawRect(color, outer_left, y0, inner_left, y1, additive, outline, o_thickness)
  DrawRect(color, inner_right, y0, outer_right, y1, additive, outline, o_thickness)

  local inner_top = y - gap - thickness / 2
  local inner_bottom = inner_top + 2 * gap + thickness
  local outer_top = inner_top - size
  local outer_bottom = inner_bottom + size
  local x0 = x - thickness / 2
  local x1 = x0 + thickness

  if T_STYLE:GetBool() then
    DrawRect(color, x0, outer_top, x1, inner_top, additive, outline, o_thickness)
  end

  DrawRect(color, x0, inner_bottom, x1, outer_bottom, additive, outline, o_thickness)

  if DOT:GetBool() then
    x0 = x - thickness / 2
    x1 = x0 + thickness
    y0 = y - thickness / 2
    y1 = y0 + thickness

    DrawRect(color, x0, y0, x1, y1, additive, outline, o_thickness)
  end
end

local function DrawQuickInfo(x, y)
  DrawText(x, y, "QuickInfoLarge", "{ ]", QUICKINFO_COLOR)
end

return function(x, y)
  local style = STYLE:GetInt()

  if style >= CLASSIC_STYLE then
    DrawClassic(x, y)
  elseif style >= DOT_IMAGE_STYLE then
    DrawDotImage(x, y)
  elseif style >= HALFLIFE2_STYLE then
    DrawHalfLife2(x, y)
  end

  if QUICKINFO:GetBool() then
    DrawQuickInfo(x, y)
  end
end
