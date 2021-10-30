----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: asset.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Asset Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    ipairs = ipairs,
    md5 = md5,
    split = split,
    gettok = gettok,
    tonumber = tonumber,
    tostring = tostring,
    fromJSON = fromJSON,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    setTimer = setTimer,
    fileExists = fileExists,
    engineRequestModel = engineRequestModel,
    engineSetModelLODDistance = engineSetModelLODDistance,
    engineFreeModel = engineFreeModel,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL,
    dxCreateTexture = dxCreateTexture,
    file = {
        read = file.read
    },
    table = {
        clone = table.clone
    },
    string = {
        byte = string.byte,
        lower = string.lower,
        gsub = string.gsub
    },
    math = {
        min = math.min,
        max = math.max
    }
}


----------------------
--[[ Class: Asset ]]--
----------------------

asset = {
    references = {
        root = "@files/assets/",
        manifest = "manifest",
        asset = "asset",
        scene = "scene"
    },
    separators = {
        IPL = imports.string.byte(", ")
    },
    ranges = {
        dimension = {-1, 65535},
        interior = {0, 255}
    }
}
asset.__index = asset

if localPlayer then
    asset.shaders = {
        controlMap = {
            validControls = {"red", "green", "blue"}
        }
    }

    function asset:create(...)
        local cAsset = imports.setmetatable({}, {__index = self})
        if not cAsset:load(...) then
            cAsset = nil
            return false
        end
        return cAsset
    end
    
    function asset:destroy(...)
        if not self or (self == asset) then return false end
        return self:unload(...)
    end
    
    function asset:load(assetType, assetPack, rwCache, assetManifest, assetData, rwPaths, callback)
        if not self or (self == asset) then return false end
        if not assetType or not assetPack or not assetPack.assetType or not rwCache or not assetManifest or not assetData or not rwPaths then return false end
        local modelID = false
        if rwPaths.dff then
            modelID = imports.engineRequestModel(assetPack.assetType, (assetManifest.assetBase and (imports.type(assetManifest.assetBase) == "number") and assetManifest.assetBase) or assetPack.assetBase or nil)
            if modelID then
                imports.engineSetModelLODDistance(modelID, 300)
                if not rwCache.dff[(rwPaths.dff)] then
                    rwCache.dff[(rwPaths.dff)] = imports.engineLoadDFF(rwPaths.dff)
                end
                if not rwCache.dff[(rwPaths.dff)] then
                    imports.engineFreeModel(modelID)
                    return false
                else
                    if not rwCache.col[(rwPaths.col)] then
                        rwCache.col[(rwPaths.col)] = imports.engineLoadCOL(rwPaths.col)
                    end
                end
            end
        end
        local loadState = false
        if not rwCache.txd[(rwPaths.txd)] then
            rwCache.txd[(rwPaths.txd)] = imports.engineLoadTXD(rwPaths.txd)
        end
        if rwCache.txd[(rwPaths.txd)] then
            imports.engineImportTXD(rwCache.txd[(rwPaths.txd)], modelID)
        end
        imports.engineReplaceModel(rwCache.dff[(rwPaths.dff)], modelID, (assetManifest and assetManifest.assetTransparency and true) or assetPack.assetTransparency)
        if rwCache.col then
            imports.engineReplaceCOL(rwCache.col[(rwPaths.col)], modelID)
        end
        assetData.cAsset = self
        self.rwPaths = rwPaths
        self.syncedData = {
            modelID = modelID
        }
        loadState = true
        if callback and (imports.type(callback) == "function") then
            callback(loadState)
        end
        return loadState
    end

    function asset:unload(rwCache, callback)
        if not self or (self == asset) then return false end
        if not rwCache then return false end
        imports.engineFreeModel(self.syncedData.modelID)
        if self.rwPaths then
            for i, j in imports.pairs(self.rwPaths) do
                if rwCache[i] and rwCache[i][j] and imports.isElement(rwCache[i][j]) then
                    imports.destroyElement(rwCache[i][j])
                    rwCache[i][j] = nil
                end
            end
        end
        self = nil
        if callback and (imports.type(callback) == "function") then
            callback(true)
        end
        return true
    end

    function asset:refreshShaderPack(assetType, assetName, shaderPack, mapType, rwCache, state)
        if not assetType or not assetName or not shaderPack or not rwCache then return false end
        for i, j in imports.pairs(shaderPack) do
            if not mapType then
                if state then
                    rwCache[i] = {}
                end
                asset:refreshShaderPack(assetType, assetName, j, i, rwCache, state)
            else
                for k, v in imports.pairs(shaderPack) do
                    if state then
                        if not rwCache[mapType][k] then
                            rwCache[mapType][k] = {}
                            if mapType == "bump" then
                                if v.map and imports.fileExists(v.map) then
                                    local createdMap = imports.dxCreateTexture(v.map, "dxt5", true)
                                    local createdBumpMap = exports.graphify_library:createBumpMap(i, "world", createdMap)
                                    rwCache[mapType][k] = {map = createdMap, shader = createdBumpMap}
                                end
                            elseif mapType == "control" then
                                local isControlValid = true
                                for m, n in imports.ipairs(asset.shaders.controlMap.validControls) do
                                    if not v[n] or not v[n].map or not imports.fileExists(v[n].map) or not v[n].scale or (imports.type(v[n].scale) ~= "number") or (v[n].scale <= 0) then
                                        isControlValid = false
                                        break
                                    end
                                end
                                if isControlValid then
                                    local redControl = imports.dxCreateTexture(v.red.map, "dxt5", true)
                                    local greenControl = imports.dxCreateTexture(v.green.map, "dxt5", true)
                                    local blueControl = imports.dxCreateTexture(v.blue.map, "dxt5", true)
                                    local createdControlMap = exports.graphify_library:createControlMap(i, "world", {
                                        red = {texture = redControl, scale = v.red.scale},
                                        green = {texture = greenControl, scale = v.green.scale},
                                        blue = {texture = blueControl, scale = v.blue.scale}
                                    })
                                    rwCache[mapType][k] = {
                                        shader = createdControlMap,
                                        redControl = redControl,
                                        greenControl = greenControl,
                                        blueControl = blueControl
                                    }
                                end
                            end
                        end
                    else
                        if rwCache[mapType][k] then
                            for m, n in imports.pairs(rwCache[mapType][k]) do
                                if n and imports.isElement(n) then
                                    if (m == "shader") and (mapType == "control") then
                                        exports.graphify_library:destroyControlMap(n, true)
                                    else
                                        imports.destroyElement(n)
                                    end
                                end
                            end
                            rwCache[mapType][k] = nil
                        end
                    end
                end
                if mapType == "emissive" then
                    if j then
                        exports.graphify_library:setTextureEmissiveState(i, "world", state)
                    end
                end
            end
        end
        return true
    end
