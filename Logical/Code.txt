# ============================================================
# Simplified Command Interpreter - CSC202B Assignment 1
# AT&T Syntax - Assembled with GAS (GNU Assembler)
# Assemble: gcc -no-pie -o interpreter code.s
# ============================================================

.section .data

prompt:         .string ">> "
newline:        .string "\n"
err_msg:        .string "ERROR: Invalid or unsupported command. Please try again.\n"
err_arg:        .string "ERROR: Missing required argument.\n"
result_lbl:     .string "Result: "

# # Tanya Shedde: Descriptive Help Message and Validation Strings
err_numeric:    .string "ERROR: Argument must be a numeric integer.\n"
err_overflow:   .string "ERROR: Number too large for 64-bit calculation.\n"
help_msg:       .string "--- Command Guide ---\n 2-Arg Math: ADD, SUB, MUL, DIV, MOD, POWER (a^b), GCD (Greatest Common Divisor)\n 2-Arg Comparison: MAX (Larger), MIN (Smaller)\n 1-Arg Math: FACTORIAL (n!), FIBONACCI (nth term), SQUARE (n^2), CUBE (n^3)\n 1-Arg Logic: ISPRIME (Prime Check), ISEVEN (Even Check), ABS (Absolute), EVEN/ODD (Parity Check)\n 0-Arg: HELP (Show this guide), EXIT (Quit)\n Usage: [COMMAND] [ARG1] [ARG2]\n"

# Command Dictionary
cmd_add:        .string "ADD"
cmd_sub:        .string "SUB"
cmd_mul:        .string "MUL"
cmd_div:        .string "DIV"
cmd_mod:        .string "MOD"
cmd_factorial:  .string "FACTORIAL"
cmd_fibonacci:  .string "FIBONACCI"
cmd_power:      .string "POWER"
cmd_isprime:    .string "ISPRIME"
cmd_iseven:     .string "ISEVEN"
cmd_gcd:        .string "GCD"
cmd_abs:        .string "ABS"
cmd_even:       .string "EVEN"       # Tanya Shedde
cmd_odd:        .string "ODD"        # Tanya Shedde
cmd_max:        .string "MAX"        # Tanya Shedde
cmd_min:        .string "MIN"        # Tanya Shedde
cmd_square:     .string "SQUARE"     # Tanya Shedde
cmd_cube:       .string "CUBE"       # Tanya Shedde
cmd_help:       .string "HELP"       # Tanya Shedde
cmd_exit:       .string "EXIT"

msg_prime:      .string " is PRIME\n"
msg_notprime:   .string " is NOT PRIME\n"
msg_even:       .string " is EVEN\n"
msg_odd:        .string " is ODD\n"

banner:         .string "==============================\n Simple Command Interpreter\n CSC202B - RUAS Assignment 1\n==============================\n Commands: ADD, SUB, MUL, DIV, MOD,\n  FACTORIAL, FIBONACCI, POWER,\n  ISPRIME, ISEVEN, GCD, ABS,\n  EVEN, ODD, MAX, MIN, SQUARE, CUBE\n Type HELP for instructions.\n==============================\n"

.section .bss
    input_buf:  .space 128
    keyword:    .space 32
    arg1_buf:   .space 32
    arg2_buf:   .space 32
    num_buf:    .space 32

.section .text
.global main

# ============================================================
# main - entry point
# ============================================================
main:
    leaq    banner(%rip), %rdi
    call    print_str

