(module
  (import "wasi_unstable" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory 1)
  (export "memory" (memory 0))

  ;; Use a wasm table as a jump table for executing instructions. This line
  ;; declares a table (there can only be one table per wasm module currently)
  ;; of length 3, and the next line adds functions to the table starting from
  ;; index 1 (since there is no opcode 0).
  ;;
  ;; The functions in this table can then be called using call_indirect. For
  ;; example, to call the multiply instruction (opcode 2) you could do:
  ;;
  ;;     (call_indirect (type $instructionType) (i32.const 2))
  ;;
  (table 3 funcref)
  (elem (i32.const 1)
    $addInstruction      ;; opcode 1
    $multiplyInstruction ;; opcode 2
  )

  ;; Type of the functions in the jump table. The first param is a pointer to
  ;; the beginning of the program, and the second param is a pointer to the
  ;; current instruction. The result is the length of the instruction, which is
  ;; how much to advance the instruction pointer after executing this
  ;; instruction.
  (type $instructionType (func (param i32 i32) (result i32)))

  ;; Memory layout:
  ;;   0..7: iovec for $getChar and $putChar
  ;;   8: "buffer" that's 1 byte in length, for $getChar and $putChar
  ;;   12..15: number of bytes read/written for $getChar and $putChar
  ;;   16..31: string buffer for $writeInt
  ;;   32..1023: buffer of ints for storing the intcode program
  ;;   1024..*: rest of memory used for executing the intcode program

  (func $main (export "_start")
    (call $loadIntcodeProgram (i32.const 32))

    ;; Solve part 1
    (call $memcpyInts (i32.const 32) (i32.const 1024) (i32.const 992))
    (call $patchIntcodeProgram (i32.const 1024) (i32.const 12) (i32.const 2))
    (call $executeIntcodeProgram (i32.const 1024))
    (call $writeInt (i32.load (i32.const 1024)))
    (call $putChar (i32.const 10))

    ;; Solve part 2
    (call $bruteForceInputs (i32.const 32) (i32.const 19690720))
  )

  ;; Solves part 2 by trying every possible "noun" and "verb". The $target is
  ;; the output of the intcode program for the inputs we are trying to find.
  (func $bruteForceInputs (param $program i32) (param $target i32)
    (local $noun i32)
    (local $verb i32)
    (local $found_it i32)

    (local.set $found_it (i32.const 0))

    (block $end_brute_force
      ;; for $noun = 0 to 99
      (local.set $noun (i32.const 0))
      (loop $each_noun
        ;; for $verb = 0 to 99
        (local.set $verb (i32.const 0))
        (loop $each_verb
          ;; Make a copy of the original program (because each time the program
          ;; is run, it modifies its own code), patch it with the inputs, and
          ;; execute it.
          (call $memcpyInts (local.get $program) (i32.const 1024) (i32.const 992))
          (call $patchIntcodeProgram (i32.const 1024) (local.get $noun) (local.get $verb))
          (call $executeIntcodeProgram (i32.const 1024))

          ;; The result of the program is in memory address 1024. Check to see
          ;; if this is the output we're looking for.
          (if (i32.eq (i32.load (i32.const 1024)) (local.get $target))
            (then
              (local.set $found_it (i32.const 1))
              (br $end_brute_force)))

          (local.set $verb (i32.add (local.get $verb) (i32.const 1)))
          (br_if $each_verb (i32.le_u (local.get $verb) (i32.const 99)))
        )

        (local.set $noun (i32.add (local.get $noun) (i32.const 1)))
        (br_if $each_noun (i32.le_u (local.get $noun) (i32.const 99)))
      )
    )

    ;; If we found the target output, print out the result of
    ;; 100 * $noun + $verb as the puzzle requires. Otherwise, print out an "X".
    (if (local.get $found_it)
      (then
        (call $writeInt
          (i32.add
            (i32.mul (local.get $noun) (i32.const 100))
            (local.get $verb)))
        (call $putChar (i32.const 10)))
      (else
        (call $putChar (i32.const 88))
        (call $putChar (i32.const 10))))
  )

  ;; Reads an intcode program from stdin, into the given $buffer.
  (func $loadIntcodeProgram (param $buffer i32)
    (local $num i32)

    (block $read_nums_done
      (loop $read_nums
        (local.set $num (call $readInt))

        (br_if $read_nums_done (i32.eq (i32.const -1) (local.get $num)))

        (i32.store (local.get $buffer) (local.get $num))
        (local.set $buffer (i32.add (local.get $buffer) (i32.const 4)))

        (br $read_nums)
      )
    )
  )

  ;; Copies an intcode program (or any array of ints really) from one address
  ;; in memory to another.
  (func $memcpyInts (param $from i32) (param $to i32) (param $num i32)
    (block $done
      (loop $copy_ints
        (br_if $done (i32.eqz (local.get $num)))
        (i32.store (local.get $to) (i32.load (local.get $from)))
        (local.set $from (i32.add (local.get $from) (i32.const 4)))
        (local.set $to (i32.add (local.get $to) (i32.const 4)))
        (local.set $num (i32.sub (local.get $num) (i32.const 1)))
        (br $copy_ints))))

  ;; Write the two inputs into the intcode program (the "noun" and the "verb").
  (func $patchIntcodeProgram (param $program i32) (param $noun i32) (param $verb i32)
    (i32.store
      (i32.add (local.get $program) (i32.const 4))
      (local.get $noun))
    (i32.store
      (i32.add (local.get $program) (i32.const 8))
      (local.get $verb))
  )

  ;; Execute an intcode program.
  (func $executeIntcodeProgram (param $program i32)
    (local $ip i32)
    (local $opcode i32)
    (local $instruction_length i32)

    (local.set $ip (local.get $program))

    (block $halt
      (loop $interpreter
        (local.set $opcode (i32.load (local.get $ip)))

        ;; Handle opcode 99 as a special case - it breaks out of the
        ;; interpreter loop, halting the program.
        (br_if $halt (i32.eq (local.get $opcode) (i32.const 99)))

        ;; For other opcodes, call into the jump table using the opcode as the
        ;; index. This will end up calling either $addInstruction or
        ;; $multiplyInstruction.
        (local.get $program) ;; Param 1 to instruction function
        (local.get $ip)      ;; Param 2 to instruction function
        (call_indirect (type $instructionType) (local.get $opcode))
        (local.set $instruction_length) ;; Result of instruction function

        ;; Increment instruction pointer by however long the previous
        ;; instruction claimed to be.
        (local.set $ip
          (i32.add
            (local.get $ip)
            (i32.mul (local.get $instruction_length) (i32.const 4))))

        (br $interpreter)
      )
    )
  )

  ;; Helper for instruction functions to turn a parameter into the address in
  ;; memory that the param points to.
  ;;
  ;; So if $ip points to the instruction "1,3,4,5" and $program is 1024, and
  ;; $index is 2, then the result will be:
  ;;
  ;;       $program + $ip[2] * 4                Note: multiply by 4 because an
  ;;     = 1024 + 4 * 4                               int is 4 bytes.
  ;;     = 1040
  ;;
  (func $getParamAddress (param $program i32) (param $ip i32) (param $index i32) (result i32)
    (i32.add
      (local.get $program)
      (i32.mul
        (i32.const 4)
        (i32.load
          (i32.add
            (local.get $ip)
            (i32.mul (local.get $index) (i32.const 4)))))))

  ;; 1,A,B,C: mem[C] = mem[A] + mem[B]
  (func $addInstruction (param $program i32) (param $ip i32) (result i32)
    (i32.store
      (call $getParamAddress (local.get $program) (local.get $ip) (i32.const 3))
      (i32.add
        (i32.load
          (call $getParamAddress
            (local.get $program)
            (local.get $ip)
            (i32.const 1)))
        (i32.load
          (call $getParamAddress
            (local.get $program)
            (local.get $ip)
            (i32.const 2)))))
    (i32.const 4)
  )

  ;; 1,A,B,C: mem[C] = mem[A] * mem[B]
  (func $multiplyInstruction (param $program i32) (param $ip i32) (result i32)
    (i32.store
      (call $getParamAddress (local.get $program) (local.get $ip) (i32.const 3))
      (i32.mul
        (i32.load
          (call $getParamAddress
            (local.get $program)
            (local.get $ip)
            (i32.const 1)))
        (i32.load
          (call $getParamAddress
            (local.get $program)
            (local.get $ip)
            (i32.const 2)))))
    (i32.const 4)
  )

  ;;
  ;; -----------------------------------------------------------
  ;; | Functions below this line copied from ../day01/fuel.wat |
  ;; -----------------------------------------------------------
  ;;

  (func $readInt (result i32)
    (local $found_digit i32)
    (local $char i32)
    (local $num i32)

    (local.set $found_digit (i32.const 0))
    (local.set $num (i32.const 0))

    (block $done
      (loop $read_chars
        (local.set $char (call $getChar))

        (if (call $isDigit (local.get $char))
          (then
            (local.set $found_digit (i32.const 1))
            (local.set $num
              (i32.add
                (i32.mul (local.get $num) (i32.const 10))
                (i32.sub (local.get $char) (i32.const 48)))))
          (else
            (br_if $done (local.get $found_digit))
            (br_if $done (i32.eq (i32.const -1) (local.get $char))))
        )

        (br $read_chars)
      )
    )

    (if (result i32) (local.get $found_digit)
      (then (local.get $num))
      (else (i32.const -1)))
  )

  (func $isDigit (param $char i32) (result i32)
    (i32.and
      (i32.ge_u (local.get $char) (i32.const 48))
      (i32.le_u (local.get $char) (i32.const 57))))

  (func $writeInt (param $num i32)
    (local $buf i32)
    (local $buf_end i32)

    (local.set $buf (i32.const 16))
    (local.set $buf_end (i32.const 16))

    (loop $digits_to_chars
      (i32.store8
        (local.get $buf_end)
        (i32.add (i32.const 48)
                 (i32.rem_u (local.get $num) (i32.const 10))))
      (local.set $buf_end (i32.add (i32.const 1) (local.get $buf_end)))
      (local.set $num (i32.div_u (local.get $num) (i32.const 10)))
      (br_if $digits_to_chars (i32.ne (i32.const 0) (local.get $num))))

    (loop $write_digits
      (local.set $buf_end (i32.sub (local.get $buf_end) (i32.const 1)))
      (call $putChar (i32.load8_u (local.get $buf_end)))
      (br_if $write_digits (i32.gt_u (local.get $buf_end) (local.get $buf))))
  )

  (func $getChar (result i32)
    (i32.store (i32.const 0) (i32.const 8))
    (i32.store (i32.const 4) (i32.const 1))

    (call $fd_read
      (i32.const 0)
      (i32.const 0)
      (i32.const 1)
      (i32.const 12)
    )
    drop

    (if (result i32)
      (i32.eq (i32.const 1) (i32.load (i32.const 12)))
      (then (i32.load8_u (i32.const 8)))
      (else (i32.const -1))
    )
  )

  (func $putChar (param $c i32)
    (i32.store (i32.const 0) (i32.const 8))
    (i32.store (i32.const 4) (i32.const 1))

    (i32.store8 (i32.const 8) (local.get $c))

    (call $fd_write
      (i32.const 1)
      (i32.const 0)
      (i32.const 1)
      (i32.const 12)
    )
    drop
  )
)
