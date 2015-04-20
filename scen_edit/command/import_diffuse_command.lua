ImportDiffuseCommand = AbstractCommand:extends{}
ImportDiffuseCommand.className = "ImportDiffuseCommand"

function ImportDiffuseCommand:init(texturePath)
    self.className = "ImportDiffuseCommand"
    self.texturePath = texturePath
end

function ImportDiffuseCommand:execute()
    SCEN_EDIT.delayGL(function()
        if not VFS.FileExists(self.texturePath) then
            Spring.Echo("Missing texture file: " .. tostring(self.texturePath))
            return
        end

        Spring.Log("scened", LOG.DEBUG, "Importing texture..")
        local totalMapTexture = gl.CreateTexture(Game.mapSizeX, Game.mapSizeZ, {
            border = false,
            min_filter = GL.NEAREST,
            mag_filter = GL.NEAREST,
            wrap_s = GL.CLAMP_TO_EDGE,
            wrap_t = GL.CLAMP_TO_EDGE,
            fbo = true,
        })
        gl.RenderToTexture(totalMapTexture, function()
            gl.Texture(self.texturePath)
            gl.TexRect(-1,-1, 1, 1,0, 0, 1, 1)
            gl.DeleteTexture(self.texturePath)
        end)

        local texSize = SCEN_EDIT.model.textureManager.TEXTURE_SIZE 
        local sizeX = math.floor(Game.mapSizeX / texSize)
        local sizeZ = math.floor(Game.mapSizeZ / texSize)
        gl.Texture(totalMapTexture)
        for i = 0, sizeX do
            for j = 0, sizeZ do
                local mapTexture = SCEN_EDIT.model.textureManager.mapFBOTextures[i][j]
                mapTexture.dirty = true
                gl.RenderToTexture(mapTexture.texture, function()
                    gl.TexRect(-1,-1, 1, 1,
                        i/sizeX, j/sizeZ, (i+1) / sizeX, (j+1) /sizeZ)
                end)
            end
        end
        gl.Texture(false)
        gl.DeleteTexture(totalMapTexture)
    end)
end