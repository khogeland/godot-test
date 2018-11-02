import
  godot,
  sequtils,
  physics_body_2d

const
  LAYER_PLAYER* = 0
  LAYER_ENEMY* = 1
  LAYER_MAP_BACKGROUND* = 2

proc addToCollisionLayers*(obj: PhysicsBody2D, layers: varargs[int]) =
  for layer in layers:
    obj.setCollisionLayerBit(layer, true)
  
proc addToCollisionMask*(obj: PhysicsBody2D, layers: varargs[int]) =
  for layer in layers:
    obj.setCollisionMaskBit(layer, true)
