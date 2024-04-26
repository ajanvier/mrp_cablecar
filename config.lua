Config = {}

Config.Debug = false

Config.Price = 100

Config.DelayToKickCablecarPassengers = 1 * 60 * 1000 -- Delay (in ms) before kicking out players in an arrived cablecar
Config.DelayToRemoveInactiveCablecar = 5 * 60 * 1000 -- Delay (in ms) before removing an inactive cablecar

-- Disable phone during a ride (recommended to prevent glitching through the cablecar)
-- Only supports lb-phone, adapt DisablePhone() and EnablePhone() in client.lua for your own use
Config.DisablePhone = true

Config.CableCars = {
    PalaSpringsLeftTrack = {
        cabinCoords = vector4(-740.911, 5599.341, 47.25, 90.0),
        cabinStartZone = {
            points = {
                vector2(-736.09643554688, 5597.873046875),
                vector2(-746.07440185547, 5597.7553710938),
                vector2(-746.12506103516, 5601.1118164062),
                vector2(-735.55377197266, 5600.9775390625)
            },
            minZ = 40,
            maxZ = 42
        },
        cabinEndZone = {
            points = {
                vector2(441.42828369141, 5575.845703125),
                vector2(451.15399169922, 5575.8627929688),
                vector2(451.12448120117, 5579.20703125),
                vector2(441.39624023438, 5579.236328125)
            },
            minZ = 780,
            maxZ = 782
        },
        doorsCoords = vector4(-740.911, 5599.341, 47.25, 0.0),
        maxSpeed = 15.0,
        maxSpeedDist = 50.0, -- Distance from station at which the car will attain maximum speed
        offset = vector3(-0.2, 0.0, 0.0),
        path = {
            vector3(-740.911, 5599.341, 47.25),
            vector3(-739.557, 5599.346, 46.997),
            vector3(-581.009, 5596.517, 77.379),
            vector3(-575.717, 5596.388, 79.22),
            vector3(-273.805, 5590.844, 240.795),
            vector3(-268.707, 5590.744, 243.395),
            vector3(6.896, 5585.668, 423.614),
            vector3(11.774, 5585.591, 426.711),
            vector3(236.82, 5581.445, 599.642),
            vector3(241.365, 5581.369, 603.183),
            vector3(412.855, 5578.216, 774.401),
            vector3(417.541, 5578.124, 777.688),
            vector3(444.93, 5577.589, 786.535),
            vector3(446.288, 5577.59, 786.75),
        },
        ped = {
            model = `s_m_m_trucker_01`,
            coords = vector4(-737.02, 5594.95, 40.65, 88.17)
        },
    },

    PalaSpringsRightTrack = {
        cabinCoords = vector4(446.291, 5566.377, 786.75, 270.0),
        cabinStartZone = {
            points = {
                vector2(451.11120605469, 5568.0834960938),
                vector2(451.16217041016, 5564.7900390625),
                vector2(441.19195556641, 5564.7612304688),
                vector2(441.36416625977, 5568.08984375)
            },
            minZ = 780,
            maxZ = 782
        },
        cabinEndZone = {
            points = {
                vector2(-736.14, 5592.33),
                vector2(-746.18, 5592.27),
                vector2(-746.19, 5588.88),
                vector2(-736.09, 5589.0)
            },
            minZ = 40,
            maxZ = 42
        },
        doorsCoords = vector4(446.291, 5566.377, 786.75, 0.0),
        maxSpeed = 15.0,
        maxSpeedDist = 50.0, -- Distance from station at which the car will attain maximum speed
        offset = vector3(-0.2, 0.0, 0.0),
        path = {
            vector3(446.291, 5566.377, 786.75),
            vector3(444.937, 5566.383, 786.551),
            vector3(417.371, 5567.001, 777.708),
            vector3(412.661, 5567.085, 774.439),
            vector3(241.31, 5570.594, 603.137),
            vector3(236.821, 5570.663, 599.561),
            vector3(11.35, 5575.298, 426.629),
            vector3(6.575, 5575.391, 423.57),
            vector3(-268.965, 5580.996, 243.386),
            vector3(-273.993, 5581.124, 240.808),
            vector3(-575.898, 5587.286, 79.251),
            vector3(-581.321, 5587.4, 77.348),
            vector3(-739.646, 5590.614, 47.006),
            vector3(-740.97, 5590.617, 47.306),
        },
        ped = {
            model = `u_m_y_proldriver_01`,
            coords = vector4(442.79, 5572.03, 780.19, 268.8),
        },
    }
}