extensions [gis]
globals [dataset week month year temp tempo maxbeetle counteggs maxbefall maxbeetlechecker]
patches-own [Baumart Baumanzahl Id Festmeter Fastmeter Eier Eier2 Eier3 Eier4 Anzahl pheromon
  Befall Totholz randomzahl Befallmeter Befallszahl Befallszahl2 Befallszahl3 Befallszahl4 Totmeter]
turtles-own [energy lifecount waittime]
breed [beetle beet]

to setup
  ca
  reset-ticks
  setupmap
  set year 2000
  set maxbeetle 0
  set maxbefall 0
  set counteggs 0
  set maxbeetlechecker false
  ask patches
  [
    set Eier 0
    set Eier2 0
    set Anzahl 0
    set pheromon false
    set Befall false
    set Totholz 0
    set Befallszahl 0
    set Befallszahl2 0
    set Befallszahl3 0
    set Befallszahl4 0
    set Totmeter 0
  ]
  ask patches with [Festmeter > 0]
  [
    set Totholz 17
  ]
  ask n-of 7 patches with [pcolor = 53]
    [
      sprout-beetle 3
      [
        set shape "bug"
        set color yellow
        set energy random 21 + 5
        set lifecount 0
        set waittime 0
      ]
      ask neighbors with [pcolor = 53]
      [
        sprout-beetle 3
        [
          set shape "bug"
          set color yellow
          set energy random 21 + 5
          set lifecount 0
          set waittime 0
        ]
      ]
  ]
  set temp 0
end

to setupmap
  gis:load-coordinate-system "FP_treeBOXES.prj"
  set dataset gis:load-dataset "FP_treeBOXES.shp"
  gis:set-world-envelope gis:envelope-of dataset
  resize-world -57 57 -57 57
  gis:apply-coverage dataset "WORD" Baumart
  gis:apply-coverage dataset "COUNT" Baumanzahl
  gis:apply-coverage dataset "ID" Id
  gis:apply-coverage dataset "VOL" Fastmeter
  ask patches with [Fastmeter > 0]
  [
    set Festmeter Fastmeter
  ]
  ask patches ;RANDOM SURROUNDING PATCH COLOR
  [
    set randomzahl random 3
    if randomzahl = 0
    [
      set pcolor brown
    ]
    if randomzahl = 1
    [
      set pcolor 53
    ]
    if randomzahl = 2
    [
      set pcolor 65
    ]
  ]
  ask patches with [pcolor != 35 and Festmeter = 0]
  [
    set Festmeter 300 + random -300 + random 300
  ]
  ask patches
  [
    if Baumart = "3"
    [
      set pcolor 65
    ]
    if Baumart = "1"
    [
      set pcolor 53
    ]
    if Baumart = "4"
    [
      set pcolor brown
    ]
    if Baumart = "0"
    [
      set pcolor grey
    ]
  ]
  if management = true
  [
    ask patches with [pcolor = 53]
    [
      if count neighbors with [pcolor = 53] < Managementnumber
      [
        set pcolor 65
      ]
    ]
  ]
end

to go
  tick
  if year = 2020
  [
    stop
  ]
  progresstime
  check
  if month = 3 or month = 4 or month = 5 or month = 6 or month = 7   ;april, mai, juni, juli, august
  [
    if temp >= 16
    [
      move
    ]
  ]
  set counteggs count patches with [Eier > 0] + count patches with [Eier2 > 0] + count patches with [Eier3 > 0] + count patches with [Eier4 > 0]
  ask patches with [count beetle-here > 0]
  [
    set Anzahl count beetle-here
  ]
  if month = 1 or month = 2 or month = 8 or month = 9
  [
    ask beetle
    [
      if [pcolor] of patch-here != 53
      [
        die
      ]
    ]
  ]
end

