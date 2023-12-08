doRelativeFile("../common.io")

elf_calories := List clone

calories_sum := 0
File openAndReadLines("input") foreach(line,
  (line strip isEmpty) ifTrue(
    elf_calories append(calories_sum)
    calories_sum = 0
  ) ifFalse(
    calories_sum = calories_sum + line asNumber
  )
)
if(calories_sum > 0, elf_calories append(calories_sum))

elf_calories max println
