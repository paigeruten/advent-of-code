# `passcode.wat`

Luckily this problem was well-suited to WebAssembly, just like [day 1](../day01) and [day 2](../day02)!

I didn't learn many new things this time, but I got a lot of practice writing loops. It's interesting that you have to come up with *names* for *loops* when writing WebAssembly... I was not trained for this. I did remember that there's a `local.tee` instruction, which is exactly the same as `local.set` but also pushes the value to the stack for further use. So here is the idiom I used for a `for (int i = 0; i < 6; i++)` loop:

```wat
(local.set $i (i32.const 0))
(loop $each_char
  ;; Print out the value of $i
  (call $writeInt (local.get $i))

  ;; Increment $i, and then jump back to loop start if $i < 6
  (br_if $each_char
    (i32.lt_u
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (i32.const 6)))
)
```

## Usage

```
$ wasmtime passcode.wat < ../input/input04
925
607
```

It prints the solution to part 1, and then the solution to part 2.