to progresstime
  if ticks = 7 or ticks = 14 or ticks = 21 or ticks = 28
  [
    temperature
    if klimakrise = true
    [
      set temp temp + 4.5
    ]
  ]
  if ticks = 35
  [
    set week week + 1
    reset-ticks
    egg
    egg2
    egg3
    egg4
    temperature
    if klimakrise = true
    [
      set temp temp + 4.5
    ]
    ask turtles with [waittime > 0]
    [
      set waittime waittime - 1
    ]
  ]
  if count beetle > maxbeetle
  [
    set maxbeetle count beetle
  ]
  if week = 4
  [
    set month month + 1
    set week 0
    sterben
  ]
  if month = 12
  [
    set year year + 1
    set month 0
    ;refresh                   #######
    settotholz
    if Windwurf = true
    [
      Windfall
    ]
    ask turtles with [lifecount = 2]  ;älteste generation stirbt
    [
      die
    ]
    set maxbefall sum [Totmeter] of patches with [pcolor = 53 and Totmeter > 0]
    ask patches with [Befall = true]
    [
      set Befall false
      set Totmeter 0
    ]
    ask patches with [Pheromon = true]
    [
      set Pheromon false
    ]
    ask beetle
    [
      if random 100 < 45 ;+ random 11
      [
        die
      ]
    ]
    ifelse count beetle > maxbeetles
    [
      set maxbeetlechecker true
    ]
    [
      set maxbeetlechecker false
    ]
  ]
end

