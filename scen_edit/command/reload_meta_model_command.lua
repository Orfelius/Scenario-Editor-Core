ReloadMetaModelCommand = AbstractCommand:extends{}

-- sends meta model files from widget to gadget
function ReloadMetaModelCommand:init(metaModelFiles)
    self.className = "ReloadMetaModelCommand"
    self.metaModelFiles = metaModelFiles
end

function ReloadMetaModelCommand:execute()
	Spring.Echo("Reloading meta model...")
    SCEN_EDIT.conf:SetMetaModelFiles(self.metaModelFiles)
    local metaModelLoader = MetaModelLoader()
    metaModelLoader:Load()
	Spring.Echo("Reload completed successfully")
end
