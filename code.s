# ============================================================
# code.s - Main Interpreter
# CSC202B - RUAS Assignment 1
# Compile: gcc -no-pie -o interpreter code.s arithmetic.s logical_parsing.s
# ============================================================

# ---- Imports from other files ----
.extern do_add
.extern do_sub
.extern do_mul
.extern do_div
.extern do_mod
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
.extern print_str
.extern print_int
.extern str_compare

.section .data

prompt:         .string ">> "
newline:        .string "\n"
err_msg:        .string "ERROR: Invalid or unsupported command. Please try again.\n"
err_arg:        .string "ERROR: Missing required argument.\n"
err_numeric:    .string "ERROR: Argument must be a numeric integer.\n"
err_overflow:   .string "ERROR: Number too large for 64-bit calculation.\n"
result_lbl:     .string "Result: "

help_msg:       .string "--- Command Guide ---\n 2-Arg Math: ADD, SUB, MUL, DIV, MOD, POWER (a^b), GCD\n 2-Arg Comparison: MAX (Larger), MIN (Smaller)\n 1-Arg Math: FACTORIAL (n!), FIBONACCI (nth term), SQUARE (n^2), CUBE (n^3)\n 1-Arg Logic: ISPRIME, ISEVEN, ABS, EVEN, ODD\n 0-Arg: HELP (Show this guide), EXIT (Quit)\n Usage: [COMMAND] [ARG1] [ARG2]\n"

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
cmd_even:       .string "EVEN"
cmd_odd:        .string "ODD"
cmd_max:        .string "MAX"
cmd_min:        .string "MIN"
cmd_square:     .string "SQUARE"
cmd_cube:       .string "CUBE"
cmd_help:       .string "HELP"
cmd_exit:       .string "EXIT"

msg_prime:      .string " is PRIME\n"
msg_notprime:   .string " is NOT PRIME\n"
msg_even:       .string " is EVEN\n"
msg_odd:        .string " is ODD\n"

banner:         .string "==============================\n Simple Command Interpreter\n CSC202B - RUAS Assignment 1\n==============================\n Commands: ADD, SUB, MUL, DIV, MOD,\n  FACTORIAL, FIBONACCI, POWER,\n  ISPRIME, ISEVEN, GCD, ABS,\n  EVEN, ODD, MAX, MIN, SQUARE, CUBE\n Type HELP for instructions.\n==============================\n"

# ---- Shared buffers (exported so other files can use them) ----
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
# ============================================================
main:
    leaq    banner(%rip), %rdi
    call    print_str

