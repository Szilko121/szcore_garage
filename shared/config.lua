SzCoreGarageConfig = {
    spawnClearRadius = 3.0, requestDistance = 12.0, autoRespawnOnRestart = false,
    warpIntoVehicle = true, lockOnSpawn = false, engineOnSpawn = false, interactionDistance = 2.0,
}
SzCoreGarages = {
    legion = {label='Legion Square Parking',vehicleType='automobile',shared=false,states={'stored'},accessPoints={{coords=vector4(215.10,-810.00,30.73,157.0),spawn=vector4(229.36,-800.11,30.57,157.0),dropPoint=vector3(220.0,-800.0,30.7),blip={sprite=357,color=3,scale=.75}}}},
    hawick = {label='Hawick Parking',vehicleType='automobile',shared=false,states={'stored'},accessPoints={{coords=vector4(365.20,297.66,103.49,343.0),spawn=vector4(374.62,288.73,103.11,164.0),dropPoint=vector3(363.5,296.2,103.5),blip={sprite=357,color=3,scale=.75}}}},
    police = {label='Police Motorpool',vehicleType='automobile',shared=true,groups={police=0},states={'stored'},accessPoints={{coords=vector4(454.64,-1017.45,28.43,90.0),spawn=vector4(438.64,-1018.29,27.76,90.0),dropPoint=vector3(445.2,-1020.0,28.5),blip={sprite=357,color=38,scale=.75}}}},
    pillbox = {label='Pillbox EMS Garage',vehicleType='automobile',shared=true,groups={ambulance=0},states={'stored'},accessPoints={{coords=vector4(300.16,-582.03,43.26,115.0),spawn=vector4(290.99,-587.42,43.17,70.0),dropPoint=vector3(295.93,-604.97,43.30),blip={sprite=357,color=2,scale=.75}}}},
    impound = {label='City Impound',type='depot',vehicleType='automobile',shared=false,states={'impounded'},skipGarageCheck=true,accessPoints={{coords=vector4(409.35,-1623.03,29.29,230.0),spawn=vector4(401.77,-1647.65,29.29,230.0),dropPoint=vector3(0,0,0),blip={sprite=68,color=1,scale=.8}}}}
}
