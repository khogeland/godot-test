import
  godot,
  engine,
  colors,
  resource_loader,
  packed_scene,
  rigid_body_2d,
  node,
  collision_object_2d,
  sprite,
  times,
  collision_shape_2d

gdobj Bullet of RigidBody2D:
  
  var hitModulate {.gdExport.} = initColor(0.1, 0.1, 0.1)
  var hitDecayTimeSec {.gdExport.} = 0.05
  var hitTime = 0.0

  proc collide*(body_id: int, body: CollisionObject2D, body_shape: int, local_shape: int) {.gdExport.} =
    hitTime = epochTime()

  method ready*() =
    discard connect("body_shape_entered", self, "collide", newArray())
    setProcess(true) 

  method process*(delta: float64) =
    if hitTime > 0:
      getNode("Sprite").as(Sprite).modulate = hitModulate
      if hitTime + hitDecayTimeSec < epochTime():
        getParent().removeChild(self)



proc shoot*(body: KinematicBody2D, direction: Vector2, color: godot.Color, speed: float = 300.0) =
  let bulletScn = load("res://bullet.tscn") as PackedScene # TODO: organization... this should be global... how?
  var bullet = bulletScn.instance() as Bullet
  let velocity = normalized(direction) * speed
  bullet.position = body.position
  bullet.linear_velocity = velocity
  bullet.getNode("Sprite").as(Sprite).modulate = color
  body.getParent().addChild(bullet)

