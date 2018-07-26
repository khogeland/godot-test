import
  godot,
  engine,
  input,
  canvas_item,
  animated_sprite,
  rigid_body_2d

gdobj Hero of RigidBody2D:

  var speed* {.gdExport.} = 400
  
  method ready*() = setProcess(true)

  method process*(delta: float64) =
    var velocity = vec2()
    if isActionPressed("ui_right"):
      velocity.x += 1
    if isActionPressed("ui_left"):
      velocity.x -= 1
    if isActionPressed("ui_down"):
      velocity.y += 1
    if isActionPressed("ui_up"):
      velocity.y -= 1
    var sprite = getNode("HeroSprite") as AnimatedSprite
    if length(velocity) > 0:
      velocity = velocity.normalized() * speed.float64
      sprite.flipH = velocity.x < 0
      sprite.play()
    else:
      sprite.stop()

    self.position=(self.position + velocity * delta)
    #self.position= vec2(clamp(self.position.x, 0, screenSize.x),
                        #clamp(self.position.y, 0, screenSize.y))
