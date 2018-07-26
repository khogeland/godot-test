# Copyright 2017 Xored Software, Inc.

import strutils
import godot
import engine, label

gdobj SomeLabel of Label:
  method ready*() =
    setProcess(true)

  method process*(delta: float64) =
    self.text = $delta
