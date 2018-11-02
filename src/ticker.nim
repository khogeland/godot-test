import
  times,
  tables

type Ticker* = ref object
  last: float

proc initTicker*(): Ticker = Ticker(last: 0.0)

proc tick*(t: var Ticker, run: proc, intervalSec: float) =
  let currentTime = epochTime()
  if t.last + intervalSec < currentTime:
    t.last = currentTime
    run()
