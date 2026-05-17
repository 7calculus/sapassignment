.section .data
msg1:  .asciz "ADD 4 6\n"
msg2:  .asciz "SUB 8 4\n"
msg3:  .asciz "MUL 6 5\n"
msg4:  .asciz "DIV 20 4\n"
msg5:  .asciz "MOD 20 3\n"
msg6:  .asciz "FACT 5\n"
msg7:  .asciz "POW 2 3\n"
msg8:  .asciz "FIB 7\n"
msg9:  .asciz "GCD 24 18\n"
msg10: .asciz "PRIME 7\n"
msg11: .asciz "EVEN 8\n"

.section .text
.global main
.extern do_add
.extern do_sub
.extern do_mul
.extern do_div
.extern do_mod
.extern do_fact
.extern do_pow
.extern do_fib
.extern do_gcd
.extern do_prime
.extern do_even
.extern print_str

main:
    pushl $msg1
    call print_str
    addl $4, %esp
    movl $4, %ebx
    movl $6, %eax
    call do_add

    pushl $msg2
    call print_str
    addl $4, %esp
    movl $8, %ebx
    movl $4, %eax
    call do_sub

    pushl $msg3
    call print_str
    addl $4, %esp
    movl $6, %ebx
    movl $5, %eax
    call do_mul

    pushl $msg4
    call print_str
    addl $4, %esp
    movl $20, %ebx
    movl $4, %eax
    call do_div

    pushl $msg5
    call print_str
    addl $4, %esp
    movl $20, %ebx
    movl $3, %eax
    call do_mod

    pushl $msg6
    call print_str
    addl $4, %esp
    movl $5, %eax
    call do_fact

    pushl $msg7
    call print_str
    addl $4, %esp
    movl $2, %eax
    movl $3, %ebx
    call do_pow

    pushl $msg8
    call print_str
    addl $4, %esp
    movl $7, %eax
    call do_fib

    pushl $msg9
    call print_str
    addl $4, %esp
    movl $24, %eax
    movl $18, %ebx
    call do_gcd

    pushl $msg10
    call print_str
    addl $4, %esp
    movl $7, %eax
    call do_prime

    pushl $msg11
    call print_str
    addl $4, %esp
    movl $8, %eax
    call do_even

    movl $0, %eax
    ret
