;; ROMAN RELIGION MODEL -- a learning model for NetLogo 6.4.0
;; Each turtle represents one family, not one person.
;; Parameters are globals supplied by the Interface sliders.
;; All probabilities use 0 to 1: for example, 0.05 means 5%.

breed [christians christian]
breed [heathens heathen]

turtles-own [
  remaining-life       ;; ticks remaining; starts at 10
]

globals [
  conversions-this-tick
  births-this-tick
  deaths-this-tick
]

to setup
  clear-all
  set-default-shape turtles "circle"
  ask patches [ set pcolor white ]

  create-heathens initial-heathens [
    initialize-family
    set color gray
  ]
  create-christians initial-christians [
    initialize-family
    set color blue
  ]

  reset-ticks
end

to initialize-family  ;; turtle procedure
  set remaining-life 10
  set size 1
  setxy random-xcor random-ycor
end

to go
  if not any? turtles [ stop ]

  set conversions-this-tick 0
  set births-this-tick 0
  set deaths-this-tick 0

  ;; Fixed snapshots: newborns and new converts cannot join these sets.
  let starting-families turtles with [true]
  let starting-christians christians with [true]

  ;; Stage 1: only Christians present at the START attempt conversions.
  ask starting-christians [ convert-heathens ]

  ;; Stage 2: existing families reproduce using their CURRENT religion.
  ;; A new convert can therefore produce a Christian family this tick.
  ask starting-families [ reproduce-family ]

  ;; Stage 3: cost, benefit, normal aging, and death.
  ;; Newborns are absent from starting-families, so they keep all 10 ticks.
  ask starting-families [ age-family ]

  ;; Advances the clock and updates the Interface plots.
  tick
end

to convert-heathens  ;; Christian turtle procedure
  ;; Select distinct targets for this Christian's turn.
  ;; There may be fewer Heathens left than the requested social-impact.
  let contact-count min (list social-impact count heathens)
  let contacts n-of contact-count heathens

  ask contacts [
    if random-float 1 < conversion-power [
      set breed christians
      set color blue
      ;; Conversion does NOT reset remaining-life.
      set conversions-this-tick conversions-this-tick + 1
    ]
  ]
end

to reproduce-family  ;; turtle procedure
  let reproduction-probability heathen-reproduction
  if breed = christians [
    set reproduction-probability christian-reproduction
  ]

  if random-float 1 < reproduction-probability [
    ;; hatch inherits the parent's breed and color.
    ;; Reset the child's lifetime and give it a display position.
    hatch 1 [ initialize-family ]
    set births-this-tick births-this-tick + 1
  ]
end

to age-family  ;; turtle procedure
  ;; Independent trials: both may happen and cancel each other.
  if breed = christians [
    if random-float 1 < social-cost [
      set remaining-life remaining-life - 1
    ]
    if random-float 1 < social-benefit [
      set remaining-life remaining-life + 1
    ]
  ]

  set remaining-life remaining-life - 1
  if remaining-life <= 0 [
    set deaths-this-tick deaths-this-tick + 1
    die
  ]
end

to-report christian-percent
  if not any? turtles [ report 0 ]
  report 100 * count christians / count turtles
end
@#$#@#$#@
TEXTBOX
15
10
1095
40
ROMAN RELIGION | A family-based learning model
20
0
0

TEXTBOX
15
47
815
72
Blue: Christian families    Gray: Heathen families    Positions are display only.
12
0
0

TEXTBOX
15
80
275
100
INITIAL POPULATION
12
0
0

SLIDER
15
105
275
138
initial-heathens
initial-heathens
0
5000
1000
1
1
NIL
HORIZONTAL

SLIDER
15
145
275
178
initial-christians
initial-christians
0
1000
5
1
1
NIL
HORIZONTAL

TEXTBOX
15
187
275
207
CONVERSION
12
0
0

SLIDER
15
212
275
245
conversion-power
conversion-power
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
15
252
275
285
social-impact
social-impact
0
10
3
1
1
NIL
HORIZONTAL

TEXTBOX
15
294
275
314
CHRISTIAN LIFESPAN EFFECTS
12
0
0

SLIDER
15
319
275
352
social-cost
social-cost
0
1
0
0.01
1
NIL
HORIZONTAL

