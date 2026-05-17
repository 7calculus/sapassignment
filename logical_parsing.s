# ============================================================
# logical_parsing.s - Parsing and Advanced Commands Module
# CSC202B - RUAS Assignment 1
# Vanshika: Input parsing + FACTORIAL, FIBONACCI, POWER,
#           ISPRIME, ISEVEN, GCD, ABS, EVEN, ODD,
#           MAX, MIN, SQUARE, CUBE
# ============================================================
# Team Credits:
#   Vanshika - All parsing logic and advanced command routines
# ============================================================

.extern arg1_buf
.extern arg2_buf
.extern input_buf
.extern keyword
.extern str_to_int
.extern print_int
.extern print_str

.section .data
result_lbl_l:   .string "Result: "
newline_l:      .string "\n"
msg_prime_l:    .string " is PRIME\n"
msg_notprime_l: .string " is NOT PRIME\n"
msg_even_l:     .string " is EVEN\n"
msg_odd_l:      .string " is ODD\n"

.section .text
.global parse_input
.global do_factorial
.global do_fibonacci
.global do_power
.global do_isprime
.global do_iseven
.global do_gcd
.global do_abs
.global do_even
.global do_odd
.global do_max
.global do_min
.global do_square
.global do_cube

# ============================================================
# parse_input
# Vanshika: Reads input_buf and separates into:
#   keyword  = command name
#   arg1_buf = first argument
#   arg2_buf = second argument
# Also handles extra spaces between command and arguments.
# ============================================================
parse_input:
    pushq   %rbx
    pushq   %rcx
    pushq   %rdx

    # Vanshika: Clear keyword buffer
    leaq    keyword(%rip), %rdi
    movq    $32, %rcx
.clear_keyword:
    movb    $0, (%rdi)
    incq    %rdi
    loop    .clear_keyword

    # Vanshika: Clear arg1 buffer
    leaq    arg1_buf(%rip), %rdi
    movq    $32, %rcx
.clear_arg1:
    movb    $0, (%rdi)
    incq    %rdi
    loop    .clear_arg1

    # Vanshika: Clear arg2 buffer
    leaq    arg2_buf(%rip), %rdi
    movq    $32, %rcx
.clear_arg2:
    movb    $0, (%rdi)
    incq    %rdi
    loop    .clear_arg2

    leaq    input_buf(%rip), %rsi

    # Vanshika: Skip leading spaces before command keyword
.skip_spaces_before_keyword:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    jne     .copy_keyword_start
    incq    %rsi
    jmp     .skip_spaces_before_keyword

    # Vanshika: Copy command keyword character by character
.copy_keyword_start:
    leaq    keyword(%rip), %rdi
.copy_keyword:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    je      .skip_spaces_before_arg1
    movb    %al, (%rdi)
    incq    %rsi
    incq    %rdi
    jmp     .copy_keyword

    # Vanshika: Skip spaces before first argument
.skip_spaces_before_arg1:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    jne     .copy_arg1_start
    incq    %rsi
    jmp     .skip_spaces_before_arg1

    # Vanshika: Copy first argument
.copy_arg1_start:
    leaq    arg1_buf(%rip), %rdi
.copy_arg1:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    je      .skip_spaces_before_arg2
    movb    %al, (%rdi)
    incq    %rsi
    incq    %rdi
    jmp     .copy_arg1

    # Vanshika: Skip spaces before second argument
.skip_spaces_before_arg2:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    jne     .copy_arg2_start
    incq    %rsi
    jmp     .skip_spaces_before_arg2

    # Vanshika: Copy second argument
.copy_arg2_start:
    leaq    arg2_buf(%rip), %rdi
.copy_arg2:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    je      .parse_done
    movb    %al, (%rdi)
    incq    %rsi
    incq    %rdi
    jmp     .copy_arg2

.parse_done:
    popq    %rdx
    popq    %rcx
    popq    %rbx
    ret

# ============================================================
# do_factorial
# Vanshika: Computes n! iteratively
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: <n!>"
# ============================================================
do_factorial:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx              # Vanshika: counter = n
    movq    $1, %rax                # Vanshika: accumulator = 1
.fact_loop:
    cmpq    $1, %rcx
    jle     .fact_done
    imulq   %rcx, %rax              # Vanshika: acc = acc * counter
    decq    %rcx
    jmp     .fact_loop
.fact_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_fibonacci
# Vanshika: Computes nth Fibonacci term iteratively
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: <fib(n)>"
# ============================================================
do_fibonacci:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx

    cmpq    $0, %rcx
    je      .fib_zero
    cmpq    $1, %rcx
    je      .fib_one

    movq    $0, %rax                # Vanshika: fib(n-2)
    movq    $1, %rbx                # Vanshika: fib(n-1)
    movq    $2, %rdx                # Vanshika: loop counter
.fib_loop:
    cmpq    %rcx, %rdx
    jg      .fib_done
    movq    %rbx, %r8
    addq    %rax, %rbx              # Vanshika: next = prev + curr
    movq    %r8, %rax
    incq    %rdx
    jmp     .fib_loop
