----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: shared.lua
     Server: -
     Author: OvileAmriam
     Developer(s): Aviril, Tron
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Shared Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    fileExists = fileExists,
    fileCreate = fileCreate,
    fileDelete = fileDelete,
    fileOpen = fileOpen,
    fileRead = fileRead,
    fileWrite = fileWrite,
    fileGetSize = fileGetSize,
    fileClose = fileClose,
    math = math
}


---------------------
--[[ Class: File ]]--
---------------------

file = {
    exists = imports.fileExists,
    delete = imports.fileDelete,
    read = function(path)
        if not path or not imports.fileExists(path) then return false end
        local cFile = imports.fileOpen(path, true)
        if not cFile then return false end
        local data = imports.fileRead(cFile, imports.fileGetSize(cFile))
        imports.fileClose(cFile)
        return data
    end,
    write = function(path, data)
        if not path or not data then return false end
        local cFile = imports.fileCreate(path)
        if not cFile then return false end
        imports.fileWrite(cFile, data)
        imports.fileClose(cFile)    
        return true
    end
}


----------------------
--[[ Class: Table ]]--
----------------------

function table.clone(baseTable, isRecursive)
    if not baseTable or imports.type(baseTable) ~= "table" then return false end
    local clonedTable = {}
    for i, j in imports.pairs(baseTable) do
        if imports.type(j) == "table" and isRecursive then
            clonedTable[i] = table.clone(j, true)
        else
            clonedTable[i] = j
        end
    end
    return clonedTable
end


---------------------
--[[ Class: Quat ]]--
---------------------

quat = {
    toEuler = function(w, x, y, z)
        if not w or not x or not y or not z then return false end
        return -imports.math.deg(imports.math.atan2(-2*((y*z) - (w*x)), (w*w) - (x*x) - (y*y) + (z*z))), -imports.math.deg(imports.math.asin(2*((x*z) + (w*y)))), -imports.math.deg(imports.math.atan2(-2*((x*y) - (w*z)), (w*w) + (x*x) - (y*y) - (z*z)))
    end
}


-----------------------
--[[ Class: Matrix ]]--
-----------------------

matrix = {
    fromRotation = function(rotX, rotY, rotZ)
        if not rotX or not rotY or not rotZ then return false end
        rotX, rotY, rotZ = imports.math.rad(rotX), imports.math.rad(rotY), imports.math.rad(rotZ)
        local sYaw, cYaw = imports.math.sin(rotX), imports.math.cos(rotX)
        local sPitch, cPitch = imports.math.sin(rotY), imports.math.cos(rotY)
        local sRoll, cRoll = imports.math.sin(rotZ), imports.math.cos(rotZ)
        return {
            {(sRoll*sPitch*sYaw) + (cRoll*cYaw), sRoll*cPitch, (sRoll*sPitch*cYaw) - (cRoll*sYaw)},
            {(cRoll *sPitch*sYaw) - (sRoll*cYaw), cRoll*cPitch, (cRoll*sPitch*cYaw) + (sRoll*sYaw)},
            {cPitch*sYaw, -sPitch, cPitch*cYaw}
        }
    end,

    transform = function(elemMatrix, rotMatrix, posX, posY, posZ)
        if not elemMatrix or not rotMatrix or not posX or not posY or not posZ then return false end
        return {
            {
                (elemMatrix[2][1]*rotMatrix[1][2]) + (elemMatrix[1][1]*rotMatrix[1][1]) + (rotMatrix[1][3]*elemMatrix[3][1]),
                (elemMatrix[3][2]*rotMatrix[1][3]) + (elemMatrix[1][2]*rotMatrix[1][1]) + (elemMatrix[2][2]*rotMatrix[1][2]),
                (elemMatrix[2][3]*rotMatrix[1][2]) + (elemMatrix[3][3]*rotMatrix[1][3]) + (rotMatrix[1][1]*elemMatrix[1][3]),
                0
            },
            {
                (rotMatrix[2][3]*elemMatrix[3][1]) + (elemMatrix[2][1]*rotMatrix[2][2]) + (rotMatrix[2][1]*elemMatrix[1][1]),
                (elemMatrix[3][2]*rotMatrix[2][3]) + (elemMatrix[2][2]*rotMatrix[2][2]) + (elemMatrix[1][2]*rotMatrix[2][1]),
                (rotMatrix[2][1]*elemMatrix[1][3]) + (elemMatrix[3][3]*rotMatrix[2][3]) + (elemMatrix[2][3]*rotMatrix[2][2]),
                0
            },
            {
                (elemMatrix[2][1]*rotMatrix[3][2]) + (rotMatrix[3][3]*elemMatrix[3][1]) + (rotMatrix[3][1]*elemMatrix[1][1]),
                (elemMatrix[3][2]*rotMatrix[3][3]) + (elemMatrix[2][2]*rotMatrix[3][2]) + (rotMatrix[3][1]*elemMatrix[1][2]),
                (rotMatrix[3][1]*elemMatrix[1][3]) + (elemMatrix[3][3]*rotMatrix[3][3]) + (elemMatrix[2][3]*rotMatrix[3][2]),
                0
            },
            {
                (posZ*elemMatrix[1][1]) + (posY*elemMatrix[2][1]) - (posX*elemMatrix[3][1]) + elemMatrix[4][1],
                (posZ*elemMatrix[1][2]) + (posY*elemMatrix[2][2]) - (posX*elemMatrix[3][2]) + elemMatrix[4][2],
                (posZ*elemMatrix[1][3]) + (posY*elemMatrix[2][3]) - (posX*elemMatrix[3][3]) + elemMatrix[4][3],
                1
            }
        }
    end
}