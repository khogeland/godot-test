import
  godot,
  speedcore,
  engine,
  kinematic_body_2d,
  hero,
  animated_sprite,
  sequtils,
  typetraits,
  material,
  ticker,
  hero,
  colors,
  viewport

gdobj Enemy of HasHealthKinematicBody2D:

  var outlineMaterial* {.gdExport, hint: ResourceType.}: Material = nil   
  var fireIntervalSec* {.gdExport.} = 1.0
  var damage* {.gdExport.}: int64 = 25
  var initialMaxHealth* {.gdExport.}: int64 = 25
  var bulletColor* {.gdExport.} = initColor(0.9, 0.1, 0.1)
  var shotSpeed* {.gdExport.} = 500.0

  var dead = false
  var shouldBeOutlined = false
  var isOutlined = false
  var heroNode: Hero = nil 

  var shooter = initTicker()

  proc outlineOn*() {.gdExport.} = shouldBeOutlined = true
  proc outlineOff*() {.gdExport.} = shouldBeOutlined = false

  proc getAllSprites(n: Node): seq[AnimatedSprite] =
    result = @[]
    for c in getChildren():
      try:
        var cSprite = c.asObject(AnimatedSprite)
        if cSprite != nil:
          result &= cSprite
      except ObjectConversionError:
        discard # "returns nil if conversion cannot be performed", my ass
      #var cNo = c.asObject(Node)
      #if cNo != nil and cNo.getChildCount > 0:
        #result &= getAllSprites(cNo)

  method onNoHealth() =
    var sprite = getNode("AnimatedSprite").as(AnimatedSprite)
    sprite.rotationDegrees = 180
    sprite.stop()
    dead = true

  method ready*() =
    discard connect("mouse_entered", self, "outline_on")
    discard connect("mouse_exited", self, "outline_off")
    heroNode = self.getNode("/root/Main/Hero").as(Hero)
    initHealthBar(initialMaxHealth)
    setProcess(true) 

  method process*(delta: float64) =
    if dead: return
    discard shooter.tick(
      proc() = self.shoot(heroNode.position + heroNode.getNode("CollisionShape2D").as(CollisionShape2D).position - self.position, damage, bulletColor, shotSpeed, LAYER_PLAYER, LAYER_MAP_BACKGROUND),
      fireIntervalSec) 
    var sprites = getAllSprites(self)
    for s in sprites:
      if shouldBeOutlined and not isOutlined:
        s.material = outlineMaterial
        isOutlined = true
      elif isOutlined and not shouldBeOutlined:
        s.material = nil
        isOutlined = false

