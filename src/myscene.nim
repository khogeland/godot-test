import
  godot,
  engine,
  node

gdobj MyScene of Node:
  method ready*() = setProcess(true)
  method process*(delta: float64) =
    echo "hello"