SLIDER
15
359
275
392
social-benefit
social-benefit
0
1
0
0.01
1
NIL
HORIZONTAL

TEXTBOX
15
401
275
421
REPRODUCTION PER TICK
12
0
0

SLIDER
15
426
275
459
christian-reproduction
christian-reproduction
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
15
466
275
499
heathen-reproduction
heathen-reproduction
0
1
0.1
0.01
1
NIL
HORIZONTAL

BUTTON
15
515
90
548
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
97
515
167
548
Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
174
515
275
548
Go / Pause
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
15
562
275
619
Probabilities: 0.05 = 5%.\nEvery family starts with 10 ticks.\nSee Info for the exact tick rules.
12
0
0

GRAPHICS-WINDOW
295
80
791
417
-1
-1
8.0
1
14
1
1
1
0
1
1
1
-30
30
-20
20
1
1
1
ticks
30.0

MONITOR
295
430
405
475
Christians
count christians
0
1
11

MONITOR
415
430
525
475
Heathens
count heathens
0
1
11

MONITOR
535
430
645
475
Total families
count turtles
0
1
11

MONITOR
655
430
791
475
Christian share (%)
christian-percent
2
1
11

MONITOR
295
489
451
534
Conversions this tick
conversions-this-tick
0
1
11

MONITOR
461
489
617
534
Births this tick
births-this-tick
0
1
11

MONITOR
627
489
791
534
Deaths this tick
deaths-this-tick
0
1
11

TEXTBOX
295
554
791
619
Tick order: conversion, reproduction, lifespan changes.\nNewborns first act next tick. New converts first convert next tick.\nConversion keeps the existing family and its remaining lifetime.
12
0
0

PLOT
810
80
1160
340
Family populations
Ticks
Families
0.0
50.0
0.0
1000.0
true
true
"" ""
PENS
"Christians" 1.0 0 -13345367 true "" "plot count christians"
"Heathens" 1.0 0 -7500403 true "" "plot count heathens"

PLOT
810
355
1160
615
Christian share
Ticks
Percent
0.0
50.0
0.0
100.0
true
false
"" ""
PENS
"Christian %" 1.0 0 -13345367 true "" "plot christian-percent"
@#$#@#$#@
## WHAT IS IT?

A deliberately simple learning model of Christian conversion and family reproduction in the Roman Empire. It implements Michael's proposed rules. It is not calibrated to historical evidence, and a tick is an abstract time step, not a specified number of years.

Each turtle represents one family. Its breed is either `christians` or `heathens`, using the requested labels. These categories are abstractions for this exercise. Christian families are blue; Heathen families are gray. Positions are for display only: contacts are chosen across the whole population, regardless of distance. There is no movement, geography, reverse conversion, migration, or population limit.

## HOW TO USE IT

1. Open this file in NetLogo 6.4.0 using File > Open.
2. Adjust the sliders, then click **Setup**.
3. Click **Step** to advance one tick, or **Go / Pause** to run continuously. Click Go / Pause again to pause.
4. View the population and Christian-share plots. Use the Code tab to inspect or edit the implementation.

Setup clears the previous run. Initial-population sliders take effect on the next Setup. Other sliders affect subsequent ticks immediately. Go stops automatically when the entire population is extinct. It keeps running if one religion disappears, because the remaining families still reproduce and die.

## PARAMETERS

All probabilities range from 0 to 1. For example, `0.05` means 5%, not 0.05%. Social Impact is an integer from 0 to 10.

| Requested quantity | Interface / code variable | Starting value |
| --- | --- | --- |
| H: initial Heathens | `initial-heathens` | 1000 |
| C: initial Christians | `initial-christians` | 5 |
| CP: Conversion Power per encounter | `conversion-power` | 0.05 |
| SI: Social Impact, contacts per Christian per tick | `social-impact` | 3 |
| SC: Social Cost per Christian per tick | `social-cost` | 0 |
| SB: Social Benefit per Christian per tick | `social-benefit` | 0 |
| Christian Reproductive Success per tick | `christian-reproduction` | 0.10 |
| Heathen Reproductive Success per tick | `heathen-reproduction` | 0.10 |

The requested definition used SC for both cost and benefit; this model distinguishes SC and SB. Starting values are illustrative settings, not historical estimates. The initial-population slider limits are Interface conveniences, not population caps.

