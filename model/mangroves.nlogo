extensions [gis]

breed [mangroves mangrove]

mangroves-own [diameter age alpha beta gamma omega dmax buffSalinity buffInundation buffCompetition species]

patches-own [fertility salinity inundation oldRC recruitmentChance whiteNoise occupied dist features bigPatch]

globals [deltaT gisDist gisFeatures trueSize resolution dynamicView years nextStorm stormOccurred stormKilled popBeforeStormNative popBeforeStormPlanted regenerationTimeNative regenerationTimePlanted avgRegTimeNative regTimeNativeCount avgRegTimePlanted regTimePlantedCount deaths avgLifespan]

;=>=>=>=>=>=>=><=<=<=<=<=<=<=
;      INITIALIZATION       ;
;=>=>=>=>=>=>=><=<=<=<=<=<=<=

to setup
  clear-all
  reset-ticks

  set years 0
  set deltaT 0.0
  if allow-storms = True [set nextStorm next-storm-schedule]
  set stormOccurred False
  set regenerationTimeNative 0
  set popBeforeStormNative 0
  set regenerationTimePlanted 0
  set popBeforeStormPlanted 0
  set avgRegTimeNative 0
  set regTimeNativeCount 0
  set avgRegTimePlanted 0
  set regTimePlantedCount 0
  set avgLifespan 0
  set deaths 0

  ; Setup map/world
  set trueSize 750 ; For Bani map
  set resolution trueSize / (max-pxcor + 1)

  setup-patches ; Setup patch values
  plant-mangroves ; Plant initial trees

  ; Some additional setup
  set-default-shape mangroves "circle"

  set dynamicView 0
end

;=>=>=>=>=>=>=><=<=<=<=<=<=<=
;         SIMULATION        ;
;=>=>=>=>=>=>=><=<=<=<=<=<=<=

to simulate
  ;if not any? mangroves [stop] ; If all mangroves are dead, stop
  if ticks >= max-days [
    final-report
    stop
  ] ; Stop if maximum desired steps has been reached
  set deltaT random-poisson 1 ; Get random time increment
  set years years + deltaT ; Update years
  set stormOccurred False
  set stormKilled 0
  ; Recolor patches if recruitment chance view is on
  if dynamicView = 1 [
    recolor-patches-by-recruitment
  ]
  if dynamicView = 2 [
    recolor-patches
    recolor-patches-by-mortality
  ]
  ; Check if regeneration is complete for both native & planted
  ifelse count mangroves with [species = "native" and diameter >= 5] < popBeforeStormNative [
    set regenerationTimeNative regenerationTimeNative + deltaT
  ][
    if popBeforeStormNative > 0 [
      print "Recovered :: Native"
      set avgRegTimeNative avgRegTimeNative + regenerationTimeNative
      set regTimeNativeCount regTimeNativeCount + 1
      set regenerationTimeNative 0
      set popBeforeStormNative 0
    ]
  ]
  ifelse count mangroves with [species = "planted" and diameter >= 5] < popBeforeStormPlanted [
    set regenerationTimePlanted regenerationTimePlanted + deltaT
  ][
    if popBeforeStormPlanted > 0 [
      print "Recovered :: Planted"
      set avgRegTimePlanted avgRegTimePlanted + regenerationTimePlanted
      set regTimePlantedCount regTimePlantedCount + 1
      set regenerationTimePlanted 0
      set popBeforeStormPlanted 0
    ]
  ]
  update-white-noise ; Update white noise term
  preserve-chances; Save old probabilities so calculation of new chances is uniform
  update-recruitment-chance ; Update recruitment chances for patches
  ; Grow each agent
  ask mangroves [grow]
  let target one-of patches with [fertility > 0 and recruitmentChance > 0 and occupied = False] ; Make mangrove babies
  if target != nobody [
    ask target [plant-baby]
  ]
  set target one-of mangroves
  if target != nobody [
    ask target [reap-soul] ; Kill some mangroves at random (from natural causes)
  ]
  ; If scheduled, make storm occur
  if allow-storms = True and years >= nextStorm [
    ;set popBeforeStormNative popBeforeStormNative + (count mangroves with [species = "native" and diameter >= 5])
    ;set popBeforeStormPlanted popBeforeStormPlanted + (count mangroves with [species = "planted" and diameter >= 5])
    ;set popBeforeStormNative (count mangroves with [species = "native" and diameter >= 5])
    ;set popBeforeStormPlanted (count mangroves with [species = "planted" and diameter >= 5])
    set popBeforeStormNative max list popBeforeStormNative (count mangroves with [species = "native" and diameter >= 5])
    set popBeforeStormPlanted max list popBeforeStormPlanted (count mangroves with [species = "planted" and diameter >= 5])
    storm
    set nextStorm next-storm-schedule
    set stormOccurred True
  ]
  tick
