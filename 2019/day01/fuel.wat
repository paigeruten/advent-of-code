(module
  ;; Import fd_read and fd_write from WASI. These will let us read from stdin
  ;; and write to stdout.
  (import "wasi_unstable" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  ;; Ask for at least 1 page of memory (64 KiB).
  (memory 1)

  ;; Export memory so that (I presume) fd_read and fd_write can access the
  ;; memory address we give them.
  (export "memory" (memory 0))

  ;; Memory layout:
  ;;   0..7: iovec for $getChar and $putChar
  ;;   8: "buffer" that's 1 byte in length, for $getChar and $putChar
  ;;   12..15: number of bytes read/written for $getChar and $putChar
  ;;   16..31: string buffer for $writeInt

  ;; Main function, will execute automatically because it's exported as
  ;; "_start".
  (func $main (export "_start")
    (local $mass i32)
    (local $total_fuel i32)

    (local.set $total_fuel (i32.const 0))

    ;; Jumping to $read_nums_done will jump to the end of this block.
    (block $read_nums_done
      ;; Jumping to $read_nums will jump back to the beginning of this loop.
      (loop $read_nums
        ;; Read an int from stdin into $mass.
        (local.set $mass (call $readInt))

        ;; If it returned -1, that means end-of-file and so we break out of the
        ;; loop.
        (br_if $read_nums_done (i32.eq (i32.const -1) (local.get $mass)))

        ;; Calculate fuel needed for the current $mass, and add it to
        ;; $total_fuel.
        (local.set $total_fuel
          (i32.add
            (local.get $total_fuel)
            (call $calculateFuelRecursively (local.get $mass))
            ;; To solve part 1, change the above line to call $calculateFuel.
          )
        )

        ;; Jump back to beginning of loop.
        (br $read_nums)
      )
    )

    ;; Print the answer.
    (call $writeInt (local.get $total_fuel))

    ;; Print a newline character (ASCII code 10).
    (call $putChar (i32.const 10))
  )

  ;; Calculates fuel needed for $mass. (Does not calculate fuel needed for the
  ;; fuel.)
  (func $calculateFuel (param $mass i32) (result i32)
    (local $fuel i32)
    ;; $fuel = $mass / 3 - 2
    (local.set $fuel
      (i32.sub
        (i32.div_u (local.get $mass) (i32.const 3))
        (i32.const 2)))
    ;; Return $fuel, or 0 if $fuel is negative.
    (if (result i32) (i32.le_s (local.get $fuel) (i32.const 0))
      (then (i32.const 0))
      (else (local.get $fuel)))
  )

  ;; Calculates fuel needed for $mass, including the fuel needed for the fuel
  ;; needed for the fuel needed for the fuel ...
  (func $calculateFuelRecursively (param $mass i32) (result i32)
    (local $fuel i32)
    ;; Calculate fuel for $mass as usual.
    (local.set $fuel (call $calculateFuel (local.get $mass)))
    ;; If $fuel > 0, recursively calculate fuel needed for that $fuel.
    (if (result i32) (i32.eqz (local.get $fuel))
      (then
        (i32.const 0))
      (else
        (i32.add
          (local.get $fuel)
          (call $calculateFuelRecursively (local.get $fuel))))
    )
  )

  ;; Reads a number from stdin (converting string to int). Won't parse negative
  ;; numbers, returns -1 if there are no numbers left in the file.
  (func $readInt (result i32)
    (local $found_digit i32)
    (local $char i32)
    (local $num i32)

    ;; Whether we've read at least 1 digit.
    (local.set $found_digit (i32.const 0))
    (local.set $num (i32.const 0))

    (block $done
      (loop $read_chars
        ;; Read a character from stdin (will be -1 if end-of-file).
        (local.set $char (call $getChar))

        ;; Check if it's a digit.
        (if (call $isDigit (local.get $char))
          (then
            (local.set $found_digit (i32.const 1))
            ;; Multiply $num by 10, and add the digit to it after converting it
            ;; to an int (by subtracting 48, the ASCII code for '0').
            (local.set $num
              (i32.add
                (i32.mul (local.get $num) (i32.const 10))
                (i32.sub (local.get $char) (i32.const 48)))))
          (else
            ;; If it's not a digit, and we've found at least one digit, then
            ;; we're done and ready to return the number.
            (br_if $done (local.get $found_digit))
            ;; If it's not a digit, and we haven't found any digits, and we've
            ;; reached the end-of-file (-1), then there's no number to return
            ;; and we're done.
            (br_if $done (i32.eq (i32.const -1) (local.get $char))))
        )

        ;; Loop back to read the next char.
        (br $read_chars)
      )
    )

    ;; If we found at least one digit, then we have a number to return.
    ;; Otherwise, we must have hit the end-of-file without reading a number,
    ;; and we return -1 to communicate that.
    (if (result i32) (local.get $found_digit)
      (then (local.get $num))
      (else (i32.const -1)))
  )

  ;; Returns 1 if the character is a digit (in the range '0'..'9', i.e. ASCII
  ;; codes 48..57), otherwise returns 0.
  (func $isDigit (param $char i32) (result i32)
    (i32.and
      (i32.ge_u (local.get $char) (i32.const 48))
      (i32.le_u (local.get $char) (i32.const 57))))

  ;; Converts an int to a string and prints it to stdout.
  (func $writeInt (param $num i32)
    (local $buf i32)
    (local $buf_end i32)

    ;; Buffer to hold the digit characters of the int, starting at memory
    ;; address 16.
    (local.set $buf (i32.const 16))
    (local.set $buf_end (i32.const 16))

    ;; When converting an int to a string, it's natural to do it in reverse.
    ;; Each digit will be written to a buffer, starting with the least
    ;; significant digit. Then we'll loop through the buffer backwards to print
    ;; out the digits in the correct order.
    (loop $digits_to_chars
      ;; Convert the least significant digit in $num to an ASCII character (by
      ;; adding 48, the ASCII code for '0'), and store it in the next byte of
      ;; our buffer.
      (i32.store8
        (local.get $buf_end)
        (i32.add (i32.const 48)
                 (i32.rem_u (local.get $num) (i32.const 10))))
      ;; Increment $buf_end by 1.
      (local.set $buf_end (i32.add (i32.const 1) (local.get $buf_end)))
      ;; Divide $num by 10.
      (local.set $num (i32.div_u (local.get $num) (i32.const 10)))
      ;; Loop until $num is 0.
      (br_if $digits_to_chars (i32.ne (i32.const 0) (local.get $num))))

    ;; Print out the digits by looping over the buffer in reverse.
    (loop $write_digits
      ;; Decrement $buf_end by 1;
      (local.set $buf_end (i32.sub (local.get $buf_end) (i32.const 1)))
      ;; Print the character pointed at by $buf_end.
      (call $putChar (i32.load8_u (local.get $buf_end)))
      ;; Loop until $buf_end has reached the beginning of the buffer.
      (br_if $write_digits (i32.gt_u (local.get $buf_end) (local.get $buf))))
  )

  ;; Reads a single character from stdin. Returns -1 if the end-of-file was
  ;; reached.
  (func $getChar (result i32)
    ;; Set up an iovec struct at memory address 0 to tell fd_read where in
    ;; memory to read input into. The first field (memory address 0) is the
    ;; memory address of the buffer, which is memory address 8. The second
    ;; field (memory address 4) is the length of the buffer, which is 1.
    ;;
    ;; Using a buffer of length 1 means that every call to getChar will have to
    ;; perform IO. It would probably be way faster to read input in larger
    ;; blocks at a time, and then most calls to getChar could just read from an
    ;; internal buffer in memory to get the next char. But I don't have time to
    ;; implement that.
    (i32.store (i32.const 0) (i32.const 8))
    (i32.store (i32.const 4) (i32.const 1))

    ;; Read a character from stdin into our 1-byte buffer.
    (call $fd_read
      (i32.const 0) ;; File descriptor 0 is stdin
      (i32.const 0) ;; Memory address of array of iovec structs
      (i32.const 1) ;; Number of iovec structs in array
      (i32.const 12) ;; Memory address to store the number of bytes read
    )
    ;; Drop the return value, we're not gonna use it.
    drop

    ;; If number of bytes read (available in memory address 12) was 1, return
    ;; the character in our buffer (at memory address 8). Otherwise return -1
    ;; to indicate end-of-file.
    (if (result i32)
      (i32.eq (i32.const 1) (i32.load (i32.const 12)))
      (then (i32.load8_u (i32.const 8)))
      (else (i32.const -1))
    )
  )

  ;; Writes a single character to stdout.
  (func $putChar (param $c i32)
    ;; fd_write also uses iovec structs. The first field is the buffer of data
    ;; we want to write, and the second field is the length of the buffer. Once
    ;; again, we use memory address 8 for our buffer of length 1.
    (i32.store (i32.const 0) (i32.const 8))
    (i32.store (i32.const 4) (i32.const 1))

    ;; Store the given character into our 1-byte buffer.
    (i32.store8 (i32.const 8) (local.get $c))

    ;; Write the character to stdout.
    (call $fd_write
      (i32.const 1) ;; File descriptor 1 is stdout
      (i32.const 0) ;; Memory address of array of iovec structs
      (i32.const 1) ;; Number of iovec structs in array
      (i32.const 12) ;; Memory address to store the number of bytes written
    )
    ;; Drop the return value, we're not gonna use it.
    drop
  )
)
