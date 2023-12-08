# `fuel.wat`

This is my attempt to solve [day 1](https://adventofcode.com/2019/day/1) of Advent of Code 2019 in hand-written WebAssembly.

It uses the [WebAssembly System Interface (WASI)](https://wasi.dev/) to read from standard input and write to standard output. WASI provides "system calls" `fd_read` and `fd_write`, which I wrapped in libc-style functions `getChar` and `putChar` (except without any error handling or buffered IO). Using these, I wrote a `readInt` function to parse an int from stdin, and a `writeInt` function to print an int to stdout.

With these supporting functions done, solving the actual problem was quite simple as it required only basic arithmetic and recursion (which WebAssembly has no problem with). For future puzzles, I may need to fall back to [AssemblyScript](https://docs.assemblyscript.org/) (which apparently has a runtime that provides you with hash maps and dynamic arrays among other things), or just Rust.

It's kind of hard to find information about how to write WebAssembly by hand... probably because there's no good reason to do it. So I added comments throughout [`fuel.wat`](fuel.wat) to explain everything to the best of my ability. Also see the list of [resources](#resources) that I found useful.

## Usage

You will need [`wasmtime`](https://wasmtime.dev/).

```
$ wasmtime fuel.wat <<< '14'
2
$ wasmtime fuel.wat <<< '1969'
966
$ wasmtime fuel.wat < ../input/input01
4726527
```

Convert it to the `.wasm` binary format using [`wat2wasm`](https://github.com/WebAssembly/wabt):

```
$ wat2wasm fuel.wat
$ wasmtime fuel.wasm <<< '1969'
966
$ wc -c fuel.wasm
469 fuel.wasm
$ xxd fuel.wasm
00000000: 0061 736d 0100 0000 0119 0560 047f 7f7f  .asm.......`....
00000010: 7f01 7f60 0000 6001 7f01 7f60 0001 7f60  ...`..`....`...`
00000020: 017f 0002 3202 0d77 6173 695f 756e 7374  ....2..wasi_unst
00000030: 6162 6c65 0766 645f 7265 6164 0000 0d77  able.fd_read...w
00000040: 6173 695f 756e 7374 6162 6c65 0866 645f  asi_unstable.fd_
00000050: 7772 6974 6500 0003 0908 0102 0203 0204  write...........
00000060: 0304 0503 0100 0107 1302 066d 656d 6f72  ...........memor
00000070: 7902 0006 5f73 7461 7274 0002 0ad6 0208  y..._start......
00000080: 2c01 027f 4100 2101 0240 0340 1005 2100  ,...A.!..@.@..!.
00000090: 417f 2000 460d 0120 0120 0010 046a 2101  A. .F.. . ...j!.
000000a0: 0c00 0b0b 2001 1007 410a 1009 0b1b 0101  .... ...A.......
000000b0: 7f20 0041 036e 4102 6b21 0120 0141 004c  . .A.nA.k!. .A.L
000000c0: 047f 4100 0520 010b 0b1a 0101 7f20 0010  ..A.. ....... ..
000000d0: 0321 0120 0145 047f 4100 0520 0120 0110  .!. .E..A.. . ..
000000e0: 046a 0b0b 4601 037f 4100 2100 4100 2102  .j..F...A.!.A.!.
000000f0: 0240 0340 1008 2101 2001 1006 0440 4101  .@.@..!. ....@A.
00000100: 2100 2002 410a 6c20 0141 306b 6a21 0205  !. .A.l .A0kj!..
00000110: 2000 0d02 417f 2001 460d 020b 0c00 0b0b   ...A. .F.......
00000120: 2000 047f 2002 0541 7f0b 0b0d 0020 0041   ... ..A..... .A
00000130: 304f 2000 4139 4d71 0b49 0102 7f41 1021  0O .A9Mq.I...A.!
00000140: 0141 1021 0203 4020 0241 3020 0041 0a70  .A.!..@ .A0 .A.p
00000150: 6a3a 0000 4101 2002 6a21 0220 0041 0a6e  j:..A. .j!. .A.n
00000160: 2100 4100 2000 470d 000b 0340 2002 4101  !.A. .G....@ .A.
00000170: 6b21 0220 022d 0000 1009 2002 2001 4b0d  k!. .-.... . .K.
00000180: 000b 0b2e 0041 0041 0836 0200 4104 4101  .....A.A.6..A.A.
00000190: 3602 0041 0041 0041 0141 0c10 001a 4101  6..A.A.A.A....A.
000001a0: 410c 2802 0046 047f 4108 2d00 0005 417f  A.(..F..A.-...A.
000001b0: 0b0b 2200 4100 4108 3602 0041 0441 0136  ..".A.A.6..A.A.6
000001c0: 0200 4108 2000 3a00 0041 0141 0041 0141  ..A. .:..A.A.A.A
000001d0: 0c10 011a 0b                             .....
```

As you can see, the `fuel.wasm` file is 469 bytes long! You can use [`wasm-objdump`](https://github.com/WebAssembly/wabt) to get a better sense of how it's structured.

BTW, if you're wondering what all those `A`'s are, they're `i32.const` instructions, whose opcode is `0x41`.

## Resources

* [Writing WebAssembly By Hand](https://blog.scottlogic.com/2018/04/26/webassembly-by-hand.html)
* [WasmExplorer](https://mbebenita.github.io/WasmExplorer/): Write C++, see how it compiles to WebAssembly.
* [WebAssembly spec](https://webassembly.github.io/spec/): Really hard to use as a reference when writing WebAssembly by hand, but theoretically contains everything you'd need to know...
* [WASI tutorial](https://github.com/bytecodealliance/wasmtime/blob/master/docs/WASI-tutorial.md): Example of writing WebAssembly by hand at the bottom.
* [WASI reference](https://github.com/bytecodealliance/wasmtime/blob/master/docs/WASI-api.md): Doesn't quite match up with what `wasmtime` gave me? But still helps...
* [Understanding WebAssembly text format (MDN)](https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format)

