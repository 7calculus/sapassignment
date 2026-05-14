# ============================================================
# logical_parsing.s - Parsing + Advanced Commands Module
# CSC202B - RUAS Assignment 1
# Commands: FACTORIAL, FIBONACCI, POWER, ISPRIME, ISEVEN,
#           GCD, ABS, EVEN, ODD, MAX, MIN, SQUARE, CUBE
# ============================================================

.extern arg1_buf
.extern arg2_buf
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

.section .bss
    .comm input_buf_ref, 0      # just a reference, not redeclared

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

.extern input_buf
.extern keyword
.extern arg1_buf
.extern arg2_buf

# ============================================================
# parse_input
# Reads input_buf and separates into keyword, arg1_buf, arg2_buf
# Handles multiple spaces between tokens
# ============================================================
parse_input:
    pushq   %rbx
    pushq   %rcx
    pushq   %rdx

    # Clear keyword buffer
    leaq    keyword(%rip), %rdi
    movq    $32, %rcx
.clear_keyword:
    movb    $0, (%rdi)
    incq    %rdi
    loop    .clear_keyword

    # Clear arg1 buffer
    leaq    arg1_buf(%rip), %rdi
    movq    $32, %rcx
.clear_arg1:
    movb    $0, (%rdi)
    incq    %rdi
    loop    .clear_arg1

    # Clear arg2 buffer
    leaq    arg2_buf(%rip), %rdi
    movq    $32, %rcx
.clear_arg2:
    movb    $0, (%rdi)
    incq    %rdi
    loop    .clear_arg2

    leaq    input_buf(%rip), %rsi

    # Skip leading spaces
.skip_spaces_before_keyword:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    jne     .copy_keyword_start
    incq    %rsi
    jmp     .skip_spaces_before_keyword

    # Copy keyword
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

    # Skip spaces before arg1
.skip_spaces_before_arg1:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    jne     .copy_arg1_start
    incq    %rsi
    jmp     .skip_spaces_before_arg1

    # Copy arg1
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

    # Skip spaces before arg2
.skip_spaces_before_arg2:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .parse_done
    cmpb    $' ', %al
    jne     .copy_arg2_start
    incq    %rsi
    jmp     .skip_spaces_before_arg2

    # Copy arg2
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
# do_factorial: FACTORIAL n -> n!
# ============================================================
do_factorial:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx
    movq    $1, %rax
.fact_loop:
    cmpq    $1, %rcx
    jle     .fact_done
    imulq   %rcx, %rax
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
# do_fibonacci: FIBONACCI n -> nth term
# ============================================================
do_fibonacci:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx

    cmpq    $0, %rcx
    je      .fib_zero
    cmpq    $1, %rcx
    je      .fib_one

    movq    $0, %rax
    movq    $1, %rbx
    movq    $2, %rdx
.fib_loop:
    cmpq    %rcx, %rdx
    jg      .fib_done
    movq    %rbx, %r8
    addq    %rax, %rbx
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
# do_power: POWER a b -> a^b
# ============================================================
do_power:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx

    movq    $1, %rax
.pow_loop:
    cmpq    $0, %rcx
    je      .pow_done
    imulq   %rbx, %rax
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
# do_isprime: ISPRIME n
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

    movq    $2, %rcx
.prime_loop:
    movq    %rcx, %rax
    imulq   %rcx, %rax
    cmpq    %rbx, %rax
    jg      .is_prime
    movq    %rbx, %rax
    xorq    %rdx, %rdx
    divq    %rcx
    cmpq    $0, %rdx
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
# do_iseven: ISEVEN n
# ============================================================
do_iseven:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int

    testq   $1, %rbx
    jz      .iseven_yes
    leaq    msg_odd_l(%rip), %rdi
    call    print_str
    ret
.iseven_yes:
    leaq    msg_even_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_gcd: GCD a b
# ============================================================
do_gcd:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx

.gcd_loop:
    cmpq    $0, %rcx
    je      .gcd_done
    movq    %rbx, %rax
    xorq    %rdx, %rdx
    divq    %rcx
    movq    %rcx, %rbx
    movq    %rdx, %rcx
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
# do_abs: ABS n
# ============================================================
do_abs:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    cmpq    $0, %rax
    jge     .abs_done
    negq    %rax
.abs_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_even: EVEN n -> is it even?
# ============================================================
do_even:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int

    testq   $1, %rbx
    jz      .even_yes
    leaq    msg_odd_l(%rip), %rdi
    call    print_str
    ret
.even_yes:
    leaq    msg_even_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_odd: ODD n -> is it odd?
# ============================================================
do_odd:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int

    testq   $1, %rbx
    jnz     .odd_yes
    leaq    msg_even_l(%rip), %rdi
    call    print_str
    ret
.odd_yes:
    leaq    msg_odd_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_max: MAX a b -> larger of two
# ============================================================
do_max:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    cmpq    %rax, %rbx
    jge     .max_take_first
    jmp     .max_done
.max_take_first:
    movq    %rbx, %rax
.max_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_min: MIN a b -> smaller of two
# ============================================================
do_min:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    cmpq    %rax, %rbx
    jle     .min_take_first
    jmp     .min_done
.min_take_first:
    movq    %rbx, %rax
.min_done:
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_square: SQUARE n -> n^2
# ============================================================
do_square:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    imulq   %rax, %rax
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_cube: CUBE n -> n^3
# ============================================================
do_cube:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    imulq   %rbx, %rax
    imulq   %rbx, %rax
    leaq    result_lbl_l(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_l(%rip), %rdi
    call    print_str
    ret