end

;=>=>=>=>=>=>=><=<=<=<=<=<=<=
;     UTILITY FUNCTIONS     ;
;=>=>=>=>=>=>=><=<=<=<=<=<=<=

to final-report
  ; >>>>>>>>>>> REPORT REGENERATION TIMES <<<<<<<<<<<<
  ; Add time from uncompleted regeneration
  print "=================================================="
  if regenerationTimeNative > 0 [
    print " <!> Native Tree Population is unrecovered for this long:"
    print regenerationTimeNative
    print " ____________________"
  ]
  if regenerationTimePlanted > 0 [
    print " <!> Planted Tree Population is unrecovered for this long: "
    print regenerationTimePlanted
    print " ____________________"
  ]
  if regTimeNativeCount > 0 [
    set avgRegTimeNative avgRegTimeNative / regTimeNativeCount
  ]
  if regTimePlantedCount > 0 [
    set avgRegTimePlanted avgRegTimePlanted / regTimePlantedCount
  ]
  print "Average Regeneration Time for Native Tree population: "
  ifelse avgRegTimeNative <= 0 [
    print "<<Infinity -- Never recovered>>"
  ][
    print avgRegTimeNative
  ]
  print "-----------------------------------------------------"
  print "Average Regeneration Time for Planted Tree population:"
  ifelse avgRegTimePlanted <= 0 [
    print "<<Infinity -- Never recovered>>"
  ][
    print avgRegTimePlanted
  ]
  print "-----------------------------------------------------"
  print "Average Tree Lifespan:"
  print avgLifespan / deaths
end

to setup-patches
  ; Set patch variables
  init-dist
  init-features
  recolor-patches
  ask patches [
    ; Assume shore-dist is 150
    set salinity min list (0.48 * (150 - dist)) 72
    set salinity (1 + e ^ ((salinity - 72) / 4)) ^ -1
    set inundation min list (0.00533 * (150 - dist)) 1
    set inundation 1 - inundation
    ifelse dist <= 0 or features = 1 [
      set fertility 0
    ][
      set fertility 1
    ]
    set recruitmentChance 0.0
    set oldRC 0.0
    set whiteNoise 0.0
    set occupied False
  ]
  init-big-patches
end

to init-big-patches
  ; first compute bigpatch once for each region's left bottom patch
  let patchGroup 0
  foreach n-values 5 [? * 10]
  [ let xx ?
    foreach n-values 5 [? * 10]
    [ let yy ?
      ask patch xx yy
      [ let bigSet patches with [pxcor >= xx and pxcor < xx + 10
                                   and pycor >= yy and pycor < yy + 10]
        ask bigSet [set bigPatch patchGroup]
        ;set patch-group patch-group ; + 1  ; incr region color
        ; now propogate big-set to whole region and color it
        ;set bigpatch big-set  set pcolor patch-group ]
        set patchGroup patchGroup + 1  ; incr region color
      ]
    ]
  ]
end


to init-dist
  ; Get GIS data for shoreline distances
  set gisDist gis:load-dataset gis-distances-filename
  gis:set-world-envelope-ds gis:envelope-of gisDist
  gis:apply-raster gisDist dist
  diffuse dist 0.9

  ask patches [set dist (dist * resolution) ^ 1.125]
end