to egg ;Normale Brut
  ask patches with [Eier > 0]
  [
    (ifelse
      temp >= 30
      [
        set Eier Eier - 2
      ]
      temp >= 25 and temp < 30
      [
        set Eier Eier - 1.7 - random-float 0.1
      ]
       temp >= 20 and temp < 25
      [
        set Eier Eier - 1.2 - random-float 0.3
      ]
      temp >= 15 and temp < 20
      [
        set Eier Eier - 0.8 - random-float 0.3
      ]
      temp < 15
      [
        set Eier Eier - 0.65
      ]
    )
    if Eier <= 0
    [
      set Eier 0
      (ifelse
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 2
        [
          if random 100 < 90
          [
            sprout-beetle (3 + random 4) * Befallszahl
            [
              set shape "bug"
              set color yellow
              set energy random 11 + 5
              set lifecount 0
              set waittime 0
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 2 and Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 4
        [
          if random 100 < 90
          [
            sprout-beetle (2 + random 2) * Befallszahl
            [
              set shape "bug"
              set color yellow
              set energy random 11 + 5
              set lifecount 0
              set waittime 0
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 4
        [
          if random 100 < 90
          [
            sprout-beetle (1 + random 2) * Befallszahl
            [
              set shape "bug"
              set color yellow
              set energy random 11 + 5
              set lifecount 0
              set waittime 0
            ]
          ]
        ]
        )
        set Befallszahl 0
      ]
    ]
end

to egg2 ;Normale Geschwisterbrut
  ask patches with [Eier2 > 0]
  [
    (ifelse
      temp >= 30
      [
        set Eier2 Eier2 - 2
      ]
      temp >= 25 and temp < 30
      [
        set Eier2 Eier2 - 1.7 - random-float 0.1
      ]
       temp >= 20 and temp < 25
      [
        set Eier2 Eier2 - 1.2 - random-float 0.3
      ]
      temp >= 15 and temp < 20
      [
        set Eier2 Eier2 - 0.8 - random-float 0.3
      ]
      temp < 15
      [
        set Eier2 Eier2 - 0.65
      ]
    )
    if Eier2 <= 0
    [
      set Eier2 0
      (ifelse
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 2
        [
          if random 100 < 80
          [
            sprout-beetle (3 + random 3) * Befallszahl2
            [
              set shape "bug"
              set color yellow
              set energy random 11 + 5
              set lifecount 0
              set waittime 0
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 2 and Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 4
        [
          if random 100 < 80
          [
            sprout-beetle (2 + random 2) * Befallszahl2
            [
              set shape "bug"
              set color yellow
              set energy random 11 + 5
              set lifecount 0
              set waittime 0
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 4
        [
          if random 100 < 80
          [
            sprout-beetle (1 + random 2) * Befallszahl2
            [
              set shape "bug"
              set color yellow
              set energy random 11 + 5
              set lifecount 0
              set waittime 0
            ]
          ]
        ]
      )
      set Befallszahl2 0
    ]
  ]
end

to egg3 ;Totholz Brut
  ask patches with [Eier3 > 0]
  [
    (ifelse
      temp >= 30
      [
        set Eier3 Eier3 - 2
      ]
      temp >= 25 and temp < 30
      [
        set Eier3 Eier3 - 1.7 - random-float 0.1
      ]
       temp >= 20 and temp < 25
      [
        set Eier3 Eier3 - 1.2 - random-float 0.3
      ]
      temp >= 15 and temp < 20
      [
        set Eier3 Eier3 - 0.8 - random-float 0.3
      ]
      temp < 15
      [
        set Eier3 Eier3 - 0.65
      ]
    )
    if Eier3 <= 0
    [
      set Eier3 0
      (ifelse
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 2
        [
          if random 100 < 75
          [
            ifelse Totholz > 30
            [
              sprout-beetle (3 + random 3) * Befallszahl3
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
            [
              sprout-beetle 3 * Befallszahl3
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 2 and Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 4
        [
          if random 100 < 75
          [
            ifelse Totholz > 30
            [
              sprout-beetle (2 + random 2) * Befallszahl3
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
            [
              sprout-beetle 2 * Befallszahl3
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 4
        [
          if random 100 < 75
          [
            ifelse Totholz > 30
            [
              sprout-beetle (1 + random 2) * Befallszahl3
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
            [
              sprout-beetle 1 * Befallszahl3
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
          ]
        ]
      )
      set Befallszahl3 0
    ]
  ]
end

to egg4 ;Totholz Geschwisterbrut
  ask patches with [Eier4 > 0]
  [
    (ifelse
      temp >= 30
      [
        set Eier4 Eier4 - 2
      ]
      temp >= 25 and temp < 30
      [
        set Eier4 Eier4 - 1.7 - random-float 0.1
      ]
       temp >= 20 and temp < 25
      [
        set Eier4 Eier4 - 1.2 - random-float 0.3
      ]
      temp >= 15 and temp < 20
      [
        set Eier4 Eier4 - 0.8 - random-float 0.3
      ]
      temp < 15
      [
        set Eier4 Eier4 - 0.65
      ]
    )
    if Eier4 <= 0
    [
      set Eier4 0
      (ifelse
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 2
        [
          if random 100 < 65
          [
            ifelse Totholz > 30
            [
              sprout-beetle (2 + random 3) * Befallszahl4
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
            [
              sprout-beetle 2 * Befallszahl4
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 2 and Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 <= 4
        [
          if random 100 < 50
          [
            ifelse Totholz > 30
            [
              sprout-beetle (1 + random 2) * Befallszahl4
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
            [
              sprout-beetle 1 * Befallszahl4
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
          ]
        ]
        Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 > 4
        [
          if random 100 < 50
          [
            ifelse Totholz > 30
            [
              sprout-beetle (1 + random 1) * Befallszahl4
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
            [
              sprout-beetle 1 * Befallszahl4
              [
                set shape "bug"
                set color yellow
                set energy random 11 + 5
                set lifecount 0
                set waittime 0
              ]
            ]
          ]
        ]
      )
      set Befallszahl4 0
    ]
  ]
end

to temperature
  (ifelse
    year = 2000
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -3.2 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 0.4 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 1.3 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 7.7 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 12.1 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 14.9 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 12.1 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 15.9 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 6.9 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 10.3 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 4.3 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 1.7 tempvalue
  ]
    ]
    year = 2001
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -1.4 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -1 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 3.1 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 3 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11.8 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 10.3 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 14.4 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 15.5 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 7.5 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 11.3 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal -1.1 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal -5.7 tempvalue
  ]
    ]
    year = 2002
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -1.9 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 2.3 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 2.9 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 4 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11.5 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 16 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.8 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 15.2 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 9.6 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 7.2 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 5.9 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 1 tempvalue
  ]
    ]
    year = 2003
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -2.2 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -3.4 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 2.9 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 5.4 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 13.1 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 17.8 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 16.3 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 19 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 12.2 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 4.4 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 6.6 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 0.3 tempvalue
  ]
    ]
    year = 2004
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -3 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 0.2 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 1.2 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 5 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 7.3 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 11.6 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 13.8 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 14.9 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 10.8 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 9.4 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 0.4 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 0.1 tempvalue
  ]
    ]
    year = 2005
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -3 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -6 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal -1.1 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 4.9 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 10.1 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 14.4 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 12.2 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 11.8 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 9.2 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 0.7 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal -4 tempvalue
  ]
    ]
    year = 2006
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -3.5 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -3.4 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal -1.3 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 4.1 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 9 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 17.6 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 11.3 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 14.1 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 10.8 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 4.7 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 1.7 tempvalue
  ]
    ]
    year = 2007
    [
      if month = 0  ;Jänner
  [
    set temp random-normal 1.3 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 1.3 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 2.3 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 9.4 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11.1 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 14.3 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 14.3 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 8.8 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 5.2 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 0.6 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 0.1 tempvalue
  ]
    ]
    year = 2008
    [
      if month = 0  ;Jänner
  [
    set temp random-normal 2 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 2 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 0.8 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 5.1 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11.8 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 14.1 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 14.5 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 15.1 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 9.3 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 8.7 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 3.9 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal -0.2 tempvalue
  ]
    ]
    year = 2009
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -2.4 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -2.5 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 0 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 10.1 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11.3 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 11.8 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.8 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 16.4 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 12.9 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 6.1 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 6.2 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal -1.5 tempvalue
  ]
    ]
    year = 2010
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -4.6 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -1.8 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 0.8 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 5.6 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 8.1 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13.3 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 16.8 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 14.8 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 9.8 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 5.9 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 3.8 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal -3.1 tempvalue
  ]
    ]
    year = 2011
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -0.8 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -0.4 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 3.4 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 8.4 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13.3 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 12.9 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 16.7 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 13.9 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 7.5 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 7.1 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 0.7 tempvalue
  ]
    ]
    year = 2012
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -2.2 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -7.3 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 4.7 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 6.1 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11.2 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 14.8 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.1 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 16.5 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 12.1 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 8 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 5.9 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal -0.9 tempvalue
  ]
    ]
    year = 2013
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -2.2 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -4.7 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal -0.8 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 6.4 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 8.4 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 12.5 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 17 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 16.1 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 10.3 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 9.6 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 1.8 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 3.1 tempvalue
  ]
    ]
    year = 2014
    [
      if month = 0  ;Jänner
  [
    set temp random-normal 2.5 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 2.8 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 5.1 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 7 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 8.6 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13.7 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.6 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 13.1 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 11.5 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 10.2 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 7.5 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 0.5 tempvalue
  ]
    ]
    year = 2015
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -0.6 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -1 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 2.1 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 5.5 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 9.9 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13.8 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 18.2 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 18.8 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 10.1 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 7.2 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 6.7 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 5.7 tempvalue
  ]
    ]
    year = 2016
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -0.4 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 1.6 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 1.1 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 6.3 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 9.5 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13.6 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.8 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 15 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 14.2 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 5.9 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 2.4 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 1.9 tempvalue
  ]
    ]
    year = 2017
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -3.5 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 2.4 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 4.4 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 3.9 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 11.2 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 16.1 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.8 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 17.1 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 9.3 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 8.8 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 2.2 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal -1 tempvalue
  ]
    ]
    year = 2018
    [
      if month = 0  ;Jänner
  [
    set temp random-normal 1.5 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal -5.9 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 0.2 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 11.4 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 12.9 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13.9 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 16.4 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 18 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 13.3 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 10 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 5.3 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 0.2 tempvalue
  ]
    ]
    year = 2019
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -3.9 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 2.7 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 3.5 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 6.6 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 6.7 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 18.4 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 16.7 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 16.7 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 11.9 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 10.8 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 5 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 2.3 tempvalue
  ]
    ]
    year = 2020
    [
      if month = 0  ;Jänner
  [
    set temp random-normal 2.6 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 2.2 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 1.8 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 8.6 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 8.3 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 13 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.5 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 16.6 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 12.2 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 7.2 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 5.8 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 2.1 tempvalue
  ]
    ]
    year = 2021
    [
      if month = 0  ;Jänner
  [
    set temp random-normal -2.6 tempvalue
  ]
  if month = 1  ;Februar
  [
    set temp random-normal 2.8 tempvalue
  ]
  if month = 2  ;März
  [
    set temp random-normal 1.6 tempvalue
  ]
  if month = 3  ;April
  [
    set temp random-normal 3.1 tempvalue
  ]
  if month = 4  ;Mai
  [
    set temp random-normal 7.3 tempvalue
  ]
  if month = 5  ;Juni
  [
    set temp random-normal 16.6 tempvalue
  ]
  if month = 6  ;Juli
  [
    set temp random-normal 15.7 tempvalue
  ]
  if month = 7  ;August
  [
    set temp random-normal 13.5 tempvalue
  ]
  if month = 8  ;September
  [
    set temp random-normal 13 tempvalue
  ]
  if month = 9  ;Oktober
  [
    set temp random-normal 8.4 tempvalue
  ]
  if month = 10 ;November
  [
    set temp random-normal 3.3 tempvalue
  ]
  if month = 11  ;Dezember
  [
    set temp random-normal 0.1 tempvalue
  ]
    ]
    )
