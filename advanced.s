.section .data
result_msg: .asciz "Result: "
newline:    .asciz "\n"
prime_msg:     .asciz "Prime Number\n"
notprime_msg:  .asciz "Not Prime Number\n"
even_msg:      .asciz "Even Number\n"
odd_msg:       .asciz "Odd Number\n"

.section .bss
num_buf: .space 32

.section .text
.global do_fact
.global do_pow
.global do_fib
.global do_gcd
.global do_prime
.global do_even
.global print_result

.extern print_int
.extern print_str

do_fact:
    movl %eax, %ecx
    movl $1, %eax
fact_loop:
    imull %ecx, %eax
    decl %ecx
    jnz fact_loop
    call print_result
    ret

do_pow:
    movl %eax, %edx
pow_loop:
    decl %ebx
    jz pow_done
    imull %edx, %eax
    jmp pow_loop
pow_done:
    call print_result
    ret

do_fib:
    movl %eax, %ecx
    movl $0, %eax
    movl $1, %ebx
fib_loop:
    addl %ebx, %eax
    xchgl %eax, %ebx
    decl %ecx
    jnz fib_loop
    movl %ebx, %eax
    call print_result
    ret

do_gcd:
gcd_loop:
    cmpl %ebx, %eax
    je gcd_done
    jg greater
    subl %eax, %ebx
    jmp gcd_loop
greater:
    subl %ebx, %eax
    jmp gcd_loop
gcd_done:
    call print_result
    ret

do_prime:
    movl %eax, %esi
    movl $2, %ecx
prime_loop:
    cmpl %ecx, %esi
    je prime_true
    movl %esi, %eax
    xorl %edx, %edx
    divl %ecx
    cmpl $0, %edx
    je prime_false
    incl %ecx
    jmp prime_loop
prime_true:
    pushl $prime_msg
    call print_str
    addl $4, %esp
    ret
prime_false:
    pushl $notprime_msg
    call print_str
    addl $4, %esp
    ret

do_even:
    movl $2, %ebx
    xorl %edx, %edx
    divl %ebx
    cmpl $0, %edx
    je even_true
    pushl $odd_msg
    call print_str
    addl $4, %esp
    ret
even_true:
    pushl $even_msg
    call print_str
    addl $4, %esp
    ret

print_result:
    pushl %eax
    pushl $result_msg
    call print_str
    addl $4, %esp
    popl %eax
    call print_int
    pushl $newline
    call print_str
    addl $4, %esp
    ret
