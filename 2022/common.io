Regex

File do(
    openAndReadLines := method(path,
        file := File clone openForReading(path)
        lines := file readLines
        file close
        return lines
    )
)

Sequence do(
    asList := method(
        result := List clone
        foreach(byte, result append(byte))
    )

    chars := method(
        asList map(asCharacter)
    )
)

AssertException := Exception clone

assert := method(expr,
    (expr isTrue) ifFalse(AssertException raise("assertion failed"))
)
