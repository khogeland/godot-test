import
  godot,
  engine,
  kinematic_body_2d,
  animated_sprite,
  sequtils,
  typetraits,
  material,
  viewport

gdobj Enemy of KinematicBody2D:

  var outlineMaterial* {.gdExport, hint: ResourceType.}: Material = nil   

  var shouldBeOutlined = false
  var isOutlined = false

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

  method ready*() =
    discard connect("mouse_entered", self, "outline_on")
    discard connect("mouse_exited", self, "outline_off")
    setProcess(true) 

  method process*(delta: float64) =
    var sprites = getAllSprites(self)
    for s in sprites:
      if shouldBeOutlined and not isOutlined:
        s.material = outlineMaterial
        isOutlined = true
      elif isOutlined and not shouldBeOutlined:
        s.material = nil
        isOutlined = false

