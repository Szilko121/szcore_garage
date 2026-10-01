local G={};local spawnLocks={};local rate={}
local function near(source,coords,max)
    local ped=GetPlayerPed(source);if ped==0 or not coords then return false end
    local c=GetEntityCoords(ped);local dx,dy,dz=c.x-coords.x,c.y-coords.y,c.z-coords.z;return dx*dx+dy*dy+dz*dz <= (max or SzCoreGarageConfig.requestDistance)^2
end
local function allowed(src,key,ms)local n=GetGameTimer();rate[src]=rate[src] or {};local p=rate[src][key] or 0;if n-p<ms then return false end;rate[src][key]=n;return true end
local function statesHas(g,state) if not g.states then return state=='stored' end;for i=1,#g.states do if g.states[i]==state then return true end end;return false end
local function groupAccess(p,groups)
    if not groups then return true end
    if type(groups)=='string' then return p.hasGroup('jobs',groups,0) or p.hasGroup('gangs',groups,0) end
    if #groups>0 then for i=1,#groups do if p.hasGroup('jobs',groups[i],0) or p.hasGroup('gangs',groups[i],0) then return true end end;return false end
    for name,grade in pairs(groups) do if p.hasGroup('jobs',name,grade) or p.hasGroup('gangs',name,grade) then return true end end
    return false
end
local function garageAccess(source,name,point,mode)
    local p=exports.szcore:GetPlayer(source);local g=G[name] or SzCoreGarages[name];if not p or not g then return nil,'garage_not_found' end
    local ap=g.accessPoints and g.accessPoints[tonumber(point) or 1];if not ap then return nil,'access_point_not_found' end
    local target=(mode=='store' and ap.dropPoint) or ap.coords;if not target or not near(source,target,SzCoreGarageConfig.requestDistance) then return nil,'too_far' end
    if not groupAccess(p,g.groups) then return nil,'no_access' end
    if type(g.canAccess)=='function' then local ok,res=pcall(g.canAccess,source,p);if not ok or not res then return nil,'no_access' end end
    return p,g,ap
end
local function spawnClear(c,r)
    r=r or SzCoreGarageConfig.spawnClearRadius;local rr=r*r
    for _,e in ipairs(GetAllVehicles()) do if DoesEntityExist(e) then local p=GetEntityCoords(e);local dx,dy,dz=p.x-c.x,p.y-c.y,p.z-c.z;if dx*dx+dy*dy+dz*dz<=rr then return false end end end
    return true
end
local function serializeVehicle(v)
    return {id=v.id,plate=v.plate,model=v.model,vehicle_type=v.vehicle_type,garage=v.garage,state=v.state,fuel=tonumber(v.fuel)or 100,engine=tonumber(v.engine)or 1000,body=tonumber(v.body)or 1000,mileage=tonumber(v.mileage)or 0,impound_fee=tonumber(v.impound_fee)or 0,impound_reason=v.impound_reason,props=v.props}