to init-features
  ; Get GIS data for topographical features (elevation)
  set gisFeatures gis:load-dataset gis-features-filename
  gis:set-world-envelope-ds gis:envelope-of gisFeatures
  gis:apply-raster gisFeatures features
end

to plant-mangroves
  ; Plant mangroves
  create-mangroves initial-native-population [
    init-native True
    set diameter diameter + random 5
    if diameter >= 5 [
      ask patch-here [
        set recruitmentChance 0.5
      ]
    ]
    set size visible-size
    recolor-mangrove
  ]
  create-mangroves initial-planted-population [
    init-planted True
    ask patch-here [set recruitmentChance 0]
  ]
end

to init-native [move]
  set diameter 0.5
  set age 0.0
  set alpha 0.95 - range-offset + random-float (2 * (0.95 + range-offset))
  set beta 2.0 - range-offset + random-float (2 * (2.0 + range-offset))
  set gamma 1.0 - range-offset + random-float (2 * (1.0 + range-offset))
  set dmax 70
  set omega 3
  set buffSalinity 0.70
  set buffInundation 0.70
  set buffCompetition 1.00
  set species "native"
  set color green
  set shape "circle"
  set size visible-size
  let px 0
  let py 0
  if move = True [
    ;ask one-of patches with [fertility > 0 and occupied = False][
    ;  set px pxcor
    ;  set py pycor
    ;  set occupied True
    ;]
    ;setxy px py
    move-to-native-patch
  ]
end

to init-planted [move]
  set diameter 0.5
  set age 0.0
  set alpha 0.95 - range-offset + random-float (2 * (0.95 + range-offset))
  set beta 2.0 - range-offset + random-float (2 * (2.0 + range-offset))
  set gamma 1.0 - range-offset + random-float (2 * (1.0 + range-offset))
  set dmax 70
  set omega 5
  set buffSalinity 1.00
  set buffInundation 1.00
  set buffCompetition 1.00
  set species "planted"
  set color turquoise
  set shape "circle"
  set size visible-size
  let px 0
  let py 0
  if move = True [
    move-to-planted-patch
  ]
end

to update-white-noise
  ; Update white noise term for each patch
  ; B(0) = 0
  ; B(t) = B(t-1) + Norm(mean = 0, std deviation = deltaT)
  ask patches [
    set whiteNoise whiteNoise + random-normal 0 deltaT
  ]
end

to preserve-chances
  ask patches [
    set oldRC recruitmentChance
  ]
end

to update-recruitment-chance
  ; Update chance of recruitment for each patch
  ask patches [
    ; Implement Forced rules
    ; ______________________
    ; A. Assume plants cannot grow on boundaries
    if pxcor <= min-pxcor or fertility < 1 [
      set recruitmentChance 0
      stop ; End function here
    ]
    ; ______________________
    ; B. Recruitment chance is 1.0 where mature trees live
    ; >> Update this when trees grow
    ; ______________________
    ; C. Recruitment chance resets to 0 where trees have died
    ; >> Update this when a tree is killed
    ; Update other patches' recruitment chance
    let inv-corr -1 / correlation-time
    let diff-over-corr diffusion-rate * inv-corr
    set recruitmentChance recruitmentChance + deltaT * (inv-corr * recruitmentChance - diff-over-corr * (recruitment-chance-xx pxcor pycor) - diff-over-corr * (recruitment-chance-yy pxcor pycor) - inv-corr * whiteNoise )
    if recruitmentChance < 0 [
      set recruitmentChance 0
    ]
    if recruitmentChance > 1 [
      set recruitmentChance 1
    ]
  ]
end

to-report recruitment-chance-xx [x y]
  if pxcor <= min-pxcor or pxcor >= max-pxcor or pycor <= min-pycor or pycor >= max-pycor [
    report 0.0 ; Assume edge patches' recruitment chances are constant
  ]
  if count turtles-here > 0 [
    report 0.0 ; recruitment chance on occupied patches is constant
  ]
  ; Default option: report 2nd-order finite difference approximation
  let xnext x + 1
  let xprev x - 1
  report ((recruitment-chance-at xnext y ) - 2 * (recruitment-chance-at x y) + (recruitment-chance-at xprev y))
end

to-report recruitment-chance-yy [x y]
  if pxcor <= min-pxcor or pxcor >= max-pxcor or pycor <= min-pycor or pycor >= max-pycor [
    report 0.0 ; Assume edge patches' recruitment chances are constant
  ]
  if count turtles-here > 0 [
    report 0.0 ; recruitment chance on occupied patches is constant
  ]
  ; Default option: report 2nd-order finite difference approximation
  let ynext y + 1
  let yprev y - 1
  report ((recruitment-chance-at x ynext ) - 2 * (recruitment-chance-at x y) + (recruitment-chance-at x yprev))
end

to-report recruitment-chance-at [x y]
  let r 0.0
  ask patch x y [
    set r oldRC
  ]
  report r
end

to grow
  let growth diameter ^ (beta - alpha - 1)
  set growth growth * (omega / (2 + alpha))
  set growth growth * (1 - (1 / gamma) * (diameter / dmax) ^ (1 + alpha))
  set growth growth * salinity-response / buffSalinity
  set growth growth * inundation-response / buffInundation
  set growth growth * competition-response / buffCompetition
  set growth growth * deltaT
  set growth max list growth 0 ; Min growth is 0
  set diameter diameter + growth / 365.25
  if diameter > dmax [
    set diameter dmax
  ]
  if diameter <= 0 [
    ask patch-here [
      kill-tree-here
    ]
    stop
  ]
  set age age + deltaT
  set size visible-size ; Redraw tree based on its new size
  ; Update recruitment chance at this patch
  ifelse diameter >= 5 [ ; Mature tree here
    ifelse species = "native" [
      ask patch-here [
        set recruitmentChance 0.5
      ]
    ][
      ask patch-here [
        set recruitmentChance 0.5
      ]
    ]
  ]
  [ ; Underage tree here
    set recruitmentChance 0.0
  ]
  recolor-mangrove
end

to-report salinity-response
  let s 0.0
  ask patch-here [
    set s salinity
  ]
  report s
end

to kill-tree-here
  ask turtles-here [
    if diameter >= 5 [
      set deaths deaths + 1
      set avgLifespan avgLifespan + age
    ]
    die
  ]
  set occupied False
  set recruitmentChance 0
end

to-report inundation-response
  let i 0.0
  ask patch-here [
    set i inundation
  ]
 report i
end

to-report competition-response
  let compTotal 1
  ask turtles-here [
    let comp-here e ^ (-0.1 * diameter / 2)
    set compTotal compTotal * comp-here
  ]
  ask neighbors [
    ask mangroves-at pxcor pycor [
      let comp-here e ^ (-0.1 * diameter / 2)
      set compTotal compTotal * comp-here
    ]
  ]
  report compTotal
end

to-report chance-of-dying
  ; Determine chance of a plant dying based on species and diameter
  let x diameter
  let p 1
  ifelse species = "native" [
    set p 0.2 * (((x - 2.5) * (x - 5.0))/((0.5 - 2.5) * (0.5 - 5.0)))
    set p p + 0.1 * (((x - 0.5) * (x - 5))/((2.5 - 0.5) * (2.5 - 5.0)))
    set p p + 0.083 * (((x - 0.5) * (x - 2.5))/((5.0 - 0.5) * (5.0 - 2.5)))
    if x >= 5 [
      set p 0.083
    ]
  ][
    set p 0.24 * (((x - 2.5) * (x - 5.0))/((0.5 - 2.5) * (0.5 - 5.0)))
    set p p + 0.12 * (((x - 0.5) * (x - 5))/((2.5 - 0.5) * (2.5 - 5.0)))
    set p p + 0.1 * (((x - 0.5) * (x - 2.5))/((5.0 - 0.5) * (5.0 - 2.5)))
    if x >= 5 [
      set p 0.1
    ]
  ]
  report p
end

