ImportAction = AbstractAction:extends{}

function ImportAction:execute()
    local dir = FilePanel.lastDir or SCEN_EDIT_EXAMPLE_DIR_RAW_FS
    local fileTypes = {"Feature placer", "Diffuse", "Heightmap"}
    sfd = ImportFileDialog(dir, fileTypes)
    sfd:setConfirmDialogCallback(
        function(path, fileType)
            if fileType == fileTypes[1] then
                Spring.Log("scened", LOG.NOTICE, "Importing feature placer file: " .. path .. " ...")
                local modelData = VFS.LoadFile(path, VFS.RAWFIRST)
                local importCommand = ImportFeaturePlacerCommand(modelData)
                SCEN_EDIT.commandManager:execute(importCommand)
                Spring.Log("scened", LOG.NOTICE, "Import complete.")
            elseif fileType == fileTypes[2] then
                Spring.Log("scened", LOG.NOTICE, "Importing diffuse: " .. path .. " ...")
                local importCommand = ImportDiffuseCommand(path)
                SCEN_EDIT.commandManager:execute(importCommand, true)
                Spring.Log("scened", LOG.NOTICE, "Import complete.")
            elseif fileType == fileTypes[3] then
                local ebMinHeight = EditBox:New {
                    hint = "Min height: ",
                    text = ""
                }
                local ebMaxHeight = EditBox:New {
                    hint = "Max height: ",
                    text = "",
                }
                local window
                window = Window:New {
                    width = 200,
                    height = 200,
                    x = 550,
                    y = 350,
                    parent = screen0,
                    children = {
                        StackPanel:New {
                            x = 0, y = 0,
                            right = 0, bottom = 0,
                            children = {
                                ebMinHeight,
                                ebMaxHeight,
                                Button:New {
                                    caption = "OK",
                                    OnClick = { function()
                                        local maxHeight = tonumber(ebMaxHeight.text)
                                        local minHeight = tonumber(ebMinHeight.text)
                                        if maxHeight == nil or minHeight == nil then
                                            return
                                        end
                                        Spring.Log("scened", LOG.NOTICE, "Importing heightmap: " .. path .. " ...")
                                        local importCommand = ImportHeightmapCommand(path, maxHeight, minHeight)
                                        SCEN_EDIT.commandManager:execute(importCommand, true)
                                        Spring.Log("scened", LOG.NOTICE, "Import complete.")
                                        window:Dispose()
                                    end},
                                },
                                Button:New {
                                    caption = "Cancel",
                                    OnClick = { function()
                                        window:Dispose()
                                    end},
                                },
                            },
                        }
                    },
                }
            else
                Spring.Log("scened", LOG.ERROR, "Error trying to export. Invalida fileType specified: " .. tostring(fileType))
            end
        end
    )
end
