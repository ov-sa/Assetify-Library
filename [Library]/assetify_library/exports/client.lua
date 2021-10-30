----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


---------------------------------
--[[ Functions: Asset's APIs ]]--
---------------------------------

function getAssetData(...)

    return manager:getData(...)

end

function isAssetLoaded(...)

    return manager:isLoaded(...)

end

function loadAsset(...)

    return manager:load(...)

end

function unloadAsset(...)

    return manager:unload(...)

end