.main_loop:
    leaq    prompt(%rip), %rdi
    call    print_str

    # Read input
    movq    $0, %rax
    movq    $0, %rdi
    leaq    input_buf(%rip), %rsi
    movq    $128, %rdx
    syscall

    # Replace newline with null terminator
    movq    %rax, %rbx
    decq    %rbx
    leaq    input_buf(%rip), %rdi
    movb    $0, (%rdi, %rbx, 1)

    # Skip empty input
    cmpb    $0, (%rdi)
    je      .main_loop

    # Check EXIT
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
# dispatch - match keyword and call correct routine
# ============================================================
dispatch:
    leaq    keyword(%rip), %rdi

    leaq    cmd_help(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      do_help

    # 2-arg commands
    leaq    keyword(%rip), %rdi
    leaq    cmd_add(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_add

    leaq    keyword(%rip), %rdi
    leaq    cmd_sub(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_sub

    leaq    keyword(%rip), %rdi
    leaq    cmd_mul(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_mul

    leaq    keyword(%rip), %rdi
    leaq    cmd_div(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_div

    leaq    keyword(%rip), %rdi
    leaq    cmd_mod(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_mod

    leaq    keyword(%rip), %rdi
    leaq    cmd_power(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_power

    leaq    keyword(%rip), %rdi
    leaq    cmd_gcd(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_gcd

    leaq    keyword(%rip), %rdi
    leaq    cmd_max(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_max

    leaq    keyword(%rip), %rdi
    leaq    cmd_min(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk2_min

    # 1-arg commands
    leaq    keyword(%rip), %rdi
    leaq    cmd_factorial(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_factorial

    leaq    keyword(%rip), %rdi
    leaq    cmd_fibonacci(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_fibonacci

    leaq    keyword(%rip), %rdi
    leaq    cmd_isprime(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_isprime

    leaq    keyword(%rip), %rdi
    leaq    cmd_iseven(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_iseven

    leaq    keyword(%rip), %rdi
    leaq    cmd_abs(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_abs

    leaq    keyword(%rip), %rdi
    leaq    cmd_even(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_even

    leaq    keyword(%rip), %rdi
    leaq    cmd_odd(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_odd

    leaq    keyword(%rip), %rdi
    leaq    cmd_square(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_square

    leaq    keyword(%rip), %rdi
    leaq    cmd_cube(%rip), %rsi
    call    str_compare
    cmpq    $1, %rax
    je      .chk1_cube

    # No match
    leaq    err_msg(%rip), %rdi
    call    print_str
    ret

# ---- 2-arg validation then jump ----
.chk2_add:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_add

.chk2_sub:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_sub

.chk2_mul:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_mul

.chk2_div:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_div

.chk2_mod:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_mod

.chk2_power:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_power

.chk2_gcd:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_gcd

.chk2_max:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_max

.chk2_min:
    call    .val_2_args
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_min

# ---- 1-arg validation then jump ----
.chk1_factorial:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_factorial

.chk1_fibonacci:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_fibonacci

.chk1_isprime:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_isprime

.chk1_iseven:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_iseven

.chk1_abs:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_abs

.chk1_even:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_even

.chk1_odd:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_odd

.chk1_square:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_square

.chk1_cube:
    call    .val_1_arg
    cmpq    $0, %rax
    je      .dispatch_skip
    jmp     do_cube

.dispatch_skip:
    ret

# ============================================================
# Validation helpers
# ============================================================
.val_2_args:
    cmpb    $0, arg1_buf(%rip)
    je      .arg_missing
    cmpb    $0, arg2_buf(%rip)
    je      .arg_missing
    leaq    arg1_buf(%rip), %rdi
    call    .validate_numeric
    cmpq    $0, %rax
    je      .val_fail
    leaq    arg2_buf(%rip), %rdi
    call    .validate_numeric
    ret

.val_1_arg:
    cmpb    $0, arg1_buf(%rip)
    je      .arg_missing
    leaq    arg1_buf(%rip), %rdi
    call    .validate_numeric
    ret

.arg_missing:
    leaq    err_arg(%rip), %rdi
    call    print_str
    xorq    %rax, %rax
    ret

.val_fail:
    xorq    %rax, %rax
    ret

.validate_numeric:
    pushq   %rbx
    pushq   %rcx
    movq    %rdi, %rbx
    xorq    %rcx, %rcx
.vn_len:
    movb    (%rbx, %rcx, 1), %al
    cmpb    $0, %al
    je      .vn_check
    incq    %rcx
    jmp     .vn_len
.vn_check:
    cmpq    $10, %rcx
    jg      .vn_overflow
    xorq    %rcx, %rcx
.vn_loop:
    movb    (%rbx, %rcx, 1), %al
    cmpb    $0, %al
    je      .vn_ok
    cmpb    $'0', %al
    jl      .vn_error
    cmpb    $'9', %al
    jg      .vn_error
    incq    %rcx
    jmp     .vn_loop
.vn_ok:
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
# do_help
# ============================================================
do_help:
    leaq    help_msg(%rip), %rdi
    call    print_str
    ret

# ============================================================
# str_compare(rdi=s1, rsi=s2) -> rax=1 equal, 0 not equal
# Case insensitive
# ============================================================
str_compare:
.cmp_loop:
    movb    (%rdi), %al
    movb    (%rsi), %bl
    cmpb    $'a', %al
    jl      .no_lower_al
    cmpb    $'z', %al
    jg      .no_lower_al
    subb    $0x20, %al
.no_lower_al:
    cmpb    $'a', %bl
    jl      .no_lower_bl
    cmpb    $'z', %bl
    jg      .no_lower_bl
    subb    $0x20, %bl
.no_lower_bl:
    cmpb    %bl, %al
    jne     .cmp_no
    cmpb    $0, %al
    je      .cmp_yes
    incq    %rdi
    incq    %rsi
    jmp     .cmp_loop
.cmp_yes:
    movq    $1, %rax
    ret
.cmp_no:
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