end
local function list(source,name,point)
    local p,g=garageAccess(source,name,point,'pickup');if not p then return nil,g end
    local rows
    if g.shared then rows=MySQL.query.await('SELECT * FROM szcore_vehicles WHERE garage=? ORDER BY updated_at DESC',{name}) or {}
    elseif g.skipGarageCheck then rows=MySQL.query.await('SELECT * FROM szcore_vehicles WHERE citizenid=? ORDER BY updated_at DESC',{p.PlayerData.citizenid}) or {}
    else rows=MySQL.query.await('SELECT * FROM szcore_vehicles WHERE citizenid=? AND garage=? ORDER BY updated_at DESC',{p.PlayerData.citizenid,name}) or {} end
    local out={}
    for i=1,#rows do
        local v=rows[i];if statesHas(g,v.state) and (not g.vehicleType or g.vehicleType==v.vehicle_type) then
            local ok,props=pcall(json.decode,v.props or '{}');v.props=ok and props or {};out[#out+1]=serializeVehicle(v)
        end
    end
    return {garage={name=name,label=g.label,type=g.type or 'garage'},vehicles=out}
end
local function spawn(source,id,name,point)
    if not allowed(source,'spawn',700) then return nil,'rate_limited' end
    id=tonumber(id);if not id or spawnLocks[id] then return nil,'vehicle_busy' end;spawnLocks[id]=true
    local p,g,ap=garageAccess(source,name,point,'pickup');local v=id and exports.szcore_vehicles:GetVehicleById(id)
    if not p or not g or not ap or not v then spawnLocks[id]=nil;return nil,'not_allowed' end
    if not statesHas(g,v.state) then spawnLocks[id]=nil;return nil,'invalid_state' end
    if not g.shared and v.citizenid~=p.PlayerData.citizenid then spawnLocks[id]=nil;return nil,'not_owner' end
    if not g.skipGarageCheck and v.garage~=name then spawnLocks[id]=nil;return nil,'wrong_garage' end
    local target=ap.spawn or ap.coords
    if not spawnClear(target,SzCoreGarageConfig.spawnClearRadius) then spawnLocks[id]=nil;return nil,'spawn_blocked' end
    local entity=exports.szcore_vehicles:SpawnPersistentVehicle(v,target)
    if not entity then spawnLocks[id]=nil;return nil,'spawn_failed'end
    local called,ok,err=pcall(function()return exports.szcore:ReleaseVehicleAtomic(source,v,name,{x=target.x,y=target.y,z=target.z,w=target.w})end)
    if not called or not ok then DeleteEntity(entity);spawnLocks[id]=nil;return nil,called and err or 'database_error'end
    if g.groups then Entity(entity).state:set('szcoreSharedKeyGroups',g.groups,true) end
    Entity(entity).state:set('szcoreGarage',name,true)
    spawnLocks[id]=nil;exports.szcore:Audit('garage.spawn',source,v.id,{garage=name});return NetworkGetNetworkIdFromEntity(entity)
end
local function store(source,netId,name,point,props)
    if not allowed(source,'store',700) then return false,'rate_limited' end
    local p,g,ap=garageAccess(source,name,point,'store');local entity=NetworkGetEntityFromNetworkId(tonumber(netId)or 0)
    if not p or not g or not ap or entity==0 or not DoesEntityExist(entity) or not near(source,ap.dropPoint or ap.coords,15.0) then return false,'vehicle_missing' end
    local ped=GetPlayerPed(source);local pc,vc=GetEntityCoords(ped),GetEntityCoords(entity)
    local dx,dy,dz=pc.x-vc.x,pc.y-vc.y,pc.z-vc.z
    if dx*dx+dy*dy+dz*dz>100 or GetEntityRoutingBucket(entity)~=GetPlayerRoutingBucket(source) or GetPedInVehicleSeat(entity,-1)~=ped then return false,'not_driver_or_too_far' end
    local v=exports.szcore_vehicles:GetRecordByEntity(entity);if not v then return false,'unknown_vehicle' end
    if not g.shared and v.citizenid~=p.PlayerData.citizenid then return false,'not_owner' end
    if v.state~='out' then return false,'invalid_state' end
    if type(props)~='table' or #json.encode(props)>65535 then props=nil end
    local c=GetEntityCoords(entity);local fuel=props and tonumber(props.fuel)or tonumber(v.fuel)or 100;local engine=props and tonumber(props.engineHealth)or tonumber(v.engine)or 1000;local body=props and tonumber(props.bodyHealth)or tonumber(v.body)or 1000
    local ok=MySQL.update.await([[UPDATE szcore_vehicles SET state='stored',garage=?,last_position=?,props=COALESCE(?,props),fuel=?,engine=?,body=?,impound_fee=0,impound_reason=NULL,impounded_at=NULL WHERE id=? AND state='out']],{name,json.encode({x=c.x,y=c.y,z=c.z,w=GetEntityHeading(entity)}),props and json.encode(props)or nil,fuel,engine,body,v.id})>0
    if not ok then return false,'database_error' end
    DeleteEntity(entity);exports.szcore:Audit('garage.store',source,v.id,{garage=name});return true
end
local function impound(source,netId,fee,reason)
    local p=exports.szcore:GetPlayer(source);if not p or not (p.hasPermission('police.impound') or (p.PlayerData.job.name=='police' and p.PlayerData.job.onduty)) then return false,'no_permission' end
    local entity=NetworkGetEntityFromNetworkId(tonumber(netId)or 0);if entity==0 or not DoesEntityExist(entity) then return false,'vehicle_missing' end
    local pc,vc=GetEntityCoords(GetPlayerPed(source)),GetEntityCoords(entity);local dx,dy,dz=pc.x-vc.x,pc.y-vc.y,pc.z-vc.z;if dx*dx+dy*dy+dz*dz>100 or GetPlayerRoutingBucket(source)~=GetEntityRoutingBucket(entity) then return false,'too_far' end
    local record=exports.szcore_vehicles:GetRecordByEntity(entity);local id=record and record.id;if not id then return false,'not_persistent' end
    fee=math.max(0,math.min(math.floor(tonumber(fee)or 0),1000000));reason=tostring(reason or 'Hatósági lefoglalás'):sub(1,128)
    local ok=MySQL.update.await("UPDATE szcore_vehicles SET state='impounded',garage='impound',impound_fee=?,impound_reason=?,impounded_at=CURRENT_TIMESTAMP WHERE id=?",{fee,reason,id})>0
    if ok then DeleteEntity(entity);exports.szcore:Audit('garage.impound',source,id,{fee=fee,reason=reason})end;return ok
end
function G.moveVehicle(vehicleId,garage,state)
    vehicleId=tonumber(vehicleId);local g=G[garage] or SzCoreGarages[garage];if not vehicleId or not g then return false,'garage_not_found' end
    state=state or 'stored';if state~='stored' and state~='out' and state~='impounded' then return false,'invalid_state' end
    return MySQL.update.await('UPDATE szcore_vehicles SET garage=?,state=? WHERE id=?',{garage,state,vehicleId})>0
end
function G.setImpoundFee(vehicleId,fee,reason)
    vehicleId=tonumber(vehicleId);fee=math.max(0,math.min(math.floor(tonumber(fee)or 0),1000000));if not vehicleId then return false end
    return MySQL.update.await("UPDATE szcore_vehicles SET state='impounded',garage='impound',impound_fee=?,impound_reason=?,impounded_at=CURRENT_TIMESTAMP WHERE id=?",{fee,tostring(reason or'Impound'):sub(1,128),vehicleId})>0
end
function G.get(name)return G[name] or SzCoreGarages[name]end
function G.getAll()local out={};for n,v in pairs(SzCoreGarages)do out[n]=v end;for n,v in pairs(G)do if type(v)=='table'then out[n]=v end end;return out end
function G.register(name,data)if type(name)~='string'or type(data)~='table'or not data.accessPoints then return false end;G[name]=data;TriggerClientEvent('szcore_garage:register',-1,name,data);return true end
function G.unregister(name)G[name]=nil;TriggerClientEvent('szcore_garage:unregister',-1,name);return true end
exports.szcore:CreateCallback('szcore_garage:list',list)
exports.szcore:CreateCallback('szcore_garage:spawn',function(src,id,...)
    local key=tonumber(id);if not key or spawnLocks[key]then return nil,'vehicle_busy'end
    local result=table.pack(pcall(spawn,src,id,...));spawnLocks[key]=nil
    if not result[1] then print('[SzCore garage] '..tostring(result[2]));return nil,'operation_failed' end
    return table.unpack(result,2,result.n)
end)
exports.szcore:CreateCallback('szcore_garage:store',store);exports.szcore:CreateCallback('szcore_garage:impound',impound)
exports('RegisterGarage',G.register);exports('UnregisterGarage',G.unregister);exports('ImpoundVehicle',impound);exports('MoveVehicle',G.moveVehicle);exports('SetImpoundFee',G.setImpoundFee);exports('GetGarage',G.get);exports('GetGarages',G.getAll)
AddEventHandler('playerDropped',function()rate[source]=nil end)
