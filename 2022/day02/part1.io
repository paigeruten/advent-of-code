doRelativeFile("../common.io")

Outcome := Object clone do(
    points ::= 0
)

HandShape := Object clone do(
    beats := nil
    points ::= 0

    fight := method(opponent,
      if(self beats == opponent, Win, if(opponent beats == self, Lose, Draw))
    )
)

Win := Outcome clone setPoints(6)
Draw := Outcome clone setPoints(3)
Lose := Outcome clone setPoints(0)

Rock := HandShape clone setPoints(1)
Paper := HandShape clone setPoints(2)
Scissors := HandShape clone setPoints(3)

// -- Rules of the Game --
Rock beats := Scissors
Paper beats := Rock
Scissors beats := Paper
// -----------------------

decodeHandShape := method(letter,
    Map with(
        "A", Rock,
        "B", Paper,
        "C", Scissors,
        "X", Rock,
        "Y", Paper,
        "Z", Scissors
    ) at(letter)
)

totalPoints := 0

File openAndReadLines("input") foreach(line,
    codes := line split

    opponent := decodeHandShape(codes first)
    me := decodeHandShape(codes second)

    // 3, 2, 1, fight!
    outcome := me fight(opponent)

    roundPoints := outcome points + me points
    totalPoints = totalPoints + roundPoints
)

totalPoints println
