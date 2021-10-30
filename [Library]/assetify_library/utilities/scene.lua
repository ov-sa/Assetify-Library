----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: scene.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Scene Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tonumber = tonumber,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    collectgarbage = collectgarbage,
    createObject = createObject,
    setElementDoubleSided = setElementDoubleSided,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior
}


----------------------
--[[ Class: Scene ]]--
----------------------

scene = {}
scene.__index = scene

function scene:create(...)
    local cScene = imports.setmetatable({}, {__index = self})
    if not cScene:load(...) then
        cScene = nil
        return false
    end
    return cScene
end

function scene:destroy(...)
    if not self or (self == scene) then return false end
    return self:unload(...)
end

function scene:load(cAsset, sceneManifest, sceneData)
    if not self or (self == scene) then return false end
    if not cAsset or not sceneManifest or not sceneData then return false end
    self.cObject = imports.createObject(cAsset.syncedData.modelID, sceneData.position.x + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.x) or 0), sceneData.position.y + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.y) or 0), sceneData.position.z + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.z) or 0), sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z)
    imports.setElementDoubleSided(self.cObject, true)
    imports.setElementDimension(self.cObject, sceneManifest.sceneDimension)
    imports.setElementInterior(self.cObject, sceneManifest.sceneInterior)
    if sceneManifest.defaultLODs then
        self.cLODObject = imports.createObject(cAsset.syncedData.modelID, sceneData.position.x + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.x) or 0), sceneData.position.y + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.y) or 0), sceneData.position.z + ((sceneManifest.sceneOffset and sceneManifest.sceneOffset.z) or 0), sceneData.rotation.x, sceneData.rotation.y, sceneData.rotation.z, true)
        imports.setElementDoubleSided(self.cLODObject, true)
        imports.setElementDimension(self.cLODObject, sceneManifest.sceneDimension)
        imports.setElementInterior(self.cLODObject, sceneManifest.sceneInterior)
    end
    return true
end

function scene:unload(cAsset)
    if not self or (self == scene) then return false end
    if not cAsset then return false end
    if imports.isElement(self.cObject) then
        imports.destroyElement(self.cObject)
    end
    if imports.isElement(self.cLODObject) then
        imports.destroyElement(self.cLODObject)
    end
    self = nil
    imports.collectgarbage()
    return true
end