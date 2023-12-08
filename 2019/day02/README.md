# `intcode.wat`

This is my attempt to solve [day 2](https://adventofcode.com/2019/day/2) of Advent of Code 2019 in hand-written WebAssembly.

With the basic input/output functions I wrote for [day 1](../day01) (go there for more explanation about writing WebAssembly by hand), I found day 2 surprisingly do-able. Surely I won't be able to keep this up for much longer.

The only real new thing here is my use of tables as a jump table for executing each instruction opcode. The alternative was to write a switch statement, which as far as I could tell would have to be a series of nested `if` blocks. See the comments in [`intcode.wat`](intcode.wat) for more details.

## Usage

```
$ wasmtime intcode.wat < ../input/input02
9706670
2552
```

It prints the solution to part 1, and then the solution to part 2.