end

to check
   ask patches   ; with [turtles-here = true]    ansonsten bekommen patches falsche werte
  [
    set Anzahl count beetle-here
  ]

end

to settotholz
(ifelse
  year = 2000
  [
    ask patches with [Festmeter > 0]
    [
      set Totholz 17
    ]
  ]
  year = 2001
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 18
    ]
  ]
  year = 2002
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 18.5
    ]
  ]
  year = 2003
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 19
    ]
  ]
  year = 2004
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 20
    ]
  ]
  year = 2005
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 21
    ]
  ]
  year = 2006
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 21
    ]
  ]
  year = 2007
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 22.5
    ]
  ]
  year = 2008
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 23.5
    ]
  ]
  year = 2009
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 25.5
    ]
  ]
  year = 2010
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 30
    ]
  ]
  year = 2011
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 32
    ]
  ]
  year = 2012
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 32
    ]
  ]
  year = 2013
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 32
    ]
  ]
  year = 2014
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 32
    ]
  ]
  year = 2015
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 32
    ]
  ]
  year = 2016
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 32
    ]
  ]
  year = 2017
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 32
    ]
  ]
  year = 2018
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 34
    ]
  ]
  year = 2019
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 34
    ]
  ]
  year = 2020
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 34
    ]
  ]
  year = 2021
    [
    ask patches with [Festmeter > 0]
    [
      set Totholz 34
    ]
  ]
    )
