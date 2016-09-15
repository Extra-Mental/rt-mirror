if SERVER then
	CreateConVar( "sbox_maxrendermirrors", "3", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NEVER_AS_STRING, FCVAR_NOTIFY } )
end

if CLIENT then
	language.Add("Tool.render_mirror_tool.name", "Render Mirror Tool")
	language.Add("Tool.render_mirror_tool.desc", "Creates a dynamic rendering mirror entity.")
	language.Add("Tool.render_mirror_tool.0", "Left click: spawn screen.")
	language.Add( "sboxlimit_rendermirrors", "You've hit Render Mirror limit!" )
end

TOOL.Name						= "Render Mirror"
TOOL.Category				= "Render"

TOOL.ClientConVar.model 		= "models/hunter/plates/plate1x1.mdl"
TOOL.ClientConVar.frozen    = 1

cleanup.Register("rendermirrors")

function TOOL:LeftClick(Trace)

  if CLIENT then return true end
	if not self:GetSWEP():CheckLimit( "rendermirrors" ) then return false end

  local Model = self:GetClientInfo("model")
  local Ang = Trace.HitNormal:Angle() + Angle(90, 0, 0)

  local Mirror = ents.Create("render_mirror")
  if !IsValid(Mirror) then return false end

  Mirror:SetPos(Trace.HitPos - Trace.HitNormal * Mirror:OBBMins().z)
	Mirror:SetAngles(Ang)
	Mirror:SetModel(Model)
	Mirror:Activate()
	Mirror:Spawn()

  self:GetOwner():AddCount("rendermirrors", Mirror)

  undo.Create("render_mirror")
	undo.AddEntity(Mirror)
	undo.SetPlayer(self:GetOwner())
  undo.Finish()

  if self:GetClientNumber("frozen") == 1 then
		Mirror:GetPhysicsObject():EnableMotion(false)
	end

  self:GetOwner():AddCleanup("render_mirror", Mirror)

end


function TOOL.BuildCPanel( CPanel )

  CPanel:AddControl( "PropSelect", { Label = "Model", ConVar = "render_mirror_tool_model", Height = 4, Models = list.Get( "RenderMirrorModels" ) } )

  CPanel:AddControl( "CheckBox", { Label = "Spawn Frozen", Command = "render_mirror_tool_frozen" } )

end


list.Set("RenderMirrorModels", "models/hunter/plates/plate025x025.mdl", {})
list.Set("RenderMirrorModels", "models/hunter/plates/plate025x05.mdl", {})
list.Set("RenderMirrorModels", "models/hunter/plates/plate025x075.mdl", {})
list.Set("RenderMirrorModels", "models/hunter/plates/plate05x05.mdl", {})
list.Set("RenderMirrorModels", "models/hunter/plates/plate05x075.mdl", {})
list.Set("RenderMirrorModels", "models/hunter/plates/plate1x1.mdl", {})

list.Set("RenderMirrorModels", "models/sprops/rectangles/size_1_5/rect_6x6x3.mdl", {})
list.Set("RenderMirrorModels", "models/sprops/rectangles/size_1_5/rect_6x12x3.mdl", {})
list.Set("RenderMirrorModels", "models/sprops/rectangles/size_1_5/rect_6x18x3.mdl", {})
list.Set("RenderMirrorModels", "models/sprops/rectangles/size_2/rect_12x12x3.mdl", {})
list.Set("RenderMirrorModels", "models/sprops/rectangles/size_2/rect_12x18x3.mdl", {})


function TOOL:Think()

  if !IsValid( self.GhostEntity ) or self.GhostEntity:GetModel( ) != self:GetClientInfo( "model" ) then
		return self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end

	local Trace = util.TraceLine( util.GetPlayerTrace( self:GetOwner()))

	if Trace.Hit then

		if IsValid( Trace.Entity ) and Trace.Entity:IsPlayer() then
			return self.GhostEntity:SetNoDraw( true )
		end

		local Ang = Trace.HitNormal:Angle( )
		Ang.pitch = Ang.pitch + 90

		self.GhostEntity:SetPos( Trace.HitPos - Trace.HitNormal * self.GhostEntity:OBBMins( ).z )
		self.GhostEntity:SetAngles( Ang )

		self.GhostEntity:SetNoDraw( false )
	end
end
