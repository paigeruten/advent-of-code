doRelativeFile("../common.io")

itemPriority := method(item,
    itemByte := item byteAt(0)
    if(item isLowercase,
        itemByte - "a" byteAt(0) + 1,
        itemByte - "A" byteAt(0) + 27
    )
)

sumOfPriorities := 0

File openAndReadLines("input") foreach(line,
    compartments := line splitAt(line size / 2) map(chars)
    sharedItem := compartments first intersect(compartments second) first
    sumOfPriorities = sumOfPriorities + itemPriority(sharedItem)
)

sumOfPriorities println
