import
  godot,
  engine,
  animated_sprite

gdobj HeroSprite of AnimatedSprite:

  proc onFrameChanged*() {.gdExport.} =
    discard
    #echo self.frame()
    #if self.frame == 0:
      #self.flip_h = not self.flip_h
      #if self.flip_h:
        #self.flip_v = not self.flip_v

  method ready*() = 
    discard self.connect("frame_changed", self, "on_frame_changed", newArray())
    setProcess(true)

  method process*(delta: float64) = discard