end

to move
  ask beetle with [waittime = 0]
  [
    (ifelse
      energy > 5
      [
        move-to one-of neighbors
        set energy energy - 1
      ]
      energy > 0 and energy <= 5
      [
        ifelse any? patches in-radius 2 with [Anzahl < Beetleonpatch and pheromon = true]
        [
          face one-of patches in-radius 2 with [Anzahl < Beetleonpatch and pheromon = true]
          fd 1
          set energy energy - 1
        ]
        [
          move-to one-of neighbors
          set energy energy - 1
        ]
      ]
      energy = 0
      [
        (ifelse any? patches in-radius 2 with [Anzahl < Beetleonpatch and pheromon = true]
          [
            move-to one-of patches in-radius 2 with [Anzahl < Beetleonpatch and pheromon = true]
          ]
          [
            if [Anzahl] of patch-here >= Beetleonpatch or [Befall] of patch-here = true or [pcolor] of patch-here != 53;Käfer bewegen sich bis sie einen passenden Patch gefunden haben
            [
              (ifelse any? neighbors with [pheromon = true]
                [
                  move-to one-of neighbors with [pheromon = true]
                ]
                [
                  (ifelse any? neighbors with [pcolor = 53 and Befall = false]
                    [
                      move-to one-of neighbors with [pcolor = 53 and Befall = false]
                    ]
                    [
                      move-to one-of neighbors
                      if [pcolor] of patch-here != 53
                      [
                        die
                      ]
                    ]
                  )
                ]
              )
            ]
          ]
        )
      ]
    )
  ]
  ask beetle with [energy = 0 and waittime = 0]
  [
    if [Anzahl] of patch-here < Beetleonpatch and [pcolor] of patch-here = 53 and [Befall] of patch-here = false
    [
      set waittime 1
      (ifelse
        lifecount = 0
        [
          set lifecount 1
          vermehren
          set energy random 21 + 5
          if random 100 < 33
          [
            die
          ]
        ]
        lifecount = 1
        [
          vermehren2
          die
        ]
      )
    ]
  ]
end

