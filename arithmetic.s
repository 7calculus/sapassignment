# ==================================================
# arithmetic.s
# Arithmetic Module for Command Interpreter
# Commands:
# ADD, SUB, MUL, DIV, MOD
# ==================================================

.section .data

result_lbl: .string "Result: "
newline:    .string "\n"

.section .bss
num_buf: .space 32

.section .text

.global do_add
.global do_sub
.global do_mul
.global do_div
.global do_mod

.global print_int
.global print_str

# ==================================================
# do_add
# INPUT:
#   %rbx = first number
#   %rax = second number
# ==================================================
do_add:

    addq %rbx, %rax

    leaq result_lbl(%rip), %rdi
    call print_str

    call print_int

    leaq newline(%rip), %rdi
    call print_str

    ret

# ==================================================
# do_sub
# INPUT:
#   %rbx = first number
#   %rax = second number
# ==================================================
do_sub:

    subq %rax, %rbx
    movq %rbx, %rax

    leaq result_lbl(%rip), %rdi
    call print_str

    call print_int

    leaq newline(%rip), %rdi
    call print_str

    ret

# ==================================================
# do_mul
# INPUT:
#   %rbx = first number
#   %rax = second number
# ==================================================
do_mul:

    imulq %rbx, %rax

    leaq result_lbl(%rip), %rdi
    call print_str

    call print_int

    leaq newline(%rip), %rdi
    call print_str

    ret

# ==================================================
# do_div
# INPUT:
#   %rbx = dividend
#   %rax = divisor
# ==================================================
do_div:

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

# ==================================================
# do_mod
# INPUT:
#   %rbx = dividend
#   %rax = divisor
# ==================================================
do_mod:

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

# ==================================================
# print_int
# INPUT:
#   %rax = number to print
# ==================================================
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

convert_loop:

    xorq %rdx, %rdx
    divq %rbx

    addb $'0', %dl

    decq %rsi
    movb %dl, (%rsi)

    incq %rcx

    testq %rax, %rax
    jnz convert_loop

    movq $1, %rax
    movq $1, %rdi
    movq %rcx, %rdx

    syscall

    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx

    ret

# ==================================================
# print_str
# INPUT:
#   %rdi = string address
# ==================================================
print_str:

    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rax

    movq %rdi, %rsi
    xorq %rdx, %rdx

length_loop:

    cmpb $0, (%rsi,%rdx,1)
    je write_string

    incq %rdx
    jmp length_loop

write_string:

    movq $1, %rax
    movq $1, %rdi

    syscall

    popq %rax
    popq %rdx
    popq %rsi
    popq %rdi

    ret