to reap-soul
  ; Randomly kill a plant
  let roll random-float 1.0
  let probOfDeath chance-of-dying
  if roll <= probOfDeath [
    ask patch-here [
      kill-tree-here
    ]
  ]
end

to plant-baby
  ; Make sure patch is fertile and not occupied
  if fertility < 1 or count mangroves-here > 0 [
    stop
  ]
  let roll random-float 1
  ; Plant  new mangrove based on recruitmentChance
  if roll < recruitmentChance or recruitmentChance >= 1.0 [
    let parent min-one-of mangroves with [diameter >= 5] [distance myself]
    if parent = nobody [
      set parent one-of mangroves with [species = "planted"]
    ]
    ifelse parent != nobody [
      sprout-mangroves 1 [
        let spec "native"
        ask parent [
          set spec species
        ]
        ifelse spec = "native" [
          init-native False
        ][
        init-planted False
        ]
        setxy pxcor pycor
        inherit parent
      ]
    ][
       print "No nearby parent found"
    ]
    set occupied True
  ]
end

to inherit [parent]
  ; Get chars of parent
  let a 0
  let b 0
  let c 0
  let z 0
  ask parent [
    set a alpha
    set b beta
    set c gamma
    set z omega
  ]
  set alpha a
  set beta b
  set gamma c
  set omega z
end


to storm

  set stormKilled 0

  ask mangroves [
    let numNeighbors count mangroves in-radius 1 with [diameter >= [diameter] of myself] ; Get number of neighbors
    let stormVulnerability 0.0
    ifelse diameter >= 5 [
      set stormVulnerability 0.7 - (numNeighbors * tree-protect)
    ][
      set stormVulnerability 0.1 - (numNeighbors * tree-protect)
    ]
    if random-float 1.0 <= stormVulnerability [
      ask patch-here [
        kill-tree-here
        set stormKilled stormKilled + 1
      ]
      ask patches in-radius 30 [
        kill-tree-here
        set stormKilled stormKilled + 1
      ]
    ]
  ]
  let blockDisturb1 random 25
  let blockDisturb2 random 25
  let blockDisturb3 random 25
  print "Block Disturb"
  print blockDisturb1
  print blockDisturb2
  print blockDisturb3
  ask patches with [bigPatch = blockDisturb1 or bigPatch = blockDisturb2 or bigPatch = blockDisturb3] [
    if random-float 1.0 <= 0.9 [
      kill-tree-here
      set stormKilled stormKilled + 1
    ]
  ]
end

to-report planted-patches
  report patches with [ features = 2 and fertility > 0 and occupied = False ]
end

to-report native-patches
  report patches with [ features = 3 and fertility > 0 and occupied = False ]
end

to-report crown-radius
  report 11.1 * diameter ^ 0.65
end

to move-to-native-patch
  let x-tmp 0
  let y-tmp 0
  ask one-of native-patches [
    set x-tmp pxcor
    set y-tmp pycor
  ]
  setxy x-tmp y-tmp
end

to move-to-planted-patch
  let x-tmp 0
  let y-tmp 0
  ask one-of planted-patches [
    set x-tmp pxcor
    set y-tmp pycor
  ]
  setxy x-tmp y-tmp
end

to-report visible-size
  ; Get size to draw trees as
  report (crown-radius / resolution) / 25 * mangrove-display-scale
end

to-report next-storm-schedule
  ; Get next storm schedule (in simulated years)
  report years + random-exponential storm-beta
end

to recolor-mangrove
  ; Recolor a mangrove based on its age
  let tree-color green
  if species = "planted" [
    set tree-color turquoise
  ]
  ifelse diameter < 2.5 [
    set color tree-color + 1.5
  ][
    ifelse diameter < 5.0 [
      set color tree-color
    ][
      set color tree-color - 2.5
    ]
  ]
end

; Color terrain

to recolor-patches
  ask patches [
    ifelse dist > 0 [
      ifelse features = 1 [
        set pcolor gray - 2
      ] [
        set pcolor scale-color brown dist 240 -140
      ]
    ] [
      set pcolor blue - 2
    ]
  ]
end

; Color patches based on salinity

