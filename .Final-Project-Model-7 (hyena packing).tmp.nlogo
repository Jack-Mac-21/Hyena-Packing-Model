globals [
  lion-energy
  hyena-energy
  impala-energy
  antelope-energy
]

breed [ lions lion ]
breed [ hyenas hyena ]
breed [impalas impala ]
breed [ antelopes antelope ]

patches-own [ grass-amount ] ;; patches will have grass in a very similar way to the wolf-sheep model

turtles-own [
  energy
  preference-number
]

hyenas-own [
  pack-count
]

to setup
  clear-all
  reset-ticks
  ask patches [
    set grass-amount random-float 10.0
    recolor-grass ;; change the world green
  ]
  create-animals
end

to go
  ask turtles [
    move
    eat
    reproduce
    check-death
  ]
  regrow-grass
  report-energy
  tick
end


to move
  rt random 90
  lt random 90
  if breed = lions [set energy (energy - lion-movement-cost)]
  if breed = hyenas [hyena-move] ; so hyenas do not use two move functions
  if breed = antelopes [set energy (energy - movement-cost)]
  if breed = impalas [set energy (energy - movement-cost)]
  forward 1
end

to hyena-move
  if-else random 100 < random-hyena-movement-probability [
    rt random 90
    lt random 90
  ]
  [
    face one-of hyenas in-radius pack-radius
  ]
  set energy (energy - hyena-movement-cost)
  forward 1
end

to lion-move
  rt random 90
  lt random 90
  set energy (energy - lion-movement-cost)
  forward 1
end

to eat ;All eat procedures called for turtls
  if breed = lions and preference-threshold? [
    lion-eat-procedure
  ]
  if breed = lions and not preference-threshold? [ lion-eat-procedure-2 ]
  if breed = hyenas [ hyena-eat-procedure ]
  if breed = impalas [ impala-eat-procedure ]
  if breed = antelopes [ antelope-eat-procedure ]
end

to lion-eat-procedure ;Lions will prioritize impalas, but will eat a hyena given the chance
  let pack-count-number (count hyenas in-radius pack-radius) ;number of hyenas in the area

  if-else any? impalas-here
  [
    let target one-of impalas-here
    ask target [ die ]
    set energy (energy + lion-energy-gain-from-eating)
  ]
  [if any? hyenas-here and (pack-count-number < 20)
    [
      let target one-of hyenas-here
      ask target [ die ]
      set energy (energy + lion-energy-gain-from-eating)
    ]
  ]

  if energy < preference-threshold [
    if any? antelopes-here [
      let target one-of antelopes-here
      ask target [ die ]
      set energy (energy + lion-energy-gain-from-eating)
    ]
  ]
end

to lion-eat-procedure-2 ;This eat procedure does not use preference based on hunger
  let pack-count-number (count hyenas in-radius pack-radius) ;number of hyenas in the area
  let target 0

  if any? antelopes-here [
    set target one-of antelopes-here
  ]

  if-else any? impalas-here
  [
    set target one-of impalas-here

  ]
  [if any? hyenas-here and (pack-count-number < 20)
    [
      set target one-of hyenas-here
    ]
  ]
  if target != 0 [
    ask target [ die ]
    set energy (energy + lion-energy-gain-from-eating)
  ]
end

