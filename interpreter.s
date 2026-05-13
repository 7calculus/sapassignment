# ============================================================
# Simplified Command Interpreter - CSC202B Assignment 1
# AT&T Syntax - Assembled with GAS (GNU Assembler)
# Assemble: gcc -no-pie -o interpreter interpreter.s
# ============================================================

.section .data
prompt:         .string ">> "
newline:        .string "\n"
err_msg:        .string "ERROR: Unknown command\n"
result_lbl:     .string "Result: "

# 12 supported commands
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
cmd_exit:       .string "EXIT"

msg_prime:      .string " is PRIME\n"
msg_notprime:   .string " is NOT PRIME\n"
msg_even:       .string " is EVEN\n"
msg_odd:        .string " is ODD\n"

banner:
    .string "==============================\n Simple Command Interpreter\n CSC202B - RUAS Assignment 1\n==============================\n Commands: ADD, SUB, MUL, DIV,\n MOD, FACTORIAL, FIBONACCI,\n POWER, ISPRIME, ISEVEN,\n GCD, ABS\n Type EXIT to quit.\n==============================\n"

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
    leaq banner(%rip), %rdi
    call print_str

.main_loop:
    leaq prompt(%rip), %rdi
    call print_str

    # sys_read(stdin, input_buf, 128)
    movq $0, %rax
    movq $0, %rdi
    leaq input_buf(%rip), %rsi
    movq $128, %rdx
    syscall

    # Replace newline with null terminator
    movq %rax, %rbx
    decq %rbx
    leaq input_buf(%rip), %rdi
    movb $0, (%rdi, %rbx, 1)

    # Check for EXIT
    leaq input_buf(%rip), %rdi
    leaq cmd_exit(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je .done

    # PARSING: split input into command keyword and arguments
    call parse_input

    # Match parsed command and call the required routine
    call dispatch
    jmp .main_loop

.done:
    movq $60, %rax
    xorq %rdi, %rdi
    syscall

# ============================================================
# PARSING SECTION
# parse_input reads input_buf and separates it into:
#   keyword  = command name
#   arg1_buf = first argument
#   arg2_buf = second argument
# It also ignores extra spaces between command and arguments.
# ============================================================
parse_input:
    pushq %rbx
    pushq %rcx
    pushq %rdx

    # Clear keyword buffer
    leaq keyword(%rip), %rdi
    movq $32, %rcx
.clear_keyword:
    movb $0, (%rdi)
    incq %rdi
    loop .clear_keyword

    # Clear arg1 buffer
    leaq arg1_buf(%rip), %rdi
    movq $32, %rcx
.clear_arg1:
    movb $0, (%rdi)
    incq %rdi
    loop .clear_arg1

    # Clear arg2 buffer
    leaq arg2_buf(%rip), %rdi
    movq $32, %rcx
.clear_arg2:
    movb $0, (%rdi)
    incq %rdi
    loop .clear_arg2

    leaq input_buf(%rip), %rsi

    # Skip spaces before command keyword
.skip_spaces_before_keyword:
    movb (%rsi), %al
    cmpb $0, %al
    je .parse_done
    cmpb $' ', %al
    jne .copy_keyword_start
    incq %rsi
    jmp .skip_spaces_before_keyword

    # Copy command keyword
.copy_keyword_start:
    leaq keyword(%rip), %rdi

.copy_keyword:
    movb (%rsi), %al
    cmpb $0, %al
    je .parse_done
    cmpb $' ', %al
    je .skip_spaces_before_arg1
    movb %al, (%rdi)
    incq %rsi
    incq %rdi
    jmp .copy_keyword

    # Skip spaces before first argument
.skip_spaces_before_arg1:
    movb (%rsi), %al
    cmpb $0, %al
    je .parse_done
    cmpb $' ', %al
    jne .copy_arg1_start
    incq %rsi
    jmp .skip_spaces_before_arg1

    # Copy first argument
.copy_arg1_start:
    leaq arg1_buf(%rip), %rdi

.copy_arg1:
    movb (%rsi), %al
    cmpb $0, %al
    je .parse_done
    cmpb $' ', %al
    je .skip_spaces_before_arg2
    movb %al, (%rdi)
    incq %rsi
    incq %rdi
    jmp .copy_arg1

    # Skip spaces before second argument
.skip_spaces_before_arg2:
    movb (%rsi), %al
    cmpb $0, %al
    je .parse_done
    cmpb $' ', %al
    jne .copy_arg2_start
    incq %rsi
    jmp .skip_spaces_before_arg2

    # Copy second argument
.copy_arg2_start:
    leaq arg2_buf(%rip), %rdi

.copy_arg2:
    movb (%rsi), %al
    cmpb $0, %al
    je .parse_done
    cmpb $' ', %al
    je .parse_done
    movb %al, (%rdi)
    incq %rsi
    incq %rdi
    jmp .copy_arg2

.parse_done:
    popq %rdx
    popq %rcx
    popq %rbx
    ret

# ============================================================
# dispatch - match keyword and jump to routine
# ============================================================
dispatch:
    leaq keyword(%rip), %rdi
    leaq cmd_add(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_add

    leaq keyword(%rip), %rdi
    leaq cmd_sub(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_sub

    leaq keyword(%rip), %rdi
    leaq cmd_mul(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_mul

    leaq keyword(%rip), %rdi
    leaq cmd_div(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_div

    leaq keyword(%rip), %rdi
    leaq cmd_mod(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_mod

    leaq keyword(%rip), %rdi
    leaq cmd_factorial(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_factorial

    leaq keyword(%rip), %rdi
    leaq cmd_fibonacci(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_fibonacci

    leaq keyword(%rip), %rdi
    leaq cmd_power(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_power

    leaq keyword(%rip), %rdi
    leaq cmd_isprime(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_isprime

    leaq keyword(%rip), %rdi
    leaq cmd_iseven(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_iseven

    leaq keyword(%rip), %rdi
    leaq cmd_gcd(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_gcd

    leaq keyword(%rip), %rdi
    leaq cmd_abs(%rip), %rsi
    call str_compare
    cmpq $1, %rax
    je do_abs

    leaq err_msg(%rip), %rdi
    call print_str
    ret

# ============================================================
# ADD a b
# ============================================================
do_add:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq arg2_buf(%rip), %rdi
    call str_to_int
    addq %rbx, %rax
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# SUB a b
# ============================================================
do_sub:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq arg2_buf(%rip), %rdi
    call str_to_int
    subq %rax, %rbx
    movq %rbx, %rax
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# MUL a b
# ============================================================
do_mul:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq arg2_buf(%rip), %rdi
    call str_to_int
    imulq %rbx, %rax
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# DIV a b
# ============================================================
do_div:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq arg2_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rcx
    movq %rbx, %rax
    xorq %rdx, %rdx
    idivq %rcx
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# MOD a b
# ============================================================
do_mod:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq arg2_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rcx
    movq %rbx, %rax
    xorq %rdx, %rdx
    idivq %rcx
    movq %rdx, %rax
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# FACTORIAL n
# ============================================================
do_factorial:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rcx
    movq $1, %rax

.fact_loop:
    cmpq $1, %rcx
    jle .fact_done
    imulq %rcx, %rax
    decq %rcx
    jmp .fact_loop

.fact_done:
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# FIBONACCI n
# ============================================================
do_fibonacci:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rcx
    cmpq $0, %rcx
    je .fib_zero
    cmpq $1, %rcx
    je .fib_one
    movq $0, %rax
    movq $1, %rbx
    movq $2, %rdx

.fib_loop:
    cmpq %rcx, %rdx
    jg .fib_done
    movq %rbx, %r8
    addq %rax, %rbx
    movq %r8, %rax
    incq %rdx
    jmp .fib_loop

.fib_zero:
    movq $0, %rax
    jmp .fib_print

.fib_one:
    movq $1, %rax
    jmp .fib_print

.fib_done:
    movq %rbx, %rax

.fib_print:
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# POWER a b
# ============================================================
do_power:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq arg2_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rcx
    movq $1, %rax

.pow_loop:
    cmpq $0, %rcx
    je .pow_done
    imulq %rbx, %rax
    decq %rcx
    jmp .pow_loop

.pow_done:
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# ISPRIME n
# ============================================================
do_isprime:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq result_lbl(%rip), %rdi
    call print_str
    movq %rbx, %rax
    call print_int
    cmpq $2, %rbx
    jl .not_prime
    je .is_prime
    movq $2, %rcx

.prime_loop:
    movq %rcx, %rax
    imulq %rcx, %rax
    cmpq %rbx, %rax
    jg .is_prime
    movq %rbx, %rax
    xorq %rdx, %rdx
    divq %rcx
    cmpq $0, %rdx
    je .not_prime
    incq %rcx
    jmp .prime_loop

.is_prime:
    leaq msg_prime(%rip), %rdi
    call print_str
    ret

.not_prime:
    leaq msg_notprime(%rip), %rdi
    call print_str
    ret

# ============================================================
# ISEVEN n
# ============================================================
do_iseven:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq result_lbl(%rip), %rdi
    call print_str
    movq %rbx, %rax
    call print_int
    testq $1, %rbx
    jz .is_even
    leaq msg_odd(%rip), %rdi
    call print_str
    ret

.is_even:
    leaq msg_even(%rip), %rdi
    call print_str
    ret

# ============================================================
# GCD a b
# ============================================================
do_gcd:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rbx
    leaq arg2_buf(%rip), %rdi
    call str_to_int
    movq %rax, %rcx

.gcd_loop:
    cmpq $0, %rcx
    je .gcd_done
    movq %rbx, %rax
    xorq %rdx, %rdx
    divq %rcx
    movq %rcx, %rbx
    movq %rdx, %rcx
    jmp .gcd_loop

.gcd_done:
    movq %rbx, %rax
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# ABS n
# ============================================================
do_abs:
    leaq arg1_buf(%rip), %rdi
    call str_to_int
    cmpq $0, %rax
    jge .abs_done
    negq %rax

.abs_done:
    leaq result_lbl(%rip), %rdi
    call print_str
    call print_int
    leaq newline(%rip), %rdi
    call print_str
    ret

# ============================================================
# str_compare(rdi=s1, rsi=s2) -> rax=1 equal, 0 not equal
# ============================================================
str_compare:
.cmp_loop:
    movb (%rdi), %al
    movb (%rsi), %bl
    cmpb %bl, %al
    jne .cmp_not_equal
    cmpb $0, %al
    je .cmp_equal
    incq %rdi
    incq %rsi
    jmp .cmp_loop

.cmp_equal:
    movq $1, %rax
    ret

.cmp_not_equal:
    movq $0, %rax
    ret

# ============================================================
# str_to_int(rdi=str) -> rax = integer
# ============================================================
str_to_int:
    xorq %rax, %rax
    xorq %rcx, %rcx

.s2i_loop:
    movb (%rdi), %cl
    cmpb $0, %cl
    je .s2i_done
    subb $'0', %cl
    imulq $10, %rax
    addq %rcx, %rax
    incq %rdi
    jmp .s2i_loop

.s2i_done:
    ret

# ============================================================
# print_int(rax = number to print)
# ============================================================
print_int:
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rsi
    movq $10, %rbx
    movq $0, %rcx
    leaq num_buf(%rip), %rsi
    addq $31, %rsi
    movb $0, (%rsi)

.pi_loop:
    xorq %rdx, %rdx
    divq %rbx
    addb $'0', %dl
    decq %rsi
    movb %dl, (%rsi)
    incq %rcx
    testq %rax, %rax
    jnz .pi_loop
    movq $1, %rax
    movq $1, %rdi
    movq %rcx, %rdx
    syscall
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx
    ret

# ============================================================
# print_str(rdi = null-terminated string)
# ============================================================
print_str:
    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rax
    movq %rdi, %rsi
    xorq %rdx, %rdx

.ps_len:
    cmpb $0, (%rsi, %rdx, 1)
    je .ps_write
    incq %rdx
    jmp .ps_len

.ps_write:
    movq $1, %rax
    movq $1, %rdi
    syscall
    popq %rax
    popq %rdx
    popq %rsi
    popq %rdi
    ret