to recolor-patches-by-salinity
  ask patches [
    set pcolor scale-color magenta (salinity * 200) -250 550
  ]
  set dynamicView 0
end


; Color patches based on salinity

to recolor-patches-by-inundation
  ask patches [
    set pcolor scale-color sky (inundation * 200) -250 550
  ]
  set dynamicView 0
end

; Color patches based on recruitment chance

to recolor-patches-by-recruitment
  ask patches [
    ifelse recruitmentChance >= 1 [
      set pcolor cyan
    ][
      set pcolor scale-color red (recruitmentChance * 200) -250 250
    ]
  ]
  set dynamicView 1
end

; Color patches based on local region/bigPatch

to recolor-big-patches
  ask patches [
    set pcolor scale-color violet (bigPatch * 10) 500 -500
  ]
  set dynamicView 0
end

; Color patches based on chance of dying

to recolor-patches-by-mortality
  ask patches with [count turtles-here > 0][
    let mort 0
    ask one-of mangroves-here [
      set mort chance-of-dying
    ]
    set pcolor scale-color turquoise (mort * 500) 250 -250
    if mort <= 0.08 [
      set pcolor blue
    ]
  ]
  set dynamicView 2
end
@#$#@#$#@
GRAPHICS-WINDOW
10
15
486
512
-1
-1
9.32
1
12
1
1
1
0
0
0
1
0
49
0
49
1
1
1
steps
60.0

INPUTBOX
502
24
657
84
initial-native-population
300
1
0
Number

INPUTBOX
502
174
657
234
range-offset
0.25
1
0
Number

BUTTON
503
257
567
290
Reset
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
592
256
655
289
Go
simulate
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
682
23
837
83
max-days
10000
1
0
Number

INPUTBOX
683
99
838
159
correlation-time
1
1
0
Number

INPUTBOX
683
174
839
234
diffusion-rate
0.5
1
0
Number

SLIDER
1022
470
1177
503
mangrove-display-scale
mangrove-display-scale
1
20
6
1
1
NIL
HORIZONTAL

BUTTON
506
320
606
353
Terrain View
recolor-patches\nset dynamicView 0
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
621
319
721
352
Salinity View
recolor-patches-by-salinity
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
740
318
860
351
Inundation View
recolor-patches-by-inundation
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
504
370
639
403
Recruitment Chance View
recolor-patches-by-recruitment
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
870
17
1014
82
Days Simulated
years
2
1
16

