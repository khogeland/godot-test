import
  godot,
  speedcore,
  engine,
  colors,
  rigid_body_2d,
  node,
  collision_object_2d,
  collision_shape_2d,
  typetraits,
  sprite,
  times,
  collision_shape_2d

gdobj Bullet of RigidBody2D:
  
  var hitModulate {.gdExport.} = initColor(0.1, 0.1, 0.1)
  var hitDecayTimeSec {.gdExport.} = 0.01
  var hitTime = 0.0

  proc collide*(body_id: int, body: CollisionObject2D, body_shape: int, local_shape: int) {.gdExport.} =
    if body of HasHealthKinematicBody2D:
      body.as(HasHealthKinematicBody2D).damage(getMeta("damage").asInt())
    hitTime = epochTime()
    getNode("CollisionShape2D").as(CollisionShape2D).disabled = true

  method ready*() =
    discard connect("body_shape_entered", self, "collide", newArray())
    setProcess(true) 

  method process*(delta: float64) =
    if hitTime > 0:
      getNode("Sprite").as(Sprite).modulate = hitModulate
      if hitTime + hitDecayTimeSec < epochTime():
        getParent().removeChild(self)


