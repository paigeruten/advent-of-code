(module
  (import "wasi_unstable" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory 1)
  (export "memory" (memory 0))

  ;; Memory layout:
  ;;   0..7: iovec for $getChar and $putChar
  ;;   8: "buffer" that's 1 byte in length, for $getChar and $putChar
  ;;   12..15: number of bytes read/written for $getChar and $putChar
  ;;   16..31: string buffer for $writeInt
  ;;   32..37: array of 6 bytes to store the current passcode
  ;;   38..43: array of 6 bytes to store the upper bound

  (func $main (export "_start")
    (local $num_valid_part1 i32)
    (local $num_valid_part2 i32)

    ;; Read initial passcode
    (call $readPasscode (i32.const 32))

    ;; Read and skip the '-' character
    (drop (call $getChar))

    ;; Read upper bound passcode
    (call $readPasscode (i32.const 38))

    ;; Loop through all passcodes in the range, counting how many meet the
    ;; criteria of both part 1 and part 2 of the puzzle.
    (local.set $num_valid_part1 (i32.const 0))
    (local.set $num_valid_part2 (i32.const 0))
    (loop $each_passcode
      (if (call $validPasscodePart1 (i32.const 32))
        (then
          (local.set $num_valid_part1
            (i32.add (local.get $num_valid_part1) (i32.const 1)))))

      (if (call $validPasscodePart2 (i32.const 32))
        (then
          (local.set $num_valid_part2
            (i32.add (local.get $num_valid_part2) (i32.const 1)))))

      (call $incrementPasscode (i32.const 32))

      (br_if $each_passcode (call $passcodeLte (i32.const 32) (i32.const 38)))
    )

    ;; Print solution to part 1
    (call $writeInt (local.get $num_valid_part1))
    (call $putChar (i32.const 10))

    ;; Print solution to part 2
    (call $writeInt (local.get $num_valid_part2))
    (call $putChar (i32.const 10))
  )

  ;; Read a 6-digit passcode from standard input into the buffer, as ASCII chars
  (func $readPasscode (param $buffer i32)
    (local $i i32)
    (local.set $i (i32.const 6))
    (loop $each_char
      (i32.store8 (local.get $buffer) (call $getChar))

      (local.set $buffer (i32.add (local.get $buffer) (i32.const 1)))

      (br_if $each_char
        (i32.gt_u
          (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
          (i32.const 0)))
    )
  )

  ;; Print a 6-digit passcode to standard output
  (func $printPasscode (param $passcode i32)
    (local $i i32)
    (local.set $i (i32.const 6))
    (loop $each_char
      (call $putChar (i32.load8_u (local.get $passcode)))

      (local.set $passcode (i32.add (local.get $passcode) (i32.const 1)))

      (br_if $each_char
        (i32.gt_u
          (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
          (i32.const 0)))
    )
    (call $putChar (i32.const 10))
  )

  ;; Does the passcode meet the criteria for part 1?
  (func $validPasscodePart1 (param $passcode i32) (result i32)
    (i32.and
      (call $passcodeNotDecreasing (local.get $passcode))
      (call $passcodeContainsDoubleDigits (local.get $passcode)))
  )

  ;; Does the passcode meet the criteria for part 2?
  (func $validPasscodePart2 (param $passcode i32) (result i32)
    (i32.and
      (call $passcodeNotDecreasing (local.get $passcode))
      (call $passcodeContainsFencedDoubleDigits (local.get $passcode)))
  )

  ;; Check that the passcode digits never decrease
  (func $passcodeNotDecreasing (param $passcode i32) (result i32)
    (local $i i32)
    (local.set $i (i32.const 5))
    (loop $each_char
      (if (i32.gt_u
            (i32.load8_u (local.get $passcode))
            (i32.load8_u (i32.add (local.get $passcode) (i32.const 1))))
        (then (return (i32.const 0))))

      (local.set $passcode (i32.add (local.get $passcode) (i32.const 1)))

      (br_if $each_char
        (i32.gt_u
          (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
          (i32.const 0)))
    )

    (i32.const 1)
  )

  ;; Check that the passcode contains two adjacent digits that are the same
  (func $passcodeContainsDoubleDigits (param $passcode i32) (result i32)
    (local $i i32)
    (local.set $i (i32.const 5))
    (loop $each_char
      (if (i32.eq
            (i32.load8_u (local.get $passcode))
            (i32.load8_u (i32.add (local.get $passcode) (i32.const 1))))
        (then (return (i32.const 1))))

      (local.set $passcode (i32.add (local.get $passcode) (i32.const 1)))

      (br_if $each_char
        (i32.gt_u
          (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
          (i32.const 0)))
    )

    (i32.const 0)
  )

  ;; Check that the passcode contains two adjacent digits that are the same,
  ;; that aren't part of a series of 3 or more adjacent digits that are the same
  (func $passcodeContainsFencedDoubleDigits (param $passcode i32) (result i32)
    (local $i i32)
    (local $current i32)
    (local $lookback1 i32)
    (local $lookback2 i32)
    (local $lookback3 i32)

    ;; For each digit we loop through, we're going to remember the 3 digits
    ;; that came before it. Then we'll check to see if the middle two digits
    ;; are the same and the outer two digits are different. To get all this
    ;; going though, we have to initialize the previous 3 characters to
    ;; some fake data that will not cause a false positive. As long as these
    ;; three initial values are outside the ASCII range '0' to '9', and are all
    ;; different from each other, it should work. So we just initialize them to
    ;; 0, 1, and 2.
    (local.set $lookback1 (i32.const 0))
    (local.set $lookback2 (i32.const 1))
    (local.set $lookback3 (i32.const 2))

    (local.set $i (i32.const 6))
    (loop $each_char
      (local.set $current (i32.load8_u (local.get $passcode)))

      (if (i32.and
            (i32.eq (local.get $lookback1) (local.get $lookback2))
            (i32.and
              (i32.ne (local.get $lookback2) (local.get $lookback3))
              (i32.ne (local.get $lookback1) (local.get $current))))
        (then (return (i32.const 1))))

      (local.set $lookback3 (local.get $lookback2))
      (local.set $lookback2 (local.get $lookback1))
      (local.set $lookback1 (local.get $current))

      (local.set $passcode (i32.add (local.get $passcode) (i32.const 1)))

      (br_if $each_char
        (i32.gt_u
          (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
          (i32.const 0)))
    )

    ;; If we got through the loop, we have a literal edge case to check: the
    ;; last two digits of the passcode, which are in $lookback1 and $lookback2.
    (i32.and
      (i32.eq (local.get $lookback1) (local.get $lookback2))
      (i32.ne (local.get $lookback2) (local.get $lookback3)))
  )

  ;; Increment the passcode, which is stored as an array of 6 ASCII digits.
  (func $incrementPasscode (param $passcode i32)
    (local $i i32)
    (local $digit i32)

    (local.set $i (i32.const 5))
    (loop $each_char
      (local.set $digit
        (i32.load8_u (i32.add (local.get $passcode) (local.get $i))))

      (if (i32.eq (local.get $digit) (i32.const 57)) ;; if $digit == ASCII '9'
        (then
          (i32.store8
            (i32.add (local.get $passcode) (local.get $i))
            (i32.const 48))) ;; set to ASCII '0'
        (else
          (i32.store8
            (i32.add (local.get $passcode) (local.get $i))
            (i32.add (local.get $digit) (i32.const 1)))
          ;; We could do a big optimization here: if we just incremented a digit
          ;; not in the ones place, we could set all the digits to the right of
          ;; it to the same digit to skip a bunch of numbers that wouldn't be
          ;; valid (because they'd all have decreasing digits).
          ;;
          ;; For example, 349999 would be incremented to 355555 instead of
          ;; 350000. That's a lot of numbers skipped! Unfortunately I don't
          ;; have time to do this at the moment.
          return))

      (br_if $each_char
        (i32.ge_s
          (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
          (i32.const 0)))
    )

    unreachable
  )

  ;; Check if our passcode has been incremented past the upper bound
  (func $passcodeLte (param $passcode1 i32) (param $passcode2 i32) (result i32)
    (local $i i32)
    (local $digit1 i32)
    (local $digit2 i32)

    (local.set $i (i32.const 6))
    (loop $each_char
      (local.set $digit1 (i32.load8_u (local.get $passcode1)))
      (local.set $digit2 (i32.load8_u (local.get $passcode2)))

      ;; If $digit1 > $digit2, return false immediately
      (if (i32.gt_u (local.get $digit1) (local.get $digit2))
        (then (return (i32.const 0))))

      ;; If $digit1 < $digit2, return true immediately
      (if (i32.lt_u (local.get $digit1) (local.get $digit2))
        (then (return (i32.const 1))))

      (local.set $passcode1 (i32.add (local.get $passcode1) (i32.const 1)))
      (local.set $passcode2 (i32.add (local.get $passcode2) (i32.const 1)))

      (br_if $each_char
        (i32.gt_u
          (local.tee $i (i32.sub (local.get $i) (i32.const 1)))
          (i32.const 0)))
    )

    ;; Return true if both passcodes are equal
    (i32.const 1)
  )

  ;;
  ;; -----------------------------------------------------------
  ;; | Functions below this line copied from ../day01/fuel.wat |
  ;; -----------------------------------------------------------
  ;;

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