PLOT
872
93
1322
461
Population
Days
Mangroves
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Natives" 1.0 0 -12087248 true "" "plot count mangroves with [species = \"native\"]"
"Storms" 1.0 2 -2674135 true "" "if stormOccurred = True [\n    plot-pen-up\n    plot-pen-down\n    plotxy ticks plot-y-max\n  ]"
"Planteds" 1.0 0 -14730904 true "" "plot count mangroves with [species = \"planted\"]"

SLIDER
870
470
1010
503
tree-protect
tree-protect
0
0.2
0.13
0.005
1
NIL
HORIZONTAL

INPUTBOX
683
247
838
307
storm-beta
150
1
0
Number

MONITOR
1024
18
1180
63
Next Storm Scheduled at
nextStorm
2
1
11

BUTTON
649
370
739
403
Big Patch View
recolor-big-patches
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
752
370
852
403
Mortality View
recolor-patches-by-mortality
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
504
99
659
159
initial-planted-population
600
1
0
Number

PLOT
13
528
720
911
Population by Maturity
Time
Mangroves
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Native Seedlings" 1.0 1 -8732573 true "" "plot count mangroves with [species = \"native\" and diameter < 2.5]"
"Native Saplings" 1.0 1 -12087248 true "" "plot count mangroves with [species = \"native\" and diameter >= 2.5 and diameter < 5.0]"
"Native Trees" 1.0 1 -14333415 true "" "plot count mangroves with [species = \"native\" and diameter >= 5.0]"
"Planted Seedlings" 1.0 1 -11033397 true "" "plot count mangroves with [species = \"planted\" and diameter < 2.5]"
"Planted Saplings" 1.0 1 -14454117 true "" "plot count mangroves with [species = \"planted\" and diameter >= 2.5 and diameter < 5]"
"Planted Trees" 1.0 1 -15582384 true "" "plot count mangroves with [species = \"planted\" and diameter > 5.0]"
"Storm" 1.0 1 -2674135 true "" "if stormOccurred = True [\n    plot-pen-up\n    plot-pen-down\n    plotxy ticks plot-y-max\n  ]"

PLOT
732
525
1321
754
Average Tree DBH
Time
Ave. Diameter
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"avgTreeDiameter" 10.0 1 -955883 true "" "let s 0\nask mangroves with [diameter >= 5] [\n    set s s + diameter\n]\nlet n count mangroves with [diameter >= 5]\nifelse n > 0 [\n  let a s / n\n  plot a\n][\n  plot 0\n]"

PLOT
732
760
1318
910
Average Tree Age
Time
Age
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"age" 10.0 1 -10022847 true "" "let s 0\nask mangroves with [diameter >= 5] [\n    set s s + age\n]\nlet n count mangroves with [diameter >= 5]\nifelse n > 0 [\n  let a s / n\n  plot a\n][\n  plot 0\n]"

PLOT
15
922
822
1136
Regeneration Time
Time
Regeneration Time
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Native Trees" 1.0 0 -14439633 true "" "plot regenerationTimeNative"
"Storm" 1.0 1 -2674135 true "" "if stormOccurred = True [\n    plot-pen-up\n    plot-pen-down\n    plotxy ticks plot-y-max\n  ]"
"Planted Trees" 1.0 0 -13403783 true "" "plot regenerationTimePlanted"

INPUTBOX
505
424
658
484
gis-features-filename
bani_features.asc
1
0
String

INPUTBOX
685
425
860
485
gis-distances-filename
bani_distance.asc
1
0
String

MONITOR
20
446
108
503
Population
count mangroves
0
1
14

PLOT
827
922
1319
1135
Killed by Storm
Time
Storm Victims
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Victims" 1.0 0 -16777216 true "" "plot stormKilled"
"Storm" 1.0 2 -5298144 true "" "if stormOccurred = True [\n    plot-pen-up\n    plot-pen-down\n    plotxy ticks plot-y-max\n  ]"

MONITOR
116
463
179
504
Native Pop
count mangroves with [species = \"native\"]
0
1
10

MONITOR
183
463
248
504
Planted Pop
count mangroves with [species = \"planted\"]
0
1
10

SWITCH
1192
19
1312
52
allow-storms
allow-storms
0
1
-1000

@#$#@#$#@
# Mangroves Thesis

Please read to wiki at https://github.com/vincentfiestada/mangroves_thesis/wiki for instructions about how to use the software and more information.

This is an agent-based model for the regrowth of multi-species mangrove forests in fragmented habitats by Vincent Paul Fiestada and Andrew Vince Lorbis, undergrad students at the University of the Philippines Diliman Department of Computer Science.

## Model Re-write Status

The model is being re-written, using code from the previous version as well as new features such as using colored noise for population spread.

**CURRENT VERSION:** Single species, small genetic "island" map, land gets more elevated farther from the shore, storms are Poisson events

## Mangrove Variables

- diameter: The diameter of the mangrove at breast height; also determines maturity

## Patch Variables

- fertility: Growth multiplier for the occupant of this patch; if 0, plants cannot grow on the patch (e.g. sea, rock, etc.)
- salinity: Salinity effect on this patch
- inundation: Tidal inundation effect on this patch
- recruitmentChance: Probability (0-1) that this patch will grow a new seedling
- whiteNoise: Current white noise term for recruitmentChance of this patch
- bigPatch: Identifies a local group/region that the patch belongs to. Used in block disturbance.

## Global Variables

- nextStorm: schedule for when the next storm hits. It is calculated as a sample from an Exponential distribution (since storms are assumed to Poisson events)

## Units

Diameters, radii, etc. are measured in centimeters (cm) and time is measured in days
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
