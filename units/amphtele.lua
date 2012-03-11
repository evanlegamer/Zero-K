unitDef = {
  unitname               = [[amphtele]],
  name                   = [[Djinn]],
  description            = [[Amphibious Teleport Bridge]],
  acceleration           = 0.25,
  brakeRate              = 0.25,
  buildCostEnergy        = 1800,
  buildCostMetal         = 1800,
  builder                = false,
  buildPic               = [[amphtele.png]],
  buildTime              = 1800,
  canAttack              = false,
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  canstop                = [[1]],
  category               = [[LAND UNARMED]],
  --collisionVolumeOffsets = [[0 1 0]],
  --collisionVolumeScales  = [[36 49 35]],
  --collisionVolumeTest    = 1,
  --collisionVolumeType    = [[ellipsoid]],
  corpse                 = [[DEAD]],

  customParams           = {
    helptext       = [[Djinn excels at moving large land based armies across bodies of water. When deployed it teleports units from around it's pre-placed static beacon to it's present location. This is one way so ensure the destination is safe.]],
  },

  defaultmissiontype     = [[Standby]],
  explodeAs              = [[BIG_UNIT]],
  footprintX             = 3,
  footprintZ             = 3,
  iconType               = [[amphtransport]],
  idleAutoHeal           = 5,
  idleTime               = 1800,
  leaveTracks            = true,
  maneuverleashlength    = [[640]],
  mass                   = 196,
  maxDamage              = 2600,
  maxSlope               = 36,
  maxVelocity            = 1.2,
  maxWaterDepth          = 5000,
  minCloakDistance       = 75,
  movementClass          = [[AKBOT3]],
  moveState              = 0,
  noAutoFire             = false,
  noChaseCategory        = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET]],
  objectName             = [[amphteleport.s3o]],
  script                 = [[amphtele.lua]],
  pushResistant          = 1,
  seismicSignature       = 16,
  selfDestructAs         = [[BIG_UNIT]],
  side                   = [[ARM]],
  sightDistance          = 300,
  smoothAnim             = true,
  steeringmode           = [[1]],
  TEDClass               = [[AKBOT3]],
  trackOffset            = 0,
  trackStrength          = 8,
  trackStretch           = 1,
  trackType              = [[ComTrack]],
  trackWidth             = 24,
  turnRate               = 700,
  workerTime             = 0,

  featureDefs            = {

    DEAD = {
      description      = [[Wreckage - Djinn]],
      blocking         = true,
      category         = [[corpses]],
      damage           = 2600,
      energy           = 0,
      featureDead      = [[HEAP]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = [[40]],
      hitdensity       = [[100]],
      metal            = 720,
      object           = [[debris3x3c.s3o]],
      reclaimable      = true,
      reclaimTime      = 720,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP = {
      description      = [[Debris - Djinn]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 2600,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 360,
      object           = [[debris3x3c.s3o]],
      reclaimable      = true,
      reclaimTime      = 360,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ amphtele = unitDef })
