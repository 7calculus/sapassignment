# ============================================================
# arithmetic.s - Arithmetic Module
# CSC202B - RUAS Assignment 1
# Sudeepa: ADD, SUB, MUL, DIV, MOD + print utilities
# ============================================================
# Team Credits:
#   Sudeepa  - All arithmetic operations and print utilities
# ============================================================

.extern arg1_buf
.extern arg2_buf
.extern str_to_int

.section .data
result_lbl_a:   .string "Result: "
newline_a:      .string "\n"

.section .bss
num_buf:    .space 32

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
# Sudeepa: Adds two numbers from arg1_buf and arg2_buf
# INPUT:
#   arg1_buf = first number (string)
#   arg2_buf = second number (string)
# OUTPUT:
#   Prints "Result: <sum>"
# ==================================================
do_add:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Sudeepa: save first number

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    addq    %rbx, %rax              # Sudeepa: add both numbers
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ==================================================
# do_sub
# Sudeepa: Subtracts arg2 from arg1
# INPUT:
#   arg1_buf = first number (string)
#   arg2_buf = second number (string)
# OUTPUT:
#   Prints "Result: <difference>"
# ==================================================
do_sub:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Sudeepa: save first number

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    subq    %rax, %rbx              # Sudeepa: arg1 - arg2
    movq    %rbx, %rax
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ==================================================
# do_mul
# Sudeepa: Multiplies arg1 and arg2
# INPUT:
#   arg1_buf = first number (string)
#   arg2_buf = second number (string)
# OUTPUT:
#   Prints "Result: <product>"
# ==================================================
do_mul:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Sudeepa: save first number

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    imulq   %rbx, %rax              # Sudeepa: multiply
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ==================================================
# do_div
# Sudeepa: Divides arg1 by arg2 (integer division)
# INPUT:
#   arg1_buf = dividend (string)
#   arg2_buf = divisor (string)
# OUTPUT:
#   Prints "Result: <quotient>"
# ==================================================
do_div:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Sudeepa: save dividend

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx              # Sudeepa: save divisor

    movq    %rbx, %rax
    xorq    %rdx, %rdx              # Sudeepa: clear remainder register
    idivq   %rcx                    # Sudeepa: divide
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ==================================================
# do_mod
# Sudeepa: Returns remainder of arg1 / arg2
# INPUT:
#   arg1_buf = dividend (string)
#   arg2_buf = divisor (string)
# OUTPUT:
#   Prints "Result: <remainder>"
# ==================================================
do_mod:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx              # Sudeepa: save dividend

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rcx              # Sudeepa: save divisor

    movq    %rbx, %rax
    xorq    %rdx, %rdx              # Sudeepa: clear remainder register
    idivq   %rcx
    movq    %rdx, %rax              # Sudeepa: move remainder to rax
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ==================================================
# print_int
# Sudeepa: Converts integer in %rax to string and prints it
# INPUT:
#   %rax = number to print
# ==================================================
print_int:
    pushq   %rbx
    pushq   %rcx
    pushq   %rdx
    pushq   %rsi

    movq    $10, %rbx               # Sudeepa: divisor for decimal conversion
    movq    $0, %rcx
    leaq    num_buf(%rip), %rsi
    addq    $31, %rsi
    movb    $0, (%rsi)              # Sudeepa: null terminate

.pi_loop:                           # Sudeepa: extract digits in reverse
    xorq    %rdx, %rdx
    divq    %rbx
    addb    $'0', %dl               # Sudeepa: convert digit to ASCII
    decq    %rsi
    movb    %dl, (%rsi)
    incq    %rcx
    testq   %rax, %rax
    jnz     .pi_loop

    movq    $1, %rax                # Sudeepa: sys_write
    movq    $1, %rdi
    movq    %rcx, %rdx
    syscall

    popq    %rsi
    popq    %rdx
    popq    %rcx
    popq    %rbx
    ret

# ==================================================
# print_str
# Sudeepa: Prints null-terminated string in %rdi
# INPUT:
#   %rdi = address of null-terminated string
# ==================================================
print_str:
    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    pushq   %rax

    movq    %rdi, %rsi
    xorq    %rdx, %rdx

.ps_len:                            # Sudeepa: calculate string length
    cmpb    $0, (%rsi, %rdx, 1)
    je      .ps_write
    incq    %rdx
    jmp     .ps_len

.ps_write:                          # Sudeepa: sys_write syscall
    movq    $1, %rax
    movq    $1, %rdi
    syscall

    popq    %rax
    popq    %rdx
    popq    %rsi
    popq    %rdi
    ret