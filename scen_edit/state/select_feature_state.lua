SelectFeatureState = AbstractState:extends{}

function SelectFeatureState:init()
    SCEN_EDIT.SetMouseCursor("search")
end

function SelectFeatureState:enterState()
end

function SelectFeatureState:leaveState()
end

function SelectFeatureState:MousePress(x, y, button)
end

function SelectFeatureState:MouseMove(x, y, dx, dy, button)
end

function SelectFeatureState:MouseRelease(x, y, button)
end

function SelectFeatureState:KeyPress(key, mods, isRepeat, label, unicode)
end