to vermehren
  ifelse [Pheromon] of patch-here = true
  [                                  ;2a  Pheromon checken
    ask patch-here
    [                                ;3a  Erfolgreich vermehren
      set Eier 7
      set Befallszahl Befallszahl + 1
      (ifelse
        Festmeter > 0 and Festmeter < 250
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
        Festmeter >= 250 and Festmeter < 350
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
        Festmeter >= 350 and Festmeter < 450
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
        Festmeter >= 450
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
      )
    ]
  ]
  [                                  ;2b Anzahl checken
    ifelse maxbeetlechecker = true or count beetle > maxbeetles
    [                                ;2c1 Fix Random Probieren
      ifelse random 100 < 30 ;15
      [                              ;3a  Erfolgreich vermehren
        set Pheromon true
        set Eier 7
        set Befallszahl Befallszahl + 1
        (ifelse
          Festmeter > 0 and Festmeter < 250
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
          Festmeter >= 250 and Festmeter < 350
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
          Festmeter >= 350 and Festmeter < 450
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
          Festmeter >= 450
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
        )
      ]
      [                              ;3b Misserfolg & Sterben
        ask beetle-here
        [
          die
        ]
      ]
    ]
    [                                ;2c2 Mby Random probieren
      ifelse random 100 < 35
      [
        ifelse random 100 < 25 ;15
        [                             ;3a  Erfolgreich vermehren
          set Pheromon true
          set Eier 7
          set Befallszahl Befallszahl + 1
          (ifelse
            Festmeter > 0 and Festmeter < 250
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 250 and Festmeter < 350
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 350 and Festmeter < 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
          )
        ]
        [                             ;3b Misserfolg & Sterben
          ask beetle-here
          [
            die
          ]
        ]
      ]
      [                               ;3c Totholz Vermehrung
        ask patch-here
        [
          set Eier3 7
          set Befallszahl3 Befallszahl3 + 1
          (ifelse
            Festmeter > 0 and Festmeter < 250
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 250 and Festmeter < 350
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 350 and Festmeter < 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
          )
        ]
      ]
    ]
  ]
end

to vermehren2
  ifelse [Pheromon] of patch-here = true
  [                                  ;2a  Pheromon checken
    ask patch-here
    [                                ;3a  Erfolgreich vermehren
      set Eier2 7
      set Befallszahl2 Befallszahl2 + 1
      (ifelse
        Festmeter > 0 and Festmeter < 250
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
        Festmeter >= 250 and Festmeter < 350
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
        Festmeter >= 350 and Festmeter < 450
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
        Festmeter >= 450
        [
          if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
          [
            set Befall true
            set Pheromon false
            set Totmeter Totmeter + Festmeter
          ]
        ]
      )
    ]
  ]
  [                                  ;2b Anzahl checken
    ifelse maxbeetlechecker = true or count beetle > maxbeetles
    [                                ;2c1 Fix Random Probieren
      ifelse random 100 < 30 ;15
      [                              ;3a  Erfolgreich vermehren
        set Pheromon true
        set Eier2 7
        set Befallszahl2 Befallszahl2 + 1
        (ifelse
          Festmeter > 0 and Festmeter < 250
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
          Festmeter >= 250 and Festmeter < 350
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
          Festmeter >= 350 and Festmeter < 450
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
          Festmeter >= 450
          [
            if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
            [
              set Befall true
              set Pheromon false
              set Totmeter Totmeter + Festmeter
            ]
          ]
        )
      ]
      [                              ;3b Misserfolg & Sterben
        ask beetle-here
        [
          die
        ]
      ]
    ]
    [                                ;2c2 Mby Random probieren
      ifelse random 100 < 35
      [                              ;3a  Erfolgreich vermehren
        ifelse random 100 < 25 ;15
        [
          set Pheromon true
          set Eier2 7
          set Befallszahl2 Befallszahl2 + 1
          (ifelse
            Festmeter > 0 and Festmeter < 250
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 250 and Festmeter < 350
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 350 and Festmeter < 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
          )
        ]
        [                            ;3b Misserfolg & Sterben
          ask beetle-here
          [
            die
          ]
        ]
      ]
      [                              ;3c Totholz Vermehrung
        ask patch-here
        [
          set Eier4 7
          set Befallszahl4 Befallszahl4 + 1
          (ifelse
            Festmeter > 0 and Festmeter < 250
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 250 and Festmeter < 350
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 1.5
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 350 and Festmeter < 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 2
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
            Festmeter >= 450
            [
              if Befallszahl + Befallszahl2 + Befallszahl3 + Befallszahl4 >= Beetleonpatch * 3
              [
                set Befall true
                set Pheromon false
                set Totmeter Totmeter + Festmeter
              ]
            ]
          )
        ]
      ]
    ]
  ]
