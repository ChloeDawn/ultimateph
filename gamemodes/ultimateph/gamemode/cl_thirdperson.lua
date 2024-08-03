local CAM_PERSPECTIVE = CreateClientConVar("ph_cam_perspective", "0", true, false,
  "The camera perspective. First person, third person, left shoulder, right shoulder.", 0, 3)

local DYNAMIC_CROSSHAIR = CreateClientConVar("ph_dynamic_crosshair", "1", true, false,
  "Whether to use a dynamic crosshair when shoulder-surfing.", 0, 1)

local DrawCrosshair = include("cl_crosshair.lua")

local FIRST_PERSON = 0
local THIRD_PERSON = 1
local SHOULDER_L = 2
local SHOULDER_R = 3

local function HasLockedPerspective(ply)
  return not ply:Alive() or ply:IsDisguised()
end

local function HasDynamicCrosshair(ply)
  if not DYNAMIC_CROSSHAIR:GetBool() then
    return false
  end

  if HasLockedPerspective(ply) then
    return false
  end

  return CAM_PERSPECTIVE:GetInt() >= SHOULDER_L
end

net.Receive("change_perspective", function()
  if not HasLockedPerspective(LocalPlayer()) then
    CAM_PERSPECTIVE:SetInt((CAM_PERSPECTIVE:GetInt() + 1) % 4)
  end
end)

hook.Add("HUDShouldDraw", "HideDefaultCrosshair", function(name)
  if name == "CHudCrosshair" and HasDynamicCrosshair(LocalPlayer()) then
    return false
  end
end)

hook.Add("HUDPaint", "DrawDynamicCrosshair", function()
  local ply = LocalPlayer()

  if not HasDynamicCrosshair(ply) then
    return
  end

  local origin = ply:GetShootPos()
  local intersection = util.TraceLine {
    start = origin,
    endpos = origin + (ply:GetAimVector() * 10000),
    filter = ply
  }

  if (intersection.HitPos - origin):Length() < 3500 then
    local target = intersection.HitPos:ToScreen()
    local x = math.Clamp(target.x, 0, ScrW())
    local y = math.Clamp(target.y, 0, ScrH())

    DrawCrosshair(x, y)
  end
end)

hook.Add("CalcView", "CalcThirdPersonView", function(ply, origin, angles, fov, znear, zfar)
  local perspective = CAM_PERSPECTIVE:GetInt()

  if perspective <= FIRST_PERSON or HasLockedPerspective(ply) then
    return nil
  end

  local forward = (perspective >= SHOULDER_L) and 50 or 100
  local target = origin - (angles:Forward() * forward)

  if perspective >= SHOULDER_L then
    local right = (perspective >= SHOULDER_R) and -35 or 35

    target = target - (angles:Right() * right)
  end

  local intersection = util.TraceLine {
    start = origin,
    endpos = target,
    filter = ply
  }

  target = intersection.HitPos

  if intersection.Fraction < 1.0 then
    target = intersection + (intersection.HitNormal * 5)
  end

  return {
    origin = target,
    drawviewer = true
  }
end)
