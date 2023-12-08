doRelativeFile("../common.io")

SectionRange := Object clone do(
    begin ::= nil
    end ::= nil

    contains := method(value,
        value >= self begin and value <= self end
    )

    fullyContains := method(other,
        contains(other begin) and contains(other end)
    )

    overlapsWith := method(other,
        self fullyContains(other) or
        other fullyContains(self) or
        self contains(other begin) or
        self contains(other end)
    )
)

re := "^(\\d+)-(\\d+),(\\d+)-(\\d+)$" asRegex

totalFullyContains := 0
totalOverlaps := 0

File openAndReadLines("input") foreach(line_idx, line,
    match := line findRegex(re)
    if(match not, Exception raise("invalid input on line #{line_idx + 1}" interpolate))

    range1 := SectionRange clone \
        setBegin(match captures at(1) asNumber) \
        setEnd(match captures at(2) asNumber)
    range2 := SectionRange clone \
        setBegin(match captures at(3) asNumber) \
        setEnd(match captures at(4) asNumber)

    (range1 fullyContains(range2) or range2 fullyContains(range1)) ifTrue(
        totalFullyContains = totalFullyContains + 1
    )

    (range1 overlapsWith(range2)) ifTrue(
        totalOverlaps = totalOverlaps + 1
    )
)

"Part 1: #{totalFullyContains}" interpolate println
"Part 2: #{totalOverlaps}" interpolate println
