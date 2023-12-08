program = DATA.readlines.map do |line|
  if line =~ /^(\w+) ([+\-]\d+)$/
    [$1.to_sym, $2.to_i]
  else
    p "oops"
  end
end

executed = {}
ip = 0
acc = 0
loop do
  if executed[ip]
    p acc
    exit
  else
    executed[ip] = true
  end

  inst, num = program[ip]
  case inst
  when :acc
    acc += num
    ip += 1
  when :jmp
    ip += num
  when :nop
    ip += 1
  else
    p "oops"
  end
end

__END__
acc -8
acc +19
nop +178
jmp +493
acc +7
jmp +267
jmp +604
acc +30
acc +11
acc -17
nop +402
jmp +81
acc +20
acc +19
acc +36
jmp +6
acc +43
acc +6
acc +10
nop +326
jmp +228
nop +371
acc +49
nop +140
acc -11
jmp +3
nop +366
jmp +74
nop +229
jmp +554
acc +12
acc +6
jmp +163
acc +43
acc +23
jmp +310
acc -6
nop +341
acc +50
acc +44
jmp +378
acc +28
acc +29
nop +76
jmp +136
nop +445
acc +27
acc -8
acc +34
jmp +199
acc +39
acc +25
acc -14
acc +1
jmp +189
acc +2
acc -9
jmp -7
acc +28
acc +28
jmp +458
jmp +1
nop +299
jmp +427
acc +10
acc +32
jmp +340
acc +26
jmp +563
jmp +1
acc +9
jmp +42
acc +4
jmp +468
acc +1
acc +3
jmp +258
acc +29
acc +7
acc -5
jmp +288
acc +22
acc +32
acc -6
jmp +173
acc +48
acc +42
acc +26
jmp +380
jmp +126
acc +45
jmp -27
acc +50
jmp +14
jmp +472
acc -19
jmp +363
acc +19
acc -8
acc +25
jmp +450
acc -7
acc +27
acc +44
acc +17
jmp +487
jmp +89
nop +216
nop +345
acc -1
acc +37
jmp +455
jmp +294
acc +20
acc +38
jmp +419
acc +17
acc +17
jmp +125
jmp +81
acc +37
acc -8
acc +9
acc +31
jmp +218
acc +24
acc +28
acc -4
acc -12
jmp -40
acc +40
nop +359
nop +182
nop +306
jmp +296
acc -8
jmp +1
nop +43
acc -14
jmp +239
acc +13
acc +10
jmp +1
jmp -36
acc -16
acc +2
jmp +344
jmp +442
acc +35
acc +2
acc +27
acc +17
jmp -27
nop +478
acc +6
acc +7
jmp +454
nop -145
acc +20
acc -6
jmp +182
nop +251
jmp -37
acc +26
jmp +300
acc +29
acc +44
acc +32
nop +56
jmp +31
acc -16
jmp +53
acc -9
jmp +84
jmp +1
nop +30
acc -15
jmp +262
acc -19
jmp +163
jmp +441
acc +27
jmp +449
acc +42
acc +45
acc +21
acc +22
jmp +338
acc +24
jmp +301
acc +42
acc +42
acc +26
jmp +348
jmp +361
acc -5
acc -19
acc +4
jmp -117
jmp +254
jmp +1
acc +47
acc -3
jmp +271
jmp +388
acc +2
acc -17
acc +37
jmp -73
acc +37
acc +34
jmp +1
jmp -148
jmp -56
jmp +103
acc -5
acc +23
acc +3
jmp +405
nop +255
acc +14
nop -41
acc +12
jmp +94
acc +22
acc +30
jmp -107
acc +12
acc -2
jmp +65
acc +35
acc -4
jmp -174
nop -159
acc +47
jmp -52
acc +35
jmp +73
acc +1
acc +19
acc +35
acc +15
jmp -59
jmp +312
acc +20
acc +25
acc +45
jmp -4
acc -4
nop -160
acc -8
acc +31
jmp +166
acc +20
acc +16
acc -1
jmp +234
acc +0
jmp -45
acc +47
acc +17
nop -187
nop +206
jmp +17
acc +36
acc +0
acc +7
jmp +263
acc +32
acc -6
nop +35
jmp -101
acc +49
nop -60
jmp +118
acc -1
acc -7
nop -94
acc +21
jmp +82
nop +216
acc +5
nop -99
jmp -47
acc +31
acc +2
acc +26
acc +27
jmp -224
acc +15
acc +48
jmp +220
nop +152
jmp -69
acc +4
acc +24
jmp +200
acc +14
jmp +126
acc +48
acc +47
acc +10
jmp +26
acc +16
jmp -203
acc +21
jmp -158
acc -15
acc -13
jmp -94
jmp -136
nop -247
acc +16
jmp -130
acc +31
jmp +115
jmp -159
acc +7
acc +50
jmp +52
acc +22
acc +26
jmp +249
acc -18
jmp +1
jmp -251
nop +254
jmp -127
acc +37
jmp -93
nop +73
acc +11
acc +36
jmp +277
acc +29
acc +16
jmp -88
nop +8
acc +18
acc +47
acc -9
jmp +184
jmp -142
acc +50
jmp +287
jmp -250
jmp -296
jmp -83
acc +13
acc +29
acc +28
acc +16
jmp +40
acc +33
acc -13
jmp +43
nop +275
acc +24
nop -257
nop -65
jmp -112
acc +4
acc +38
jmp -193
jmp +1
acc -18
acc +15
jmp -223
acc -18
jmp -55
jmp -207
acc -6
jmp -215
acc +16
acc +44
jmp +1
acc +47
jmp -35
acc +47
acc +47
acc +35
jmp +144
jmp +1
acc +45
acc +25
jmp -293
acc +32
jmp -381
nop +65
jmp +1
acc +2
jmp -74
acc -13
acc -9
acc +4
jmp -251
jmp +1
jmp +71
acc -12
acc +7
acc +15
jmp +11
jmp -68
acc +33
jmp -330
jmp +48
acc -15
acc -11
jmp +97
acc -9
acc -10
jmp +100
acc +29
acc +21
jmp -134
acc -18
acc +38
jmp +67
jmp -12
acc +27
acc +26
acc -8
acc -2
jmp -124
jmp +165
nop -245
acc -16
acc +25
acc -19
jmp -328
nop -182
acc -7
acc +46
jmp -250
acc +45
acc -7
nop -256
acc -2
jmp +21
acc +21
acc +37
jmp +156
nop +32
jmp -195
nop -355
acc -14
nop -302
acc +48
jmp -407
acc +50
acc -9
acc +47
jmp -110
acc +31
acc +37
acc +15
jmp -162
acc -14
jmp -437
acc +44
jmp +1
acc +24
jmp -139
jmp -362
acc +40
jmp -41
acc +38
jmp -231
acc +31
acc +23
jmp +135
acc -19
acc +15
jmp +148
acc +16
acc -18
acc -3
acc +1
jmp -189
acc -12
acc -6
acc -18
nop -454
jmp +83
nop -190
jmp -17
acc -7
acc +34
acc -1
jmp +94
acc +42
jmp +34
nop -150
nop +90
nop -126
jmp -161
acc +5
acc +11
acc +20
acc +38
jmp -97
acc +49
acc +29
acc +26
jmp -36
acc +4
acc -14
acc +30
acc +42
jmp -192
jmp -336
acc +34
acc +31
acc +2
acc +33
jmp +65
acc +4
jmp -459
nop -399
acc -6
nop -256
jmp -420
acc -12
acc -17
jmp -276
acc +45
acc +40
jmp -180
acc +50
jmp -501
acc +17
jmp -232
acc +12
jmp -109
nop -291
nop -345
jmp +100
acc +36
acc +2
acc -2
jmp +1
acc +23
nop -299
acc +24
acc +30
jmp -476
acc +0
acc +6
acc +49
jmp +6
nop -461
jmp -539
nop -62
acc +48
jmp -526
jmp -365
acc +47
acc +10
acc +32
jmp -490
nop -148
acc +42
acc +5
jmp -358
acc -5
jmp -101
jmp -502
acc +15
acc +45
nop -399
jmp +1
acc +31
acc +47
acc +49
jmp -269
acc +6
acc +45
acc -8
acc -6
jmp +36
jmp +51
acc +39
jmp -64
acc +47
jmp +1
acc -8
jmp -102
acc -8
jmp -202
jmp -18
acc +1
jmp -484
acc +35
acc +30
acc +49
jmp -562
jmp -515
acc -13
nop -6
jmp -369
acc +27
acc +18
nop -477
acc -10
jmp -430
jmp +1
acc +7
nop -111
jmp -445
jmp +12
jmp -50
acc +7
acc +3
nop -433
jmp -390
acc -5
acc +50
jmp -67
acc +45
acc -10
jmp -446
jmp -496
jmp -17
acc +14
acc +33
jmp -239
acc +3
acc -3
acc +27
acc -3
jmp -162
jmp -16
acc +23
acc +26
acc +25
jmp -346
acc +40
acc +45
acc +42
acc -4
jmp +1
