import
  godot,
  speedcore,
  times,
  ticker,
  engine,
  colors,
  input,
  camera_2d,
  viewport,
  label,
  canvas_item,
  animated_sprite,
  collision_shape_2d,
  rectangle_shape_2d,
  packed_scene,
  resource_loader,
  color_rect,
  bullet,
  kinematic_body_2d

gdobj Hero of HasHealthKinematicBody2D:

  var playerSpeed* {.gdExport.} = 200.0
  var damage* {.gdExport.}: int64 = 5
  var initialMaxHealth* {.gdExport.} = 100
  var smooth_velocity_hardness {.gdExport.} = 10.0
  var clickSpeedSec* {.gdExport.} = 0.1
  var shotIntervalSec* {.gdExport.} = 0.5
  var shotColor* {.gdExport.} = initColor(0.1, 0.1, 0.9)

  var dead = false

  var shooter = initTicker()

  var prevVelocity = vec2()

  var heldLeft = false
  var heldUp = false

  var facingLeft = false

  var lmbDown = false
  var lmbDownTime = 0.0
  var isClickMoving = false
  var clickPosition: Vector2 = nil
  var originalPositionWhenClicked: Vector2 = nil

  var clickMarker: AnimatedSprite = nil
  var hitbox: CollisionShape2D = nil
  var feetOffset: Vector2 = nil

  method ready*() =
    #self.connect(self, "")
    initHealthBar(initialMaxHealth)
    #discard connect("damage", self, "hit", newArray())
    clickMarker = getNode("/root/Main/ClickMarker").as(AnimatedSprite)
    hitbox = getNode("CollisionShape2D").as(CollisionShape2D)
    let hitboxShape = hitbox.shape.as(RectangleShape2D)
    feetOffset = hitbox.position() + hitboxShape.extents * vec2(0.5, 1)
    setProcess(true)

  proc cancelClickMove() =
    isClickMoving = false
    clickMarker.hide()

  method onNoHealth() =
    var sprite = getNode("HeroSprite") as AnimatedSprite
    sprite.rotationDegrees = 180
    var label = getNode("/root/Main/DeadLabel").as(Label)
    label.rectPosition = position()
    label.show()
    dead = true

  method process*(delta: float64) =
    if dead: return
    let currentTime = epochTime()

    var velocity = vec2()

    if isClickMoving:
      velocity = clickPosition - position()

    if isActionPressed("ui_right_click"):
      shooter.tick(
        proc() = self.shoot(self.getLocalMousePosition(), damage, shotColor, 100.0, LAYER_ENEMY, LAYER_MAP_BACKGROUND),
        shotIntervalSec) 

    if isActionPressed("ui_left_click"):
      cancelClickMove()
      velocity = getLocalMousePosition()
      facingLeft = velocity.x < 0
      if not lmbDown:
        lmbDown = true
        lmbDownTime = currentTime
    else:
      if lmbDownTime != 0.0 and currentTime - lmbDownTime <= clickSpeedSec and lmbDown:
        #echo lmbDownTime, " ", epochTime(), " ", epochTime() - lmbDownTime
        let mousePosition = getGlobalMousePosition()
        clickPosition = mousePosition - feetOffset
        originalPositionWhenClicked = position()
        isClickMoving = true
        clickMarker.frame = 0
        clickMarker.play()
        clickMarker.position = mousePosition
        clickMarker.show()
      lmbDown = false

    if isActionPressed("ui_right"):
      cancelClickMove()
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
      cancelClickMove()
      heldLeft = true
      velocity.x -= 1
      facingLeft = true

    if isActionPressed("ui_down"):
      cancelClickMove()
      if isActionPressed("ui_up"):
        if heldUp:
          velocity.y = 1
        else:
          velocity.y = -1
      else:
        heldUp = false
        velocity.y += 1
    elif isActionPressed("ui_up"):
      cancelClickMove()
      heldUp = true
      velocity.y -= 1

    velocity = lerp(prevVelocity, velocity.normalized() * playerSpeed, smooth_velocity_hardness * delta)
    prevVelocity = velocity

    var sprite = getNode("HeroSprite") as AnimatedSprite
    sprite.flipH = facingLeft
    if velocity.length > playerSpeed/10:
      sprite.play()
    else:
      sprite.stop()

    discard moveAndSlide(velocity)
    maybeTakeDamage()
    getNode("Camera2D").as(Camera2D).align()

    if length(clickPosition - position()) < 10:
      cancelClickMove()
    if getSlideCount() > 0:
      cancelClickMove()
