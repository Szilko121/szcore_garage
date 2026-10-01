local runtime={};local opened=false;local current=nil
local function cfg(name)return runtime[name] or SzCoreGarages[name]end
local function notify(t,typ)exports.szcore_ui:Notify({description=t,type=typ or 'info'})end
local function clearAt(c,r)return not IsAnyVehicleNearPoint(c.x,c.y,c.z,r or SzCoreGarageConfig.spawnClearRadius)end
local function refresh()
    if not current then return end;local d,err=exports.szcore:AwaitCallback('szcore_garage:list',current.name,current.point)
    if d and opened then SendNUIMessage({action='data',data=d})elseif err then notify(err,'error')end
end
local function open(name,point)
    local d,err=exports.szcore:AwaitCallback('szcore_garage:list',name,point);if not d then return notify(err or 'Garázs nem elérhető.','error')end
    current={name=name,point=point or 1};opened=true;SetNuiFocus(true,true);SendNUIMessage({action='open',data=d})
end
local function close()opened=false;current=nil;SetNuiFocus(false,false);SendNUIMessage({action='close'})end
local function spawn(id)
    local g=cfg(current.name);local ap=g and g.accessPoints[current.point];if not ap then return end;local s=ap.spawn or ap.coords
    if not clearAt(s) then return notify('A spawn hely foglalt.','error')end
    local net,err=exports.szcore:AwaitCallback('szcore_garage:spawn',id,current.name,current.point);if not net then return notify(err or 'Nem sikerült kiadni a járművet.','error')end
    close();local timeout=GetGameTimer()+10000;local v=0;while GetGameTimer()<timeout do v=NetToVeh(net);if v~=0 and DoesEntityExist(v)then break end;Wait(50)end
    if v==0 then return notify('Jármű hálózati timeout.','error')end
    if SzCoreGarageConfig.engineOnSpawn then SetVehicleEngineOn(v,true,true,false)end
    if SzCoreGarageConfig.lockOnSpawn then SetVehicleDoorsLocked(v,2)else SetVehicleDoorsLocked(v,1)end
    if SzCoreGarageConfig.warpIntoVehicle then SetPedIntoVehicle(PlayerPedId(),v,-1)end
end
local function store(name,point)
    local ped=PlayerPedId();local v=GetVehiclePedIsIn(ped,false);if v==0 then return notify('Nem ülsz járműben.','error')end
    local props=exports.szcore_vehicles:GetVehicleProperties(v);local ok,err=exports.szcore:AwaitCallback('szcore_garage:store',NetworkGetNetworkIdFromEntity(v),name,point,props)
    notify(ok and 'Jármű elrakva.' or (err or 'Nem sikerült elrakni.'),ok and 'success'or'error')
end
RegisterNUICallback('close',function(_,cb)close();cb({ok=true})end)
RegisterNUICallback('spawn',function(d,cb)spawn(tonumber(d.id));cb({ok=true})end)
RegisterNUICallback('refresh',function(_,cb)refresh();cb({ok=true})end)
RegisterNetEvent('szcore_garage:register',function(n,d)runtime[n]=d end);RegisterNetEvent('szcore_garage:unregister',function(n)runtime[n]=nil end)
local zoneIds={}
local function buildZones()
    if GetResourceState('szcore_interact')~='started'then return end
    for _,id in ipairs(zoneIds)do exports.szcore_interact:RemoveZone(id)end;zoneIds={}
    local all={};for n,g in pairs(SzCoreGarages)do all[n]=g end;for n,g in pairs(runtime)do all[n]=g end
    for name,g in pairs(all)do for i,ap in ipairs(g.accessPoints or{})do
        if ap.blip then local b=AddBlipForCoord(ap.coords.x,ap.coords.y,ap.coords.z);SetBlipSprite(b,ap.blip.sprite or 357);SetBlipColour(b,ap.blip.color or 3);SetBlipScale(b,ap.blip.scale or .75);SetBlipAsShortRange(b,true);BeginTextCommandSetBlipName('STRING');AddTextComponentString(g.label);EndTextCommandSetBlipName(b)end
        zoneIds[#zoneIds+1]=exports.szcore_interact:AddSphereZone({name=('garage_%s_%d'):format(name,i),coords=vector3(ap.coords.x,ap.coords.y,ap.coords.z),radius=1.8,distance=2.2,options={{label=g.type=='depot' and 'Lefoglalt járművek' or 'Garázs megnyitása',icon='car',callback=function()open(name,i)end}}})
        local dp=ap.dropPoint;if dp and not(g.type=='depot')and not(dp.x==0 and dp.y==0)then zoneIds[#zoneIds+1]=exports.szcore_interact:AddSphereZone({name=('garage_store_%s_%d'):format(name,i),coords=dp,radius=2.5,distance=3.0,options={{label='Jármű elrakása',icon='parking',callback=function()store(name,i)end}}})end
    end end
end
AddEventHandler('onClientResourceStart',function(r)if r=='szcore_interact'or r==GetCurrentResourceName()then SetTimeout(800,buildZones)end end)
exports('OpenGarage',open);exports('StoreCurrentVehicle',store)
