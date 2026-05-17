.section .data
result_lbl: .asciz "Result: "
newline:    .asciz "\n"

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

do_add:
    addl %ebx, %eax
    pushl %eax
    pushl $result_lbl
    call print_str
    addl $4, %esp
    popl %eax
    call print_int
    pushl $newline
    call print_str
    addl $4, %esp
    ret

do_sub:
    subl %eax, %ebx
    movl %ebx, %eax
    pushl %eax
    pushl $result_lbl
    call print_str
    addl $4, %esp
    popl %eax
    call print_int
    pushl $newline
    call print_str
    addl $4, %esp
    ret

do_mul:
    imull %ebx, %eax
    pushl %eax
    pushl $result_lbl
    call print_str
    addl $4, %esp
    popl %eax
    call print_int
    pushl $newline
    call print_str
    addl $4, %esp
    ret

do_div:
    movl %eax, %ecx
    movl %ebx, %eax
    xorl %edx, %edx
    idivl %ecx
    pushl %eax
    pushl $result_lbl
    call print_str
    addl $4, %esp
    popl %eax
    call print_int
    pushl $newline
    call print_str
    addl $4, %esp
    ret

do_mod:
    movl %eax, %ecx
    movl %ebx, %eax
    xorl %edx, %edx
    idivl %ecx
    movl %edx, %eax
    pushl %eax
    pushl $result_lbl
    call print_str
    addl $4, %esp
    popl %eax
    call print_int
    pushl $newline
    call print_str
    addl $4, %esp
    ret

print_int:
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %esi
    pushl %edi
    movl $10, %ebx
    movl $0, %ecx
    movl $num_buf, %esi
    addl $31, %esi
    movb $0, (%esi)

convert_loop:
    xorl %edx, %edx
    divl %ebx
    addb $'0', %dl
    decl %esi
    movb %dl, (%esi)
    incl %ecx
    testl %eax, %eax
    jnz convert_loop
    movl %ecx, %edi
    movl $4, %eax
    movl $1, %ebx
    movl %esi, %ecx
    movl %edi, %edx
    int $0x80
    popl %edi
    popl %esi
    popl %edx
    popl %ecx
    popl %ebx
    ret

print_str:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %ecx
    movl $0, %edx

strlen_loop:
    cmpb $0, (%ecx,%edx,1)
    je write_string
    incl %edx
    jmp strlen_loop

write_string:
    movl $4, %eax
    movl $1, %ebx
    int $0x80
    popl %ebp
    ret
