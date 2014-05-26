DragFeatureState = AbstractState:extends{}

function DragFeatureState:init(featureId, startDiffX, startDiffZ)
    self.featureId = featureId
    self.startDiffX = startDiffX
    self.startDiffZ = startDiffZ
    self.dx = 0
    self.dz = 0
    self.featureGhostViews = {}
    SCEN_EDIT.SetMouseCursor("drag")
end

function DragFeatureState:GameFrame(frameNum)
    local selType, featureIds = SCEN_EDIT.view.selectionManager:GetSelection()
    for i = 1, #featureIds do
        local featureId = featureIds[i]
        if not Spring.ValidFeatureID(featureId) then
            SCEN_EDIT.stateManager:SetState(DefaultState())
            return false
        end
    end
end

function DragFeatureState:MouseMove(x, y, dx, dy, button)
    local result, coords = Spring.TraceScreenRay(x, y, true)
    if result == "ground" then
        if not Spring.ValidFeatureID(self.featureId) then
            SCEN_EDIT.stateManager:SetState(DefaultState())
            return false
        end
        local featureX, featureY, featureZ = Spring.GetFeaturePosition(self.featureId)
        self.dx = coords[1] + self.startDiffX - featureX
        self.dz = coords[3] + self.startDiffZ - featureZ
        local _, featureIds = SCEN_EDIT.view.selectionManager:GetSelection()
        self.featureGhostViews = {}
    
        for i = 1, #featureIds do
            local featureId = featureIds[i]
            local featureX, featureY, featureZ = Spring.GetFeaturePosition(featureId)
            local y = Spring.GetGroundHeight(featureX + self.dx, featureZ + self.dz)
            local position = { featureX + self.dx, y, featureZ + self.dz}
            self.featureGhostViews[featureId] = position
        end
    end
end

function DragFeatureState:MouseRelease(x, y, button)
    local commands = {}
    local _, featureIds = SCEN_EDIT.view.selectionManager:GetSelection()
    for i = 1, #featureIds do
        local featureId = featureIds[i]
        local featureX, featureY, featureZ = Spring.GetFeaturePosition(featureId)

        local modelFeatureId = SCEN_EDIT.model.featureManager:getModelFeatureId(featureId)
        local y = Spring.GetGroundHeight(featureX + self.dx, featureZ + self.dz)
        local moveCommand = MoveFeatureCommand(modelFeatureId, featureX + self.dx, y, featureZ + self.dz)
        table.insert(commands, moveCommand)
    end
    local compoundCommand = CompoundCommand(commands)
    SCEN_EDIT.commandManager:execute(compoundCommand)
    SCEN_EDIT.stateManager:SetState(DefaultState())
end

function DragFeatureState:DrawWorld()
    for featureId, pos in pairs(self.featureGhostViews) do
        gl.PushMatrix()
		gl.Color(1, 1, 1, 0.5)
        local featureDefId = Spring.GetFeatureDefID(featureId)
        local featureTeamId = Spring.GetFeatureTeam(featureId)
        gl.Translate(pos[1], pos[2], pos[3])

        local dirX, dirY, dirZ = Spring.GetFeatureDirection(featureId)
        local angleY = math.atan2(dirX, dirZ)
        
        if angleY ~= 0 then
            gl.Rotate(180 / math.pi * angleY, 0, 1, 0)
        end

        gl.Texture(1, "%-" .. featureDefId .. ":1")
        gl.FeatureShape(featureDefId, featureTeamId)
        gl.PopMatrix()
    end
end
