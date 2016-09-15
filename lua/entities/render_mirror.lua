AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "render_mirror"

local RTs = {}
local LastRender = {}

function ENT:Initialize()

  if CLIENT then
    RTs[self:EntIndex()] = GetRenderTarget("rendermirror" .. self:EntIndex(), 512, 512, false)
    RTs[self:EntIndex() .. "Mats"] = Material("rendermirror" .. self:EntIndex())
    LastRender[self:EntIndex()] = 0
    return
  end

  self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

  local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then
		phys:Wake()
	end

end

function ENT:Draw()
  self:DrawModel()
end

function ENT:DrawMirror()

  local Depth = self:OBBMaxs().z
  local Width = self:OBBMaxs().x
  local Height = self:OBBMaxs().y

  local Pos = self:LocalToWorld(Vector(-Width,Height,Depth))
  local Ang = self:GetAngles()

  cam.Start3D2D(Pos, Ang, 1)

    RTs[self:EntIndex() .. "Mats"]:SetTexture("$basetexture", RTs[self:EntIndex()])
    surface.SetDrawColor(255,255,255,255)
    surface.SetMaterial(RTs[self:EntIndex() .. "Mats"])
    surface.DrawTexturedRectUV(0, 0, Width*2, Height*2, 0,1 , 1,0 )

  cam.End3D2D()

end

hook.Add("PostDrawOpaqueRenderables","DrawMirror", function()
	for k,v in pairs(ents.FindByClass("render_mirror"))do
    if v:IsValid() then
		    if GetViewEntity():IsLineOfSightClear(v:GetPos()) then v:DrawMirror() end
    end
	end
end)

local RENDERING_MIRROR = false
local DRAW_PLAYER = false

function ENT:RenderMirror(origin, angles, fov)

  if RENDERING_MIRROR == self then return end

  //print(CurTime() - LastRender[self:EntIndex()])
  if CurTime() - LastRender[self:EntIndex()] < 0.1 then return end
  LastRender[self:EntIndex()] = CurTime()

  local Depth = self:OBBMaxs().z
  local Width = self:OBBMaxs().y
  local Height = self:OBBMaxs().x

  local Pos = self:LocalToWorld(Vector(-Height,Width,Depth))
  local Ang = self:LocalToWorldAngles(Angle(-90,90,0))



  //Reflect angles
  //Ang:RotateAroundAxis(Ang:Up(), -RenderAngles().p)
  //Ang:RotateAroundAxis(Ang:Right(), -RenderAngles().r)
  //Ang:RotateAroundAxis(Ang:Right(), RenderAngles().y)


  render.PushRenderTarget(RTs[self:EntIndex()])
  render.Clear(0, 0, 0, 255)
  render.ClearDepth()
  render.ClearStencil()
  local view = {
    angles = Ang,
    origin = Pos,
    x = 0,
    y = 0,
    w = 512,
    h = 512,
    drawviewmodel = false,
    fov = 100,
  }
  local OldRender = RENDERING_MIRROR
  RENDERING_MIRROR = self
  DRAW_PLAYER = true
  render.RenderView(view)
  DRAW_PLAYER = false
  RENDERING_MIRROR = OldRender
  render.PopRenderTarget()

end

hook.Add( "RenderScene", "RenderMirror", function(origin, angles, fov)
	for k, v in ipairs( ents.FindByClass( "render_mirror" ) ) do
    if v:IsValid() then
		    if GetViewEntity():IsLineOfSightClear(v:GetPos()) then v:RenderMirror(origin, angles, fov) end
    end
	end
end)


//hook.Add( "ShouldDrawLocalPlayer", "RenderMirrorDrawPlayer", function()
			  //return DRAW_PLAYER
//end)

//hook.Remove("ShouldDrawLocalPlayer", "RenderMirrorDrawPlayer")