to hyena-eat-procedure ;hyenas eat antelopes now, but will eat impalas if they are hungry enough
  set pack-count (count hyenas in-radius pack-radius)
  if any? antelopes-here [
    let target one-of antelopes-here
    ask target [ die ]
    set energy (energy + hyena-energy-gain-from-eating)
  ]
  if energy < preference-threshold [
    if any? impalas-here [
      let target one-of impalas-here
      ask target [ die ]
      set energy (energy + hyena-energy-gain-from-eating)
    ]
  ]
  ;if pack-count > 5 [ ;; Hyenas will eat impala if they have a large enough pack size.
   ; if any? impalas-here [
    ;  let target one-of impalas-here
     ; ask target [ die ]
      ;set energy (energy + hyena-energy-gain-from-eating)
    ;]
  if pack-count > 20 [
    if any? lions-here [
      let target one-of lions-here
      ask target [ die ]
      set energy (energy + hyena-energy-gain-from-eating)
    ]
  ]
end

to impala-eat-procedure
  ;; check to make sure there is grass here
  if ( grass-amount > 0 ) [
    ;; increment the sheep's energy
    set energy energy + (energy-gain-from-grass * grass-units-eaten-per-eat)
    ;; decrement the grass
    set grass-amount grass-amount - grass-units-eaten-per-eat
    recolor-grass
  ]
end

to antelope-eat-procedure
  ;; check to make sure there is grass here
  if ( grass-amount > 0 ) [
    ;; increment the sheep's energy
    set energy energy + (energy-gain-from-grass * grass-units-eaten-per-eat)
    ;; decrement the grass
    set grass-amount grass-amount - grass-units-eaten-for-impala
    recolor-grass
  ]
end

to check-death
  if energy < 0 [ die ]
end

to recolor-grass
  set pcolor scale-color green (10 - grass-amount) -10 20
end


to regrow-grass
  ask patches [
    set grass-amount grass-amount + grass-regrowth-rate
    if grass-amount > 15.0 [
      set grass-amount 15.0
    ]
    recolor-grass
  ]
end

to create-animals ;; creates the animals in the setup procedure
  create-lions 20 [
    setxy random-xcor random-ycor
    set color red
    set shape "wolf 4"
    set size 2.2
    set energy 400
    set preference-number 2
  ]
  create-hyenas 50 [
    setxy random-xcor random-ycor
    set color brown
    set shape "wolf"
    set size 2
    set energy 100
    set preference-number 1
  ]
  create-impalas 100 [
    setxy random-xcor random-ycor
    set color grey
    set shape "sheep"
    set size 1
    set energy 100
    set preference-number 0
  ]
  create-antelopes 200 [
    setxy random-xcor random-ycor
    set color white
    set size 0.75
    set energy 70
    set preference-number 0
  ]
end

to reproduce
  if breed = lions [ lion-reproduce-procedure ]
  if breed = hyenas [ reproduce-regular ]
  if breed = impalas [ reproduce-regular ]
  if breed = antelopes [ reproduce-regular ]
end

to antelope-reproduce  ;; all animals have the same reproduction
  if energy > 130 [
    set energy energy - 40  ;; reproduction transfers energy
    hatch 1 [ set energy 70 ] ;; to the new agent
  ]
end

to reproduce-regular
  if energy > 120 [
    set energy energy - 30  ;; reproduction transfers energy
    hatch 1 [ set energy 100 ] ;; to the new agent
  ]
end

to lion-reproduce-procedure
    if energy > lion-reproduction-threshold [ ;; the point a lion will hatch an offspring
    set energy energy - lion-reproduction-cost  ;; reproduction transfers energy
    hatch 1 [ set energy 100 ] ;; to the new agent
  ]
end

to report-energy
  set lion-energy 0
  set hyena-energy 0
  set impala-energy 0
  ask lions [set lion-energy (lion-energy + energy)]
  ask hyenas [set hyena-energy (hyena-energy + energy)]
  ask impalas [set impala-energy (impala-energy + energy)]
end

to kill-lions
  ask lions [ die ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
36
16
99
49
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

BUTTON
121
15
184
48
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

PLOT
5
293
205
443
energy plot
ticks
energy
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"_1_1_1_1_1_1_1_1_1_1_1_1_1_1" 1.0 0 -2674135 true "" "plot lion-energy"
"_1_1_1_1_1_1_1_1_1_1_1_1_1_1" 1.0 0 -8431303 true "" "plot hyena-energy"
"pen-2" 1.0 0 -1184463 true "" "plot antelope-energy"

SLIDER
516
583
688
616
movement-cost
movement-cost
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
516
657
688
690
grass-regrowth-rate
grass-regrowth-rate
0
3
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
516
542
702
575
energy-gain-from-grass
energy-gain-from-grass
0
50
4.0
1
1
NIL
HORIZONTAL

SLIDER
517
620
711
653
grass-units-eaten-per-eat
grass-units-eaten-per-eat
0
10
3.0
1
1
NIL
HORIZONTAL

PLOT
5
137
205
287
population
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -8431303 true "" "plot count hyenas"
"pen-1" 1.0 0 -2674135 true "" "plot count lions"
"pen-2" 1.0 0 -1184463 true "" "plot count antelopes"
"pen-3" 1.0 0 -7500403 true "" "plot count impalas"

SLIDER
17
577
226
610
lion-energy-gain-from-eating
lion-energy-gain-from-eating
0
250
100.0
10
1
NIL
HORIZONTAL

SLIDER
250
541
475
574
hyena-energy-gain-from-eating
hyena-energy-gain-from-eating
0
200
90.0
10
1
NIL
HORIZONTAL

SLIDER
17
613
189
646
lion-reproduction-cost
lion-reproduction-cost
0
200
85.0
1
1
NIL
HORIZONTAL

SLIDER
17
501
217
534
lion-reproduction-threshold
lion-reproduction-threshold
0
200
200.0
1
1
NIL
HORIZONTAL

BUTTON
56
54
161
87
create 5 lions
create-lions 5[\n    setxy random-xcor random-ycor\n    set color red\n    set shape \"wolf 4\"\n    set size 2.2\n    set energy 400\n    set preference-number 2\n  ]
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
17
538
189
571
preference-threshold
preference-threshold
0
200
29.0
1
1
NIL
HORIZONTAL

SLIDER
18
649
190
682
lion-movement-cost
lion-movement-cost
0
25
17.0
1
1
NIL
HORIZONTAL

SLIDER
516
502
724
535
grass-units-eaten-for-impala
grass-units-eaten-for-impala
0
5
1.0
1
1
NIL
HORIZONTAL

SLIDER
250
581
424
614
hyena-movement-cost
hyena-movement-cost
0
20
13.0
1
1
NIL
HORIZONTAL

SLIDER
250
620
505
653
random-hyena-movement-probability
random-hyena-movement-probability
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
252
501
424
534
pack-radius
pack-radius
0
30
7.0
1
1
NIL
HORIZONTAL

BUTTON
42
95
170
128
create 10 hyenas
create-hyenas 10[\n    setxy random-xcor random-ycor\n    set color brown\n    set shape \"wolf\"\n    set size 2.2\n    set energy 100\n    set preference-number 2\n  ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
58
471
213
502
Lion Parameters
14
15.0
1

TEXTBOX
258
469
395
488
Hyena Parameters
14
34.0
1

TEXTBOX
538
461
709
498
Impala Parameters (Grey)\nAntelope Parameters (White)
12
0.0
1

SWITCH
18
687
197
720
preference-threshold?
preference-threshold?
1
1
-1000

@#$#@#$#@
## Model changes from previous

IN this model I added rabbits and made lions eat antelopes instead of hyenas. Lions will prioritize antelopes, but will also eat a hyena if they are present. Hyenas will prioritize

## Have the hyena have some odds of facing another hyena
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

cow skull
false
0
Polygon -7500403 true true 150 90 75 105 60 150 75 210 105 285 195 285 225 210 240 150 225 105
Polygon -16777216 true false 150 150 90 195 90 150
Polygon -16777216 true false 150 150 210 195 210 150
Polygon -16777216 true false 105 285 135 270 150 285 165 270 195 285
Polygon -7500403 true true 240 150 263 143 278 126 287 102 287 79 280 53 273 38 261 25 246 15 227 8 241 26 253 46 258 68 257 96 246 116 229 126
Polygon -7500403 true true 60 150 37 143 22 126 13 102 13 79 20 53 27 38 39 25 54 15 73 8 59 26 47 46 42 68 43 96 54 116 71 126

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

wolf 4
false
0
Polygon -7500403 true true 105 75 105 45 45 0 30 45 45 60 60 90
Polygon -7500403 true true 45 165 30 135 45 120 15 105 60 75 105 60 180 60 240 75 285 105 255 120 270 135 255 165 270 180 255 195 255 210 240 195 195 225 210 255 180 300 120 300 90 255 105 225 60 195 45 210 45 195 30 180
Polygon -16777216 true false 120 300 135 285 120 270 120 255 180 255 180 270 165 285 180 300
Polygon -16777216 true false 240 135 180 165 180 135
Polygon -16777216 true false 60 135 120 165 120 135
Polygon -7500403 true true 195 75 195 45 255 0 270 45 255 60 240 90
Polygon -16777216 true false 225 75 210 60 210 45 255 15 255 45 225 60
Polygon -16777216 true false 75 75 90 60 90 45 45 15 45 45 75 60

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
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
