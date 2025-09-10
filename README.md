qb core server icebox heist

requirment - 
mlo icebox link - https://toxicfivem.com/threads/ice-box-diamond-store.905/
qb-core framework
qb-target
qb-doorlock 

add this line - qb/qb-doorlock/config.lua 

{
	objName ='ice-box-main left side',
    locked = true,
    doorRate = 1.0,
    doorType = 'door',
    distance = 1,
    hideLabel = true,
    authorizedJobs = { ['police'] = 0 },
    objName = -770610628,
    objCoords = vec3(-1230.656738, -800.096558, 18.008320),
    fixText = false,
    objYaw = 307.11312866211,
},

{
	objName = 'ice-box-main right side',
    locked = true,
    doorRate = 1.0,
    doorType = 'door',
    distance = 1,
    hideLabel = true,
    authorizedJobs = { ['police'] = 0 },
    objCoords = vec3(-1232.228271, -798.019653, 18.008320),
    fixText = false,
    objYaw = 127.1131362915,
},

 { objName = 'ice-box-2nd door',
    locked = true,
    doorRate = 1.0,
    doorType = 'door',
    distance = 1,
    objCoords = vec3(-1258.020142, -820.688293, 17.181341),
    objYaw = 217.1131439209,
    fixText = false,
    authorizedJobs = { ['police'] = 0 },
}

<img width="457" height="614" alt="{D1ACFBDD-A6BD-4F19-A020-AB0D1858D0B0}" src="https://github.com/user-attachments/assets/81e4b108-62dd-4588-ad00-5aaedd99cd9d" />

create new file in qb/qb-doorlock/configs/ new file name - ice-box.lua
paste this code



-- main left side created by bavan
Config.DoorList['ice-box-main left side'] = {
    locked = true,
    doorRate = 1.0,
    doorType = 'door',
    distance = 1,
    hideLabel = true,
    authorizedJobs = { ['police'] = 0 },
    objName = -770610628,
    objCoords = vec3(-1230.656738, -800.096558, 18.008320),
    fixText = false,
    objYaw = 307.11312866211,
}

-- main right side created by bavan
Config.DoorList['ice-box-main right side'] = {
    locked = true,
    doorRate = 1.0,
    doorType = 'door',
    distance = 1,
    hideLabel = true,
    authorizedJobs = { ['police'] = 0 },
    objName = -770610628,
    objCoords = vec3(-1232.228271, -798.019653, 18.008320),
    fixText = false,
    objYaw = 127.1131362915,
}

-- 2nd door created by bavan
Config.DoorList['ice-box-2nd door'] = {
    locked = true,
    doorRate = 1.0,
    doorType = 'door',
    distance = 1,
    objCoords = vec3(-1258.020142, -820.688293, 17.181341),
    objYaw = 217.1131439209,
    objName = -506110411,
    fixText = false,
    authorizedJobs = { ['police'] = 0 },
}

and save it
