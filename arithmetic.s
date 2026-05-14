# ============================================================
# arithmetic.s - Arithmetic Module
# CSC202B - RUAS Assignment 1
# Commands: ADD, SUB, MUL, DIV, MOD
# + print_int, print_str utilities
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

# ============================================================
# do_add: ADD arg1 arg2
# ============================================================
do_add:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    addq    %rbx, %rax
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_sub: SUB arg1 arg2
# ============================================================
do_sub:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    subq    %rax, %rbx
    movq    %rbx, %rax
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_mul: MUL arg1 arg2
# ============================================================
do_mul:
    leaq    arg1_buf(%rip), %rdi
    call    str_to_int
    movq    %rax, %rbx

    leaq    arg2_buf(%rip), %rdi
    call    str_to_int

    imulq   %rbx, %rax
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_div: DIV arg1 arg2
# ============================================================
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
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ============================================================
# do_mod: MOD arg1 arg2
# ============================================================
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
    movq    %rdx, %rax          # remainder
    leaq    result_lbl_a(%rip), %rdi
    call    print_str
    call    print_int
    leaq    newline_a(%rip), %rdi
    call    print_str
    ret

# ============================================================
# print_int: prints integer in %rax
# ============================================================
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

# ============================================================
# print_str: prints null-terminated string in %rdi
# ============================================================
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