## EXACT ORDER WITHIN A TICK

**1. Remember the starting population.** Fixed snapshots record the families and Christians present at the start of the tick.

**2. Attempt conversions.** Each starting Christian, in random order, chooses up to SI distinct families from the Heathens currently remaining. Each contact independently converts with probability CP. If fewer than SI Heathens remain, the Christian contacts all of them. A Heathen that resists one Christian may be contacted by another in the same tick. A successful conversion immediately changes the family's breed and color, but leaves its remaining lifetime unchanged. New converts first attempt conversions in the NEXT tick.

**3. Reproduce.** Each starting family has one trial, using its religion AFTER conversion. Success produces exactly one new family of the same religion. A newborn receives 10 ticks of remaining life; it does not convert, reproduce, experience cost/benefit, or age until the next tick. A new convert may produce a Christian offspring in this tick.

**4. Apply lifespan changes and deaths.** Every starting Christian, including new converts, independently faces a cost trial and a benefit trial. A cost event subtracts 1 from remaining life; a benefit event adds 1. Every starting family then loses 1 tick to ordinary aging. Families with zero or less remaining life die. Both social effects are applied before checking death, so they can cancel. Families can act and reproduce during their final tick.

**5. Advance the clock and update plots.** The event monitors report conversions, births, and deaths during the completed tick. Christian share reports zero when the entire population is extinct; use the Total monitor to distinguish this from an all-Heathen population.

## LIFETIME CONSEQUENCES

Each initial and newborn family starts with exactly 10 ticks of remaining life. Without social effects, a family therefore gets exactly 10 ticks in which to act. All initial families start at the same age, so synchronized deaths at tick 10 are an expected artifact of this first version.

For a Christian family:

    new remaining life = old remaining life - 1 - cost event + benefit event

Cost and benefit events are each 0 or 1. Thus, with SB = 1 and SC = 0, normal aging is canceled on every tick and Christians never die under these rules. With SC = 1 and SB = 0, they lose two ticks of remaining life each tick and die after five ticks. With both probabilities at 1, the effects cancel and lifetime is 10 ticks.

Without conversion or social effects, a reproduction probability of 0.10 gives one expected offspring over a family's 10-tick lifetime. This is an expected replacement level, not a guarantee of a constant population; a small population can still go extinct. High reproduction probabilities can produce rapid growth because this version has no resource or population limit.

## THINGS TO TRY

* Set CP, SC, SB, and both reproduction probabilities to zero. After Setup, all initial families should survive nine ticks and die at the end of tick 10.
* Set H = 10, C = 1, CP = 1, SI = 1, and both reproduction probabilities, SC, and SB to zero. There should be two Christians after the first tick and four after the second, demonstrating that converts wait until the next tick to convert others.
* Start with the supplied defaults. Change only CP or SI between runs and watch both the absolute counts and the Christian share.
* Turn conversion off and vary the reproductive probabilities to separate reproduction from conversion.
* Compare equal cost and benefit probabilities with both zero. Equal probabilities balance the expected change, but independent trials still vary individual lifetimes.
* Repeat a setting several times: each run uses random draws. For a repeatable run, enter `random-seed 42 setup` in the Observer Command Center, then use Step or Go. Use the same seed and settings to reproduce the run.

## NETLOGO CONCEPTS IN THE CODE

`breed` defines the two family categories. `set breed christians` converts a family. `hatch 1` creates a new family and inherits the parent's breed and color; `initialize-family` resets its remaining life. `random-float 1 < probability` implements a probability trial. `n-of` selects distinct random contacts. The `with [true]` expressions create fixed starting sets so later births and conversions cannot expand those sets during the tick.

The sliders define parameter globals automatically. Do not declare those variables again in `globals` while the sliders exist. The additional `globals` in the Code tab are event counters.

Official NetLogo 6.4.0 references:

* [NetLogo Dictionary](https://ccl.northwestern.edu/netlogo/6.4.0/docs/dictionary.html)
* [Programming Guide](https://ccl.northwestern.edu/netlogo/6.4.0/docs/programming.html)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
setup
repeat 20 [ go ]
@#$#@#$#@

@#$#@#$#@
<experiments>
</experiments>
@#$#@#$#@

@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

