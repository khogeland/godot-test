import
  godot,
  colors,
  color_rect,
  collision_object_2d,
  rigid_body_2d,
  kinematic_body_2d,
  resource_loader,
  resource_loader,
  packed_scene,
  physics_body_2d,
  canvas_item

const
  LAYER_PLAYER* = 0
  LAYER_ENEMY* = 1
  LAYER_MAP_BACKGROUND* = 2

type HasHealthKinematicBody2D* = ref object of KinematicBody2D
  maxHealth*: int64
  health*: int64
  healthBar*: ColorRect

method onNoHealth*(h: HasHealthKinematicBody2D) {.base, gcsafe.} = discard

#type HasHealth* = concept h of CanvasItem
  #h.maxHealth is int64
  #h.health is int64
  #h.healthBar is ColorRect

#type HasHealthKinematicBody2D* = concept h of HasHealth
  #h is KinematicBody2D

proc addToCollisionLayers*(obj: PhysicsBody2D, layers: varargs[int]) =
  for layer in layers:
    obj.setCollisionLayerBit(layer, true)
  
proc addToCollisionMask*(obj: PhysicsBody2D, layers: varargs[int]) =
  for layer in layers:
    obj.setCollisionMaskBit(layer, true)

proc damage*(h: HasHealthKinematicBody2D, strength: int64) =
  echo h.name & " hit for " & $strength & ", new health: " & $h.health
  let oldHealth = h.health
  h.health -= strength
  if h.health <= 0:
    h.onNoHealth()
  h.healthBar.rectSize = vec2((h.healthBar.rectSize.x / float(oldHealth)) * float(h.health), h.healthBar.rectSize.y)

proc initHealthBar*(h: HasHealthKinematicBody2D, maxHealth: int64, color: godot.Color = static initColor(1.0, 0.0, 0.0)) =
  h.maxHealth = maxHealth
  h.health = maxHealth
  if not h.hasNode("HealthBar"):
    let healthBarScn = load("res://healthbar.tscn").as(PackedScene)
    h.healthBar = healthBarScn.instance().as(ColorRect)
    h.addChild(h.healthBar)

proc maybeTakeDamage*(h: HasHealthKinematicBody2D) =
  let slideCount = h.getSlideCount()
  #if slideCount != 0:
    #for i in 0..slideCount-1:
      #echo i

proc shoot*(body: KinematicBody2D, direction: Vector2, strength: int64, color: godot.Color, speed: float = 100.0, collisions: varargs[int]) =
  let bulletScn = load("res://bullet.tscn") as PackedScene # TODO: organization... this should be global... how?
  var bullet = bulletScn.instance().as(RigidBody2D)
  let velocity = normalized(direction) * speed
  bullet.as(PhysicsBody2D).addToCollisionMask(collisions)
  bullet.position = body.position
  bullet.linear_velocity = velocity
  bullet.getNode("Sprite").as(Sprite).modulate = color
  bullet.setMeta("damage", newVariant(strength))
  body.getParent().addChild(bullet)

