extensions [ gis matrix csv ]
globals [ gis-dist gis-features natural-color planted-color true-size resolution dist-threshold storm-return]

breed [ naturals natural ]
breed [ planteds planted ]

turtles-own [ dbh planted-neighbors naturals-neighbors num-neighbors ]

patches-own [ val owned dist features bigpatch ]

; ----------------------------------------
; INITIALIZATION
; ----------------------------------------

to setup
  ca
  reset-ticks

  set true-size 750
  set resolution true-size / (max-pxcor + 1)
  set storm-return random 25

  initialize-dist
  initialize-features
  recolor-patches

  initialize-naturals
  initialize-planteds
  natural-recolor
  planted-recolor
  refresh-turtles

  load-matrix
  ;print matrix "test.txt" 3 3
  ;let m matrix:from-row-list [[1 2 3] [4 5 6]]
  ;print m


end

To-report matrix [ filename rows cols ]
   File-open filename
   Let results n-values rows
      [ n-values cols
         [ file-read ]
      ]
   File-close
   Report results
End

to load-matrix
;  let m matrix:from-row-list
;[[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
;[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]]
;matrix:set m 1 2 10


;ask patches [ set val m pxcor pycor ]
;let matrixval (csv:from-file "filename.csv" " ") ; `but-first` since we don't care about that first line

;ask patches [
;  let row max-pycor - pycor
;  let column pxcor - min-pxcor
;  set val item column item row matrixval
;]

print count turtles
print count naturals with [ dbh < 2.5 ]
print count naturals with [ dbh > 5 ]

;ask turtles [
;set my-neighbors (other neighbors) in-radius dbh
;set num-neighbors count my-neighbors
;print num-neighbors
;]
  let big-color blue - 4
  ; first compute bigpatch once for each region's left bottom patch
  foreach n-values 5 [? * 10]
  [ let xx ?
    foreach n-values 5 [? * 10]
    [ let yy ?
      ask patch xx yy
      [ let big-set patches with [pxcor >= xx and pxcor < xx + 100
                                   and pycor >= yy and pycor < yy + 100]
        set big-color big-color + .25  ; incr region color
        ; now propogate big-set to whole region and color it
        ask big-set [ set bigpatch big-set  set pcolor big-color ]
      ]
      tick  ; to show progress
    ]
  ]

end

to-report crown
  report 11 * dbh ^ 0.65
end

to-report visible-size
  report (crown / resolution) / 25 * mangrove-display-scale
end


to initialize-dist
  set gis-dist gis:load-dataset "bani_distance.asc"
  gis:set-world-envelope-ds gis:envelope-of gis-dist
  gis:apply-raster gis-dist dist


  diffuse dist 0.875

  ask patches [ set dist (dist * resolution) ^ 1.125 ]

  set dist-threshold resolution / 2

end

to initialize-features
  set gis-features gis:load-dataset "bani_features.asc"
  gis:set-world-envelope-ds gis:envelope-of gis-features
  gis:apply-raster gis-features features
end

to recolor-patches
  ask patches [
    ifelse dist > dist-threshold [
      ifelse features = 1 [
        set pcolor gray
      ] [
        set pcolor scale-color orange dist 240 -140
      ]
    ] [
      set pcolor blue
    ]
  ]
end

to refresh-turtles
  ask turtles [ set size visible-size ]
end

; AGENT CLASSIFICATION

to-report planted-trees
  report planteds with [ dbh >= 5.0 ]
end

to-report planted-saplings
  report planteds with [ dbh < 5.0 and dbh >= 2.5 ]
end

to-report planted-seedlings
  report planteds with [ dbh < 2.5 ]
end

to-report natural-trees
  report naturals with [ dbh >= 5.0 ]
end

to-report natural-saplings
  report naturals with [ dbh < 5.0 and dbh >= 2.5 ]
end

to-report natural-seedlings
  report naturals with [ dbh < 2.5 ]
end

; PATCH CLASSIFICATION

to-report habitable-patches
  report patches with [ features != 1 and dist > dist-threshold ]
end

to-report habitable-patches-in-radius [ radius ]
  report patches in-radius radius with [ features != 1 and dist > dist-threshold ]
end

to-report habitable-neighbors
  report neighbors with [ features != 1 and dist > dist-threshold ]
end

to-report planted-patches
  report patches with [ features = 2 ]
end

to-report natural-patches
  report patches with [ features = 3 ]
end

; NATURAL MANGROVES

to move-to-natural-patch
  let x-tmp 0
  let y-tmp 0
  ask one-of natural-patches [
    set x-tmp pxcor
    set y-tmp pycor
  ]
  setxy x-tmp y-tmp
end

to initialize-naturals
  set-default-shape naturals "circle"
  set natural-color green


end

to initialize-natural
  set dbh 0.5
  set size visible-size
end

; PLANTED MANGROVES

to move-to-planted-patch
  let x-tmp 0
  let y-tmp 0
  ask one-of planted-patches [
    set x-tmp pxcor
    set y-tmp pycor
  ]
  setxy x-tmp y-tmp
end

to initialize-planteds
  set-default-shape planteds "circle"
  set planted-color cyan

  if planted-species = "Rhizophora" [
    create-planteds planted-density [
      initialize-planted
      move-to-planted-patch
    ]
  ]

  if planted-species = "native" [
    create-naturals planted-density [
      initialize-natural
      move-to-planted-patch
    ]
  ]

  if planted-species = "both" [
    create-planteds ( planted-density / 2 ) [
      initialize-planted
      move-to-planted-patch
    ]

    create-naturals ( planted-density / 2 ) [
      initialize-natural
      move-to-planted-patch
    ]
  ]

end

to initialize-planted
  set dbh 0.5
  set size visible-size
end

; ----------------------------------------
; RUN
; ----------------------------------------

to go
  if not any? turtles [ stop ]

  if ticks >= 100 and limit-years [ stop ]

  print "aaaaaaaaaaaaaaaa"
  print count planteds + count naturals
  print "zzzzzzzzzzzzzzzz"

  natural-recolor
  planted-recolor

  ask naturals [ natural-grow ]
  ask planteds [ planted-grow ]

  ask naturals with [ dbh >= 5.0 ] [ natural-recruit ]
  ask planteds with [ dbh >= 5.0 ] [ planted-recruit ]

  ask naturals [ natural-die ]
  ask planteds [ planted-die ]

  if storms = true [
    ifelse storm-return = 0 [
      storm
      set storm-return random-poisson 22.5
    ] [
      set storm-return storm-return - 1
    ]
  ]

  tick
end

; recolor mangroves

to natural-recolor
  ask naturals with [ dbh < 2.5 ] [ set color natural-color + 2 ]
  ask naturals with [ dbh < 5.0 and dbh >= 2.5 ] [set color natural-color ]
  ask naturals with [ dbh >= 5.0 ] [set color natural-color - 2]
end

to planted-recolor
  ask planteds with [ dbh < 2.5 ] [ set color planted-color + 2 ]
  ask planteds with [ dbh < 5.0 and dbh >= 2.5 ] [set color planted-color ]
  ask planteds with [ dbh >= 5.0 ] [set color planted-color - 2]
end

; growth

to natural-grow
  set dbh dbh + natural-dbh-change
  set size visible-size
end

to planted-grow
  set dbh dbh + planted-dbh-change
  set size visible-size
end

; recruitment

to natural-recruit

  if random-float 1.0 * 10 < natural-birth [
    let parent-x pxcor
    let parent-y pycor

    hatch random-normal 3 1 [
      initialize-natural

      let x-tmp 0
      let y-tmp 0
      ask one-of habitable-patches-in-radius 5 [
        set x-tmp pxcor
        set y-tmp pycor
      ]
      setxy x-tmp y-tmp
    ]
  ]
end

to planted-recruit
  if random-float 1.0 * 10 < planted-birth [
    let parent-x pxcor
    let parent-y pycor

    hatch random-normal 3 1 [
      initialize-planted

      let x-tmp 0
      let y-tmp 0
      ask one-of habitable-patches-in-radius 2 [
        set x-tmp pxcor
        set y-tmp pycor
      ]
      setxy x-tmp y-tmp
    ]
  ]
end

; death

to natural-die
  let mortality-roll random-float 1.0 * 10
  ifelse dbh >= 5.0
    [ if mortality-roll <= natural-tree-mortality [ die ] ]
    [ ifelse dbh >= 2.5
      [ if mortality-roll < natural-sapling-mortality [ die ] ]
      [ if mortality-roll < natural-seedling-mortality [ die ] ]
    ]
end

to planted-die
  let mortality-roll random-float 1.0 * 10
  ifelse dbh >= 5.0
    [ if mortality-roll <= planted-tree-mortality [ die ] ]
    [ ifelse dbh >= 2.5
      [ if mortality-roll < planted-sapling-mortality [ die ] ]
      [ if mortality-roll < planted-seedling-mortality [ die ] ]
    ]
end

; ----------------------------------------
; MANGROVE EQUATIONS
; ----------------------------------------

to-report natural-dbh-change
  let result dbh ^ (natural-beta - natural-alpha - 1)
  set result result * (natural-omega / (2 + natural-alpha))
  set result result * (1 - (1 / natural-gamma) * (dbh / natural-d-max) ^ (1 + natural-alpha))

  ask patch-here [
    set result result * salinity-response / natural-salinity-response
    set result result * inundation-response / natural-inundation-response
    set result result * competition-response / natural-competition-response
  ]

  report max list result 0
end

to-report planted-dbh-change
  let result dbh ^ (planted-beta - planted-alpha - 1)
  set result result * (planted-omega / (2 + planted-alpha))
  set result result * (1 - (1 / planted-gamma) * (dbh / planted-d-max) ^ (1 + planted-alpha))

  ask patch-here [
    set result result * salinity-response / planted-salinity-response
    set result result * inundation-response / planted-inundation-response
    set result result * competition-response / planted-competition-response
  ]

  report max list result 0
end

to-report shore-dist
  report 150
end

to-report seaward-dist
  report shore-dist - dist
end

to-report salinity-response
  let salinity-field min list (72 / shore-dist * seaward-dist) 72
  report (1 + e ^ ((salinity-field - 72) / 4)) ^ -1
end

to-report inundation-response
  let inundation-field min list (0.8 / shore-dist * seaward-dist) 1
  report 1 - inundation-field
end

to-report total-response
  report salinity-response * inundation-response
end

to-report competition-response
  let comp-total 1
  ask turtles-here [
    let comp-here e ^ (-0.1 * dbh / 2)
    set comp-total comp-total * comp-here
  ]
  ask neighbors [
    ask turtles-at pxcor pycor [
      let comp-here e ^ (-0.1 * dbh / 2)
      set comp-total comp-total * comp-here
    ]
  ]
  report comp-total
end

to storm
  ask naturals [
    set naturals-neighbors naturals in-radius 0 with [ dbh > [dbh] of myself ]
    set planted-neighbors planteds in-radius 0 with [ dbh > [dbh] of myself ]
    set num-neighbors count planted-neighbors + count naturals-neighbors
  ]

  ask planteds [
    set naturals-neighbors naturals in-radius dbh with [ dbh > [dbh] of myself ]
    set planted-neighbors planteds in-radius dbh with [ dbh > [dbh] of myself ]
    set num-neighbors count planted-neighbors + count naturals-neighbors
  ]

  ask turtles [
    ifelse dbh > 10 [
      if random-float 1.0 < (0.7 - (num-neighbors * tree-protect) ) [ die ]
    ] [
      if random-float 1.0 < (0.1 - (num-neighbors * tree-protect) )
      [
        print "i died"
        die
         ]
    ]
  ]















end
@#$#@#$#@
GRAPHICS-WINDOW
447
8
923
505
-1
-1
9.32
1
10
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
0
0
1
ticks
30.0

BUTTON
78
10
141
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
240
163
439
196
planted-plot-age
planted-plot-age
0
50
14
1
1
NIL
HORIZONTAL

BUTTON
12
10
75
43
NIL
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

SLIDER
243
237
442
270
planted-birth
planted-birth
0
5
1.2
.1
1
NIL
HORIZONTAL

SLIDER
243
337
442
370
planted-tree-mortality
planted-tree-mortality
0
5
1
0.01
1
NIL
HORIZONTAL

SLIDER
243
303
442
336
planted-sapling-mortality
planted-sapling-mortality
0
5
1.2
.1
1
NIL
HORIZONTAL

SLIDER
243
270
441
303
planted-seedling-mortality
planted-seedling-mortality
0
5
2.4
0.1
1
NIL
HORIZONTAL

SLIDER
243
378
415
411
planted-alpha
planted-alpha
0
1
0.95
0.05
1
NIL
HORIZONTAL

SLIDER
243
412
415
445
planted-beta
planted-beta
0
5
2
0.1
1
NIL
HORIZONTAL

SLIDER
243
443
415
476
planted-omega
planted-omega
0
15
5
1
1
NIL
HORIZONTAL

SLIDER
243
478
416
511
planted-gamma
planted-gamma
0.01
1
1
0.05
1
NIL
HORIZONTAL

SLIDER
243
512
415
545
planted-d-max
planted-d-max
5
130
60
5
1
NIL
HORIZONTAL

SLIDER
240
553
459
586
planted-competition-response
planted-competition-response
0
2
1
0.05
1
NIL
HORIZONTAL

PLOT
928
11
1321
326
population line graph
time
pop
0.0
100.0
0.0
1000.0
true
true
"" ""
PENS
"Rhizophora (t)" 1.0 0 -13403783 true "" "plot count planted-trees"
"Rhizophora (sp)" 1.0 0 -11221820 true "" "plot count planted-saplings"
"Rhizophora (sd)" 1.0 0 -6759204 true "" "plot count planted-seedlings"
"native (t)" 1.0 0 -13210332 true "" "plot count natural-trees"
"native (sp)" 1.0 0 -10899396 true "" "plot count natural-saplings"
"native (sd)" 1.0 0 -6565750 true "" "plot count natural-seedlings"

SLIDER
9
585
227
618
natural-salinity-response
natural-salinity-response
0
2
0.7
0.05
1
NIL
HORIZONTAL

SLIDER
9
618
227
651
natural-inundation-response
natural-inundation-response
0
2
0.7
0.05
1
NIL
HORIZONTAL

SLIDER
240
585
459
618
planted-salinity-response
planted-salinity-response
0
2
1
0.05
1
NIL
HORIZONTAL

SLIDER
240
618
459
651
planted-inundation-response
planted-inundation-response
0
2
1
0.05
1
NIL
HORIZONTAL

SLIDER
240
197
439
230
planted-density
planted-density
0
2000
1000
50
1
NIL
HORIZONTAL

SLIDER
9
553
227
586
natural-competition-response
natural-competition-response
0
2
1
0.05
1
NIL
HORIZONTAL

SLIDER
9
378
182
411
natural-alpha
natural-alpha
0
1
0.95
0.05
1
NIL
HORIZONTAL

SLIDER
9
413
182
446
natural-beta
natural-beta
0
5
2
0.1
1
NIL
HORIZONTAL

SLIDER
9
445
182
478
natural-omega
natural-omega
0
15
3
1
1
NIL
HORIZONTAL

SLIDER
9
478
182
511
natural-gamma
natural-gamma
0
1
1
0.05
1
NIL
HORIZONTAL

SLIDER
9
513
182
546
natural-d-max
natural-d-max
5
100
70
5
1
NIL
HORIZONTAL

SLIDER
9
198
208
231
natural-density
natural-density
0
2000
400
50
1
NIL
HORIZONTAL

SLIDER
9
237
208
270
natural-birth
natural-birth
0
5
1
.1
1
NIL
HORIZONTAL

SLIDER
9
270
208
303
natural-seedling-mortality
natural-seedling-mortality
0
5
2
0.1
1
NIL
HORIZONTAL

SLIDER
9
303
208
336
natural-sapling-mortality
natural-sapling-mortality
0
5
1
0.1
1
NIL
HORIZONTAL

SLIDER
9
335
208
368
natural-tree-mortality
natural-tree-mortality
0
5
0.83
0.01
1
NIL
HORIZONTAL

BUTTON
145
10
253
45
manual-storm
storm
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
240
115
378
160
planted-species
planted-species
"Rhizophora" "native" "both"
2

PLOT
481
513
842
815
population phase portrait
Rhizophora
native
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plotxy count planteds count naturals"

SWITCH
12
99
122
132
storms
storms
0
1
-1000

SWITCH
13
63
123
96
limit-years
limit-years
0
1
-1000

SLIDER
12
138
186
171
mangrove-display-scale
mangrove-display-scale
0
20
10
1
1
NIL
HORIZONTAL

PLOT
929
331
1323
546
population line graph (Rhizophora vs. native)
time
population
0.0
100.0
0.0
1000.0
true
true
"" ""
PENS
"Rhizophora" 1.0 0 -11221820 true "" "plot count planteds"
"native" 1.0 0 -10899396 true "" "plot count naturals"
"storm-occur" 1.0 0 -3844592 true "" "plot 0\nif storms = true [\n    if storm-return = 0 [\n      plot-pen-up\n      plot-pen-down\n      plotxy ticks plot-y-max \n\n\n    ]\n  ]"

SLIDER
206
69
432
102
tree-protect
tree-protect
0
.1
0.035
.005
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
