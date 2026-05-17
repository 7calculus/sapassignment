# ============================================================
# code.s - Main Interpreter
# CSC202B - RUAS Assignment 1
# Compile: gcc -no-pie -o interpreter code.s arithmetic.s logical_parsing.s
# ============================================================
# Team Credits:
#   Tanya Shedde      - Main interpreter, dispatch, validation, help
#   Sudeepa           - Arithmetic module (ADD, SUB, MUL, DIV, MOD)
#   Vanshika          - Parsing and advanced commands module
# ============================================================

# ---- Imports from arithmetic.s (Sudeepa) ----
.extern do_add
.extern do_sub
.extern do_mul
.extern do_div
.extern do_mod
.extern print_str
.extern print_int

# ---- Imports from logical_parsing.s (Vanshika) ----
.extern do_factorial
.extern do_fibonacci
.extern do_power
.extern do_isprime
.extern do_iseven
.extern do_gcd
.extern do_abs
.extern do_even
.extern do_odd
.extern do_max
.extern do_min
.extern do_square
.extern do_cube
.extern parse_input

.extern str_compare

.section .data

prompt:         .string ">> "
newline:        .string "\n"
err_msg:        .string "ERROR: Invalid or unsupported command. Please try again.\n"
err_arg:        .string "ERROR: Missing required argument.\n"
result_lbl:     .string "Result: "

# Tanya Shedde: Descriptive Help Message and Validation Strings
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

# ---- Shared buffers exported to arithmetic.s (Sudeepa) and logical_parsing.s (Vanshika) ----
.section .bss
.global input_buf
.global keyword
.global arg1_buf
.global arg2_buf
.global num_buf

input_buf:  .space 128
keyword:    .space 32
arg1_buf:   .space 32
arg2_buf:   .space 32
num_buf:    .space 32

.section .text
.global main
.global str_compare
.global str_to_int

# ============================================================
# main - entry point
# Tanya Shedde: Main loop, input reading, exit handling
# ============================================================
main:
    leaq    banner(%rip), %rdi
    call    print_str

.main_loop:
    leaq    prompt(%rip), %rdi
    call    print_str

    # Read user input via sys_read syscall
    movq    $0, %rax
    movq    $0, %rdi
    leaq    input_buf(%rip), %rsi
    movq    $128, %rdx
    syscall

    # Replace newline character with null terminator
    movq    %rax, %rbx
    decq    %rbx
    leaq    input_buf(%rip), %rdi
    movb    $0, (%rdi, %rbx, 1)

    # Tanya Shedde: Empty Input Handling
    cmpb    $0, (%rdi)
    je      .main_loop

    # Check if user typed EXIT
    leaq    input_buf(%rip), %rdi
    leaq    cmd_exit(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .done

    # Vanshika: parse input into keyword + args (logical_parsing.s)
    call    parse_input
    # Tanya Shedde: dispatch to correct command routine
    call    dispatch

    jmp     .main_loop

.done:
    movq    $60, %rax
    xorq    %rdi, %rdi
    syscall

# ============================================================
# dispatch - match keyword and call correct routine
# Tanya Shedde: Command routing with validation
# ============================================================
dispatch:
    leaq    keyword(%rip), %rdi

    # Tanya Shedde: HELP Command Routing
    leaq    cmd_help(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      do_help

    # 2-Argument Commands - Sudeepa (arithmetic.s)
    leaq    cmd_add(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_add

    leaq    keyword(%rip), %rdi
    leaq    cmd_sub(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_sub

    leaq    keyword(%rip), %rdi
    leaq    cmd_mul(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_mul

    leaq    keyword(%rip), %rdi
    leaq    cmd_div(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_div

    leaq    keyword(%rip), %rdi
    leaq    cmd_mod(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_mod

    # 2-Argument Commands - Vanshika (logical_parsing.s)
    leaq    keyword(%rip), %rdi
    leaq    cmd_power(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_power

    leaq    keyword(%rip), %rdi
    leaq    cmd_gcd(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_gcd

    leaq    keyword(%rip), %rdi
    leaq    cmd_max(%rip), %rsi     # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_max           # Tanya Shedde

    leaq    keyword(%rip), %rdi
    leaq    cmd_min(%rip), %rsi     # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_min           # Tanya Shedde

    # 1-Argument Commands - Vanshika (logical_parsing.s)
    leaq    keyword(%rip), %rdi
    leaq    cmd_factorial(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_factorial

    leaq    keyword(%rip), %rdi
    leaq    cmd_fibonacci(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_fibonacci

    leaq    keyword(%rip), %rdi
    leaq    cmd_isprime(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_isprime

    leaq    keyword(%rip), %rdi
    leaq    cmd_iseven(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_iseven

    leaq    keyword(%rip), %rdi
    leaq    cmd_abs(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_abs

    leaq    keyword(%rip), %rdi
    leaq    cmd_even(%rip), %rsi    # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_even          # Tanya Shedde

    leaq    keyword(%rip), %rdi
    leaq    cmd_odd(%rip), %rsi     # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_odd           # Tanya Shedde

    leaq    keyword(%rip), %rdi
    leaq    cmd_square(%rip), %rsi  # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_square        # Tanya Shedde

    leaq    keyword(%rip), %rdi
    leaq    cmd_cube(%rip), %rsi    # Tanya Shedde
    call    str_compare
    cmpq    $1, %rax
    je      .dispatch_cube          # Tanya Shedde

    # No match found - Tanya Shedde: error message
    leaq    err_msg(%rip), %rdi
    call    print_str
    ret

# ---- 2-arg validation then jump - Sudeepa (arithmetic.s) ----
.dispatch_add:      call .val_2_args; jz .skip; jmp do_add
.dispatch_sub:      call .val_2_args; jz .skip; jmp do_sub
.dispatch_mul:      call .val_2_args; jz .skip; jmp do_mul
.dispatch_div:      call .val_2_args; jz .skip; jmp do_div
.dispatch_mod:      call .val_2_args; jz .skip; jmp do_mod

# ---- 2-arg validation then jump - Vanshika (logical_parsing.s) ----
.dispatch_power:    call .val_2_args; jz .skip; jmp do_power
.dispatch_gcd:      call .val_2_args; jz .skip; jmp do_gcd
.dispatch_max:      call .val_2_args; jz .skip; jmp do_max     # Tanya Shedde
.dispatch_min:      call .val_2_args; jz .skip; jmp do_min     # Tanya Shedde

# ---- 1-arg validation then jump - Vanshika (logical_parsing.s) ----
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

# ============================================================
# Tanya Shedde: Advanced Validation Helpers
# ============================================================
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

# Tanya Shedde: Numeric and Range Validation (Exhaustive)
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
# Tanya Shedde: Help Command System
# ============================================================
do_help:
    leaq    help_msg(%rip), %rdi
    call    print_str
    ret

# ============================================================
# str_compare(rdi=s1, rsi=s2) -> rax=1 equal, 0 not equal
# Tanya Shedde: Case-Insensitivity logic
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
# str_to_int(rdi=str) -> rax = integer
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