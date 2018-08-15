import
  godot,
  engine,
  input,
  viewport,
  canvas_item,
  animated_sprite,
  kinematic_body_2d

gdobj Hero of KinematicBody2D:

  var speed* {.gdExport.} = 400.0
  var smooth_velocity_hardness {.gdExport.} = 1.0

  var prevVelocity = vec2()

  var heldLeft = false
  var heldUp = false

  var facingLeft = false

  method ready*() =
    #self.connect(self, "")
    setProcess(true)

  method process*(delta: float64) =
    var velocity = vec2()

    if isActionPressed("ui_left_click"):
        velocity = getLocalMousePosition()
        facingLeft = velocity.x < 0

    if isActionPressed("ui_right"):
      if isActionPressed("ui_left"):
        if heldLeft:
          velocity.x = 1
          facingLeft = false
        else:
          velocity.x = -1
          facingLeft = true
      else:
        heldLeft = false
        velocity.x += 1
        facingLeft = false
    elif isActionPressed("ui_left"):
      heldLeft = true
      velocity.x -= 1
      facingLeft = true

    if isActionPressed("ui_down"):
      if isActionPressed("ui_up"):
        if heldUp:
          velocity.y = 1
        else:
          velocity.y = -1
      else:
        heldUp = false
        velocity.y += 1
    elif isActionPressed("ui_up"):
      heldUp = true
      velocity.y -= 1

    velocity = lerp(prevVelocity, velocity.normalized() * speed, delta * smooth_velocity_hardness)
    prevVelocity = velocity

    var sprite = getNode("HeroSprite") as AnimatedSprite
    sprite.flipH = facingLeft
    if abs(velocity.y) + abs(velocity.x) > speed/10:
      sprite.play()
    else:
      sprite.stop()

    discard moveAndSlide(velocity)