.fib_zero:
    movq    $0, %rax
    jmp     .fib_print
.fib_one:
    movq    $1, %rax
    jmp     .fib_print
.fib_done:
    movq    %rbx, %rax
.fib_print:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_power
# Vanshika: Computes base^exponent iteratively
# INPUT: arg1_buf = base, arg2_buf = exponent
# OUTPUT: Prints "Result: <base^exp>"
# ============================================================
do_power:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Vanshika: base

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx              # Vanshika: exponent

    movq    $1, %rax                # Vanshika: result = 1
.pow_loop:
    cmpq    $0, %rcx
    je      .pow_done
    imulq   %rbx, %rax              # Vanshika: result = result * base
    decq    %rcx
    jmp     .pow_loop
.pow_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_isprime
# Vanshika: Checks if n is prime by trial division
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: n is PRIME/NOT PRIME"
# ============================================================
do_isprime:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int

    cmpq    $2, %rbx
    jl      .not_prime
    je      .is_prime

    movq    $2, %rcx                # Vanshika: trial divisor starts at 2
.prime_loop:
    movq    %rcx, %rax
    imulq   %rcx, %rax              # Vanshika: if divisor^2 > n, it's prime
    cmpq    %rbx, %rax
    jg      .is_prime
    movq    %rbx, %rax
    xorq    %rdx, %rdx
    divq    %rcx
    cmpq    $0, %rdx                # Vanshika: if remainder = 0, not prime
    je      .not_prime
    incq    %rcx
    jmp     .prime_loop
.is_prime:
    leaq    msg_prime_l(%rip), %rdi
    call    print_str
    ret
.not_prime:
    leaq    msg_notprime_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_iseven
# Vanshika: Checks if n is even or odd using bitwise AND
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: n is EVEN/ODD"
# ============================================================
do_iseven:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int

    testq   $1, %rbx                # Vanshika: check last bit (0=even, 1=odd)
    jz      .iseven_yes
    leaq    msg_odd_l(%rip), %rdi
    call    print_str
    ret
.iseven_yes:
    leaq    msg_even_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_gcd
# Vanshika: Computes GCD using Euclidean algorithm
# INPUT: arg1_buf = a, arg2_buf = b
# OUTPUT: Prints "Result: <gcd(a,b)>"
# ============================================================
do_gcd:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx

.gcd_loop:                          # Vanshika: Euclidean algorithm
    cmpq    $0, %rcx
    je      .gcd_done
    movq    %rbx, %rax
    xorq    %rdx, %rdx
    divq    %rcx
    movq    %rcx, %rbx
    movq    %rdx, %rcx              # Vanshika: gcd(b, a mod b)
    jmp     .gcd_loop
.gcd_done:
    movq    %rbx, %rax
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_abs
# Vanshika: Returns absolute value of n
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: |n|"
# ============================================================
do_abs:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    cmpq    $0, %rax
    jge     .abs_done
    negq    %rax                    # Vanshika: negate if negative
.abs_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_even
# Vanshika: Checks if n is even (parity check)
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: n is EVEN/ODD"
# ============================================================
do_even:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int

    testq   $1, %rbx                # Vanshika: check last bit
    jz      .even_yes
    leaq    msg_odd_l(%rip), %rdi
    call    print_str
    ret
.even_yes:
    leaq    msg_even_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_odd
# Vanshika: Checks if n is odd (parity check)
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: n is ODD/EVEN"
# ============================================================
do_odd:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int

    testq   $1, %rbx                # Vanshika: check last bit
    jnz     .odd_yes
    leaq    msg_even_l(%rip), %rdi
    call    print_str
    ret
.odd_yes:
    leaq    msg_odd_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_max
# Vanshika: Returns the larger of two numbers
# INPUT: arg1_buf = a, arg2_buf = b
# OUTPUT: Prints "Result: <max(a,b)>"
# ============================================================
do_max:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Vanshika: save first number

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int              # Vanshika: rax = second number

    cmpq    %rax, %rbx             # Vanshika: compare first and second
    jge     .max_take_first
    jmp     .max_done
.max_take_first:
    movq    %rbx, %rax              # Vanshika: first is larger
.max_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_min
# Vanshika: Returns the smaller of two numbers
# INPUT: arg1_buf = a, arg2_buf = b
# OUTPUT: Prints "Result: <min(a,b)>"
# ============================================================
do_min:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Vanshika: save first number

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int              # Vanshika: rax = second number

    cmpq    %rax, %rbx             # Vanshika: compare first and second
    jle     .min_take_first
    jmp     .min_done
.min_take_first:
    movq    %rbx, %rax              # Vanshika: first is smaller
.min_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_square
# Vanshika: Computes n^2
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: <n^2>"
# ============================================================
do_square:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    imulq   %rax, %rax              # Vanshika: n * n
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_cube
# Vanshika: Computes n^3
# INPUT: arg1_buf = n
# OUTPUT: Prints "Result: <n^3>"
# ============================================================
do_cube:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    imulq   %rbx, %rax              # Vanshika: n * n
    imulq   %rbx, %rax              # Vanshika: n^2 * n = n^3
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret