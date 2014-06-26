SCEN_EDIT.Include(SCEN_EDIT_VIEW_DIR .. "file_dialog.lua")

ImportFileDialog = FileDialog:extends{}

function ImportFileDialog:init(dir)
    self:super("init", dir, "Import file")
end

function ImportFileDialog:confirmDialog()
    local path = self:getSelectedFilePath()
    local exists = VFS.FileExists(path, VFS.RAW_ONLY)    
    if exists then
        if self.confirmDialogCallback then 
            self.confirmDialogCallback(path)
        end
    end
end