else
    function asset:buildFile(filePath, filePointer)
        if not filePath or not filePointer then return false end
        if not filePointer[filePath] then
            local builtFileData = imports.file.read(filePath)
            if builtFileData then
                filePointer[filePath] = true
                filePointer.fileData[filePath] = builtFileData
                filePointer.fileHash[filePath] = imports.md5(builtFileData)
            end
        end
        return true
    end

    function asset:buildShader(assetPath, shaderPack, assetFiles)
        for i, j in imports.pairs(shaderPack) do
            if j and (imports.type(j) == "table") then
                asset:buildShader(assetPath, j, assetFiles)
            else
                if i == "map" then
                    shaderPack[i] = assetPath.."map/"..j
                    asset:buildFile(shaderPack[i], assetFiles)
                end
            end
            thread.pause()
        end
        return true
    end

    function asset:buildPack(assetType, assetPack, callback)
        if not assetType or not assetPack or not callback or (imports.type(callback) ~= "function") then return false end
        local cAssetPack = imports.table.clone(assetPack, true)
        cAssetPack.manifestData = imports.file.read((asset.references.root)..imports.string.lower(assetType).."/"..(asset.references.manifest)..".json")
        cAssetPack.manifestData = (cAssetPack.manifestData and imports.fromJSON(cAssetPack.manifestData)) or false
        if cAssetPack.manifestData then
            cAssetPack.rwDatas = {}
            thread:create(function(cThread)
                local callbackReference = callback
                for i = 1, #cAssetPack.manifestData, 1 do
                    local assetReference = cAssetPack.manifestData[i]
                    local assetPath = (asset.references.root)..imports.string.lower(assetType).."/"..assetReference.."/"
                    local assetManifestPath = assetPath..(asset.references.asset)..".json"
                    local assetManifestData = imports.file.read(assetManifestPath)
                    assetManifestData = (assetManifestData and imports.fromJSON(assetManifestData)) or false
                    if not assetManifestData then
                        cAssetPack.rwDatas[assetPath] = false
                    else
                        cAssetPack.rwDatas[assetReference] = {
                            synced = {
                                manifestData = assetManifestData
                            },
                            unSynced = {
                                fileList = {},
                                fileData = {},
                                fileHash = {}
                            }
                        }
                        assetManifestData.shaderMaps = (assetManifestData.shaderMaps and (imports.type(assetManifestData.shaderMaps) == "table") and assetManifestData.shaderMaps) or false
                        if assetType == "scene" then
                            assetManifestData.sceneDimension = imports.math.max(asset.ranges.dimension[1], imports.math.min(asset.ranges.dimension[2], imports.tonumber(assetManifestData.sceneDimension) or 0))
                            assetManifestData.sceneInterior = imports.math.max(asset.ranges.interior[1], imports.math.min(asset.ranges.interior[2], imports.tonumber(assetManifestData.sceneInterior) or 0))
                            if assetManifestData.sceneOffset then
                                if imports.type(assetManifestData.sceneOffset) ~= "table" then
                                    assetManifestData.sceneOffset = false
                                else
                                    for i, j in imports.pairs(assetManifestData.sceneOffset) do
                                        assetManifestData.sceneOffset[i] = imports.tonumber(j)
                                    end
                                end
                            end
                            local sceneIPLPath = assetPath..(asset.references.scene)..".ipl"
                            local sceneManifestData = imports.file.read(sceneIPLPath)
                            if sceneManifestData then
                                asset:buildFile(sceneIPLPath, cAssetPack.rwDatas[assetReference].unSynced)
                                asset:buildFile(assetPath..(asset.references.asset)..".txd", cAssetPack.rwDatas[assetReference].unSynced)
                                local unparsedDatas = imports.split(sceneManifestData, "\n")
                                for k = 1, #unparsedDatas, 1 do
                                    local childName = imports.string.gsub(imports.tostring(imports.gettok(unparsedDatas[k], 2, asset.separators.IPL)), " ", "")
                                    asset:buildFile(assetPath.."dff/"..childName..".dff", cAssetPack.rwDatas[assetReference].unSynced)
                                    asset:buildFile(assetPath.."col/"..childName..".col", cAssetPack.rwDatas[assetReference].unSynced)
                                    thread.pause()
                                end
                            end
                        else
                            asset:buildFile(assetPath..(asset.references.asset)..".txd", cAssetPack.rwDatas[assetReference].unSynced)
                            asset:buildFile(assetPath..(asset.references.asset)..".dff", cAssetPack.rwDatas[assetReference].unSynced)
                            asset:buildFile(assetPath..(asset.references.asset)..".col", cAssetPack.rwDatas[assetReference].unSynced)
                            thread.pause()
                        end
                        if assetManifestData.shaderMaps then
                            asset:buildShader(assetPath, assetManifestData.shaderMaps, cAssetPack.rwDatas[assetReference].unSynced)
                        end
                    end
                end
                assetPack.assetPack = cAssetPack
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(true)
                end
            end):resume({
                executions = downloadSettings.buildRate,
                frames = 1
            })
            return true
        end
        if callbackReference and (imports.type(callbackReference) == "function") then
            callbackReference(false)
        end
        return false
    end
end