.main_loop:
    leaq    prompt(%rip), %rdi
    call    print_str

    movq    $0, %rax
    movq    $0, %rdi
    leaq    input_buf(%rip), %rsi
    movq    $128, %rdx
    syscall

    movq    %rax, %rbx
    decq    %rbx
    leaq    input_buf(%rip), %rdi
    movb    $0, (%rdi, %rbx, 1)

    # Tanya Shedde: Empty Input Handling
    cmpb    $0, (%rdi)
    je      .main_loop

    leaq    input_buf(%rip), %rdi
    leaq    cmd_exit(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .done

    call    parse_input
    call    dispatch

    jmp     .main_loop

.done:
    movq    $60, %rax
    xorq    %rdi, %rdi
    syscall

# ============================================================
# parse_input - splits input_buf into keyword, arg1, arg2
# ### TEAM MEMBER 2: INSERT IMPROVED PARSING LOGIC HERE ###
# ============================================================
parse_input:
    pushq   %rbx
    pushq   %rcx
    pushq   %rdx

    leaq    input_buf(%rip), %rsi
    leaq    keyword(%rip), %rdi

.copy_keyword:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .done_keyword
    cmpb    $' ', %al
    je      .done_keyword
    movb    %al, (%rdi)
    incq    %rsi
    incq    %rdi
    jmp     .copy_keyword

.done_keyword:
    movb    $0, (%rdi)
    cmpb    $' ', (%rsi)
    jne     .parse_done
    incq    %rsi

    leaq    arg1_buf(%rip), %rdi

.copy_arg1:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .done_arg1
    cmpb    $' ', %al
    je      .done_arg1
    movb    %al, (%rdi)
    incq    %rsi
    incq    %rdi
    jmp     .copy_arg1

.done_arg1:
    movb    $0, (%rdi)
    cmpb    $' ', (%rsi)
    jne     .parse_done
    incq    %rsi

    leaq    arg2_buf(%rip), %rdi

.copy_arg2_loop:
    movb    (%rsi), %al
    cmpb    $0, %al
    je      .done_arg2
    movb    %al, (%rdi)
    incq    %rsi
    incq    %rdi
    jmp     .copy_arg2_loop

.done_arg2:
    movb    $0, (%rdi)

.parse_done:
    popq    %rdx
    popq    %rcx
    popq    %rbx
    ret

# ============================================================
# dispatch - match keyword and jump to routine
# ============================================================
dispatch:
    leaq    keyword(%rip), %rdi
    
    # # Tanya Shedde: HELP Command Routing
    leaq    cmd_help(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      do_help

    # 2-Argument Commands
    leaq    cmd_add(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_add

    leaq    cmd_sub(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_sub

    leaq    cmd_mul(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_mul

    leaq    cmd_div(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_div

    leaq    cmd_mod(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_mod

    leaq    cmd_power(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_power

    leaq    cmd_gcd(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_gcd

    leaq    cmd_max(%rip), %rsi     # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_max           # Tanya Shedde

    leaq    cmd_min(%rip), %rsi     # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_min           # Tanya Shedde

    # 1-Argument Commands
    leaq    cmd_factorial(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_factorial

    leaq    cmd_fibonacci(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_fibonacci

    leaq    cmd_isprime(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_isprime

    leaq    cmd_iseven(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_iseven

    leaq    cmd_abs(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_abs

    leaq    cmd_even(%rip), %rsi    # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_even          # Tanya Shedde

    leaq    cmd_odd(%rip), %rsi     # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_odd           # Tanya Shedde

    leaq    cmd_square(%rip), %rsi  # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_square        # Tanya Shedde

    leaq    cmd_cube(%rip), %rsi    # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_cube          # Tanya Shedde

    leaq    err_msg(%rip), %rdi
    call    print_str
    ret

.dispatch_add:       call .val_2_args; jz .skip; jmp do_add
.dispatch_sub:       call .val_2_args; jz .skip; jmp do_sub
.dispatch_mul:       call .val_2_args; jz .skip; jmp do_mul
.dispatch_div:       call .val_2_args; jz .skip; jmp do_div
.dispatch_mod:       call .val_2_args; jz .skip; jmp do_mod
.dispatch_power:     call .val_2_args; jz .skip; jmp do_power
.dispatch_gcd:       call .val_2_args; jz .skip; jmp do_gcd
.dispatch_max:       call .val_2_args; jz .skip; jmp do_max     # Tanya Shedde
.dispatch_min:       call .val_2_args; jz .skip; jmp do_min     # Tanya Shedde

.dispatch_factorial: call .val_1_arg; jz .skip; jmp do_factorial
.dispatch_fibonacci: call .val_1_arg; jz .skip; jmp do_fibonacci
.dispatch_isprime:   call .val_1_arg; jz .skip; jmp do_isprime
.dispatch_iseven:    call .val_1_arg; jz .skip; jmp do_iseven
.dispatch_abs:       call .val_1_arg; jz .skip; jmp do_abs
.dispatch_even:      call .val_1_arg; jz .skip; jmp do_even      # Tanya Shedde
.dispatch_odd:       call .val_1_arg; jz .skip; jmp do_odd       # Tanya Shedde
.dispatch_square:    call .val_1_arg; jz .skip; jmp do_square    # Tanya Shedde
.dispatch_cube:      call .val_1_arg; jz .skip; jmp do_cube      # Tanya Shedde

.skip: ret

# # Tanya Shedde: Advanced Validation Helpers
.val_2_args:
    cmpb    $0, arg1_buf(%rip)
    je      .arg_missing
    cmpb    $0, arg2_buf(%rip)
    je      .arg_missing
    leaq    arg1_buf(%rip), %rdi
    call    .validate_numeric
    cmpq    $0, %rax
    je      .skip_val
    leaq    arg2_buf(%rip), %rdi
    call    .validate_numeric
    cmpq    $0, %rax
    je      .skip_val
    testq   %rax, %rax
    ret
.val_1_arg:
    cmpb    $0, arg1_buf(%rip)
    je      .arg_missing
    leaq    arg1_buf(%rip), %rdi
    call    .validate_numeric
    cmpq    $0, %rax
    je      .skip_val
    testq   %rax, %rax
    ret
.arg_missing:
    leaq    err_arg(%rip), %rdi
    call    print_str
    xorq    %rax, %rax
    ret
.skip_val:
    xorq    %rax, %rax
    ret

# # Tanya Shedde: Numeric and Range Validation (Exhaustive)
.validate_numeric:
    pushq   %rbx
    pushq   %rcx
    movq    %rdi, %rbx
    xorq    %rcx, %rcx
.vn_len:
    movb    (%rbx, %rcx, 1), %al
    cmpb    $0, %al
    je      .vn_range
    incq    %rcx
    jmp     .vn_len
.vn_range:
    cmpq    $10, %rcx
    jg      .vn_overflow
    xorq    %rcx, %rcx
.vn_loop:
    movb    (%rbx, %rcx, 1), %al
    cmpb    $0, %al
    je      .vn_done
    cmpb    $'0', %al
    jl      .vn_error
    cmpb    $'9', %al
    jg      .vn_error
    incq    %rcx
    jmp     .vn_loop
.vn_done:
    movq    $1, %rax
    popq    %rcx
    popq    %rbx
    ret
.vn_overflow:
    leaq    err_overflow(%rip), %rdi
    call    print_str
    xorq    %rax, %rax
    popq    %rcx
    popq    %rbx
    ret
.vn_error:
    leaq    err_numeric(%rip), %rdi
    call    print_str
    xorq    %rax, %rax
    popq    %rcx
    popq    %rbx
    ret

# ============================================================
# Logic Routines
# ============================================================

# # Tanya Shedde: Help Command System
do_help:
    leaq    help_msg(%rip), %rdi
    call    print_str
    ret

do_add:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    addq    %rbx, %rax
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

do_sub:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    subq    %rax, %rbx
    movq    %rbx, %rax
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

do_mul:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    imulq   %rbx, %rax
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

do_div:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx
    movq    %rbx, %rax
    xorq    %rdx, %rdx
    idivq   %rcx
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

do_mod:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx
    movq    %rbx, %rax
    xorq    %rdx, %rdx
    idivq   %rcx
    movq    %rdx, %rax
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

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
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

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
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

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
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

do_isprime:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    leaq    result_lbl(%rip), %rdi
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
    leaq    msg_prime(%rip), %rdi
    call    print_str
    ret
.not_prime:
    leaq    msg_notprime(%rip), %rdi
    call    print_str
    ret

do_iseven:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx
    leaq    result_lbl(%rip), %rdi
    call    print_str
    movq    %rbx, %rax
    call    print_int
    testq   $1, %rbx
    jz      .is_even_msg
    leaq    msg_odd(%rip), %rdi
    call    print_str
    ret
.is_even_msg:
    leaq    msg_even(%rip), %rdi
    call    print_str
    ret

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
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

do_abs:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    cmpq    $0, %rax
    jge     .abs_done
    negq    %rax
.abs_done:
    leaq    result_lbl(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline(%rip), %rdi
    call    print_str
    ret

# ============================================================
# Stubs for New Commands 
# ============================================================
do_even:
    # ### TEAM MEMBER 1: INSERT ARITHMETIC LOGIC HERE ###
    ret

do_odd:
    # ### TEAM MEMBER 1: INSERT ARITHMETIC LOGIC HERE ###
    ret

do_max:
    # ### TEAM MEMBER 1: INSERT ARITHMETIC LOGIC HERE ###
    ret

do_min:
    # ### TEAM MEMBER 1: INSERT ARITHMETIC LOGIC HERE ###
    ret

do_square:
    # ### TEAM MEMBER 1: INSERT ARITHMETIC LOGIC HERE ###
    ret

do_cube:
    # ### TEAM MEMBER 1: INSERT ARITHMETIC LOGIC HERE ###
    ret

# ============================================================
# str_compare(rdi=s1, rsi=s2) -> rax=1 equal, 0 not equal
# ============================================================
str_compare:
.cmp_loop:
    movb    (%rdi), %al
    movb    (%rsi), %bl

    # Tanya Shedde: Case-Insensitivity logic
    cmpb    $'a', %al
    jl      .not_lower_al
    cmpb    $'z', %al
    jg      .not_lower_al
    subb    $0x20, %al
.not_lower_al:
    cmpb    $'a', %bl
    jl      .not_lower_bl
    cmpb    $'z', %bl
    jg      .not_lower_bl
    subb    $0x20, %bl
.not_lower_bl:

    cmpb    %bl, %al
    jne     .cmp_not_equal
    cmpb    $0, %al
    je      .cmp_equal
    incq    %rdi
    incq    %rsi
    jmp     .cmp_loop

.cmp_equal:
    movq    $1, %rax
    ret

.cmp_not_equal:
    xorq    %rax, %rax
    ret

# ============================================================
# Utility Routines
# ============================================================
str_to_int:
    xorq    %rax, %rax
    xorq    %rcx, %rcx
.s2i_loop:
    movb    (%rdi), %cl
    cmpb    $0, %cl
    je      .s2i_done
    subb    $'0', %cl
    imulq   $10, %rax
    addq    %rcx, %rax
    incq    %rdi
    jmp     .s2i_loop
.s2i_done:
    ret

print_int:
    pushq   %rbx
    pushq   %rcx
    pushq   %rdx
    pushq   %rsi
    movq    $10, %rbx
    movq    $0, %rcx
    leaq    num_buf(%rip), %rsi
    addq    $31, %rsi
    movb    $0, (%rsi)
.pi_loop:
    xorq    %rdx, %rdx
    divq    %rbx
    addb    $'0', %dl
    decq    %rsi
    movb    %dl, (%rsi)
    incq    %rcx
    testq   %rax, %rax
    jnz     .pi_loop
    movq    $1, %rax
    movq    $1, %rdi
    movq    %rcx, %rdx
    syscall
    popq    %rsi
    popq    %rdx
    popq    %rcx
    popq    %rbx
    ret

print_str:
    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    pushq   %rax
    movq    %rdi, %rsi
    xorq    %rdx, %rdx
.ps_len:
    cmpb    $0, (%rsi, %rdx, 1)
    je      .ps_write
    incq    %rdx
    jmp     .ps_len
.ps_write:
    movq    $1, %rax
    movq    $1, %rdi
    syscall
    popq    %rax
    popq    %rdx
    popq    %rsi
    popq    %rdi
    ret

