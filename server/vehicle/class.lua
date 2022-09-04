---@class CVehicle
---@field id number
---@field owner number
---@field netid number
---@field entity number
---@field model string
---@field plate string
---@field script string
---@field set fun(key: string, value: any)
---@field get fun(key: string): any
---@field getState fun(): { [string]: any, set: fun(self: table, key: string, value: any, replicated: boolean) }
---@field delete function
---@field store fun(value: string?)

---@type CVehicle
local CVehicle = Class.new('CVehicle')

---Backing method for imported method calls.
---@param source number
---@param method string
---@param ... unknown
---@return unknown
function Ox.CVehicle(source, method, ...)
    local vehicle = Ox.GetVehicle(source)
    return vehicle and CVehicle[method](vehicle, ...)
end

local vehicleData = {}
local VehicleRegistry = require 'vehicle.registry'

---Triggered after vehicle instantiation to setup metadata.
---@param data table
function CVehicle:init(data)
    if not vehicleData[self.entity] then
        VehicleRegistry[self.entity] = self
        vehicleData[self.entity] = data
    end
end

---Gets the vehicle's metadata, returning the entire table if key is omitted.
function CVehicle:get(index)
    local data = vehicleData[self.entity]
    return index and data[index] or data
end

---Update the vehicle's metadata.
---@param key string
---@param value any
function CVehicle:set(key, value)
    if key == 'properties' and value.plate then
        self.plate = value.plate
    end

    vehicleData[self.entity][key] = value
end

function CVehicle:getState()
    return Entity(self.entity).state
end

function CVehicle:delete()
    Vehicle.despawn(self, true)
    vehicleData[self.entity] = nil
end

function CVehicle:store(value)
    self.stored = value or self.stored or 'impound'
    Vehicle.despawn(self, nil, vehicleData[self.entity])
    vehicleData[self.entity] = nil
end

return CVehicle