end

to sterben
  ifelse maxbeetlechecker = true
  [
  ask beetle with [lifecount = 0]
  [
    if random-float 100 < todeschance - 3
    [
      die
    ]
  ]
  ask beetle with [lifecount = 1]
  [
    if random-float 100 < todeschance
    [
      die
    ]
  ]
  ]
    [
  ask beetle with [lifecount = 0]
  [
    if random-float 100 < todeschance
    [
      die
    ]
  ]
  ask beetle with [lifecount = 1]
  [
    if random-float 100 < todeschance + 10
    [
      die
    ]
  ]
  ]
end

to Windfall
  if year = 2007 or year = 2008
  [
    ask patches with [Festmeter > 0]
    [
      set Totholz 35
    ]
  ]
  if Extremevent = true and year = 2005
    [
      ask patches with [(pxcor > -15 and pxcor < 15)]
      [
        set Totholz 35
      ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
793
594
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-57
57
-57
57
0
0
1
ticks
30.0

BUTTON
14
17
81
50
NIL
SETUP
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
115
17
178
50
NIL
GO
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
643
608
793
650
DUNKELGRÜN\t = NADELWALD\nHELLGRÜN\t = LAUBWALD\nBRAUN \t= NON-WALD
11
0.0
1

MONITOR
5
659
62
704
NIL
week
17
1
11

MONITOR
67
659
124
704
NIL
month
17
1
11

MONITOR
130
659
187
704
NIL
year
17
1
11

MONITOR
5
592
90
653
Temp [°C]
temp
1
1
15

MONITOR
5
438
62
483
Beetles
count beetle
17
1
11

MONITOR
6
488
63
533
Brut
count patches with [Eier > 0]
17
1
11

MONITOR
75
488
178
533
Geschwisterbrut
count patches with [Eier2 > 0]
17
1
11

PLOT
324
601
524
751
Befall
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
"Festmeter Befall" 1.0 1 -5825686 true "" "plot sum [Totmeter] of patches with [pcolor = 53 and Totmeter > 0]"

SLIDER
13
51
185
84
todeschance
todeschance
0
10
5.0
0.5
1
NIL
HORIZONTAL

SLIDER
13
85
185
118
maxbeetles
maxbeetles
0
1000
400.0
10
1
NIL
HORIZONTAL

SLIDER
13
119
185
152
tempvalue
tempvalue
0
10
4.0
1
1
NIL
HORIZONTAL

MONITOR
3
543
83
588
Totholz Brut
count patches with [Eier3 > 0]
17
1
11

MONITOR
87
543
211
588
Totholz Geschwister
count patches with [Eier4 > 0]
17
1
11

PLOT
11
154
194
284
Temperature
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
"default" 1.0 0 -16777216 true "" "plot Temp"

PLOT
11
287
195
427
Beetles
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
"default" 1.0 0 -16777216 true "" "plot count beetle"

TEXTBOX
98
622
248
650
Breeding Months:\n3, 4, 5, 6 & 7
11
0.0
1

SWITCH
215
621
324
654
Windwurf
Windwurf
0
1
-1000

BUTTON
15
721
110
754
Überprüfen
set year 2006
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
74
438
183
483
Maximum beetle
maxbeetle
17
1
11

SLIDER
532
662
704
695
Beetleonpatch
Beetleonpatch
1
15
3.0
1
1
NIL
HORIZONTAL

MONITOR
196
661
253
706
Befall
count patches with [Befall = true]
17
1
11

MONITOR
157
714
250
759
Eier insgesamt
counteggs
17
1
11

MONITOR
256
660
319
705
Befall [fm]
sum [Totmeter] of patches with [pcolor = 53 and Totmeter > 0]
17
1
11

MONITOR
253
713
322
758
Jahresbefall
maxbefall
17
1
11

SWITCH
532
697
641
730
Klimakrise
Klimakrise
0
1
-1000

SWITCH
645
697
772
730
Extremevent
Extremevent
0
1
-1000

SWITCH
531
732
639
765
Management
Management
0
1
-1000

SLIDER
646
731
772
764
Managementnumber
Managementnumber
0
9
3.0
1
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
