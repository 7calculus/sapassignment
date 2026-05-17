 # ============================================================
 # Simplified Command Interpreter - CSC202B Assignment 1
 # AT&T Syntax - Assembled with GAS (GNU Assembler)
 # Assemble: gcc -m32 -no-pie -o interpreter code.s
 # ============================================================

.section .data

prompt:         .string ">> "
newline:        .string "\n"
err_msg:        .string "ERROR: Invalid or unsupported command. Please try again.\n"
err_arg:        .string "ERROR: Missing required argument.\n"
result_lbl:     .string "Result: "

 # # Tanya Shedde: Descriptive Help Message and Validation Strings
err_numeric:    .string "ERROR: Argument must be a numeric integer.\n"
err_overflow:   .string "ERROR: Number too large for 32-bit calculation.\n"
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
cmd_even:       .string "EVEN"        # Tanya Shedde
cmd_odd:        .string "ODD"         # Tanya Shedde
cmd_max:        .string "MAX"         # Tanya Shedde
cmd_min:        .string "MIN"         # Tanya Shedde
cmd_square:     .string "SQUARE"      # Tanya Shedde
cmd_cube:       .string "CUBE"        # Tanya Shedde
cmd_help:       .string "HELP"        # Tanya Shedde
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
    leal    banner, %edi
    call    print_str

.main_loop:
    leal    prompt, %edi
    call    print_str

    movl    $3, %eax
    movl    $0, %ebx
    leal    input_buf, %ecx
    movl    $128, %edx
    int     $0x80

    movl    %eax, %ebx
    decl    %ebx
    leal    input_buf, %edi
    movb    $0, (%edi, %ebx, 1)

     # Tanya Shedde: Empty Input Handling
    cmpb    $0, (%edi)
    je      .main_loop

    leal    input_buf, %edi
    leal    cmd_exit, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .done

    call    parse_input
    call    dispatch

    jmp     .main_loop

.done:
    movl    $1, %eax
    xorl    %ebx, %ebx
    int     $0x80

 # ============================================================
 # parse_input - splits input_buf into keyword, arg1, arg2
 # ### TEAM MEMBER 2: INSERT IMPROVED PARSING LOGIC HERE ###
 # ============================================================
parse_input:
    pushl   %ebx
    pushl   %ecx
    pushl   %edx

    leal    input_buf, %esi
    leal    keyword, %edi

.copy_keyword:
    movb    (%esi), %al
    cmpb    $0, %al
    je      .done_keyword
    cmpb    $' ', %al
    je      .done_keyword
    movb    %al, (%edi)
    incl    %esi
    incl    %edi
    jmp     .copy_keyword

.done_keyword:
    movb    $0, (%edi)
    cmpb    $' ', (%esi)
    jne     .parse_done
    incl    %esi

    leal    arg1_buf, %edi

.copy_arg1:
    movb    (%esi), %al
    cmpb    $0, %al
    je      .done_arg1
    cmpb    $' ', %al
    je      .done_arg1
    movb    %al, (%edi)
    incl    %esi
    incl    %edi
    jmp     .copy_arg1

.done_arg1:
    movb    $0, (%edi)
    cmpb    $' ', (%esi)
    jne     .parse_done
    incl    %esi

    leal    arg2_buf, %edi

.copy_arg2_loop:
    movb    (%esi), %al
    cmpb    $0, %al
    je      .done_arg2
    movb    %al, (%edi)
    incl    %esi
    incl    %edi
    jmp     .copy_arg2_loop

.done_arg2:
    movb    $0, (%edi)

.parse_done:
    popl    %edx
    popl    %ecx
    popl    %ebx
    ret

 # ============================================================
 # dispatch - match keyword and jump to routine
 # ============================================================
dispatch:
    leal    keyword, %edi
    
     # # Tanya Shedde: HELP Command Routing
    leal    cmd_help, %esi
    call    str_compare
    cmpl    $1, %eax
    je      do_help

     # 2-Argument Commands
    leal    cmd_add, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_add

    leal    cmd_sub, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_sub

    leal    cmd_mul, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_mul

    leal    cmd_div, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_div

    leal    cmd_mod, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_mod

    leal    cmd_power, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_power

    leal    cmd_gcd, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_gcd

    leal    cmd_max, %esi      # Tanya Shedde
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_max            # Tanya Shedde

    leal    cmd_min, %esi      # Tanya Shedde
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_min            # Tanya Shedde

     # 1-Argument Commands
    leal    cmd_factorial, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_factorial

    leal    cmd_fibonacci, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_fibonacci

    leal    cmd_isprime, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_isprime

    leal    cmd_iseven, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_iseven

    leal    cmd_abs, %esi
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_abs

    leal    cmd_even, %esi     # Tanya Shedde
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_even           # Tanya Shedde

    leal    cmd_odd, %esi      # Tanya Shedde
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_odd            # Tanya Shedde

    leal    cmd_square, %esi   # Tanya Shedde
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_square         # Tanya Shedde

    leal    cmd_cube, %esi     # Tanya Shedde
    call    str_compare
    cmpl    $1, %eax
    je      .dispatch_cube           # Tanya Shedde

    leal    err_msg, %edi
    call    print_str
    ret

.dispatch_add:       call .val_2_args; jz .skip; jmp do_add
.dispatch_sub:       call .val_2_args; jz .skip; jmp do_sub
.dispatch_mul:       call .val_2_args; jz .skip; jmp do_mul
.dispatch_div:       call .val_2_args; jz .skip; jmp do_div
.dispatch_mod:       call .val_2_args; jz .skip; jmp do_mod
.dispatch_power:     call .val_2_args; jz .skip; jmp do_power
.dispatch_gcd:       call .val_2_args; jz .skip; jmp do_gcd
.dispatch_max:       call .val_2_args; jz .skip; jmp do_max      # Tanya Shedde
.dispatch_min:       call .val_2_args; jz .skip; jmp do_min      # Tanya Shedde

.dispatch_factorial: call .val_1_arg; jz .skip; jmp do_factorial
.dispatch_fibonacci: call .val_1_arg; jz .skip; jmp do_fibonacci
.dispatch_isprime:   call .val_1_arg; jz .skip; jmp do_isprime
.dispatch_iseven:    call .val_1_arg; jz .skip; jmp do_iseven
.dispatch_abs:       call .val_1_arg; jz .skip; jmp do_abs
.dispatch_even:      call .val_1_arg; jz .skip; jmp do_even       # Tanya Shedde
.dispatch_odd:       call .val_1_arg; jz .skip; jmp do_odd        # Tanya Shedde
.dispatch_square:    call .val_1_arg; jz .skip; jmp do_square     # Tanya Shedde
.dispatch_cube:      call .val_1_arg; jz .skip; jmp do_cube       # Tanya Shedde

.skip: ret

 # # Tanya Shedde: Advanced Validation Helpers
.val_2_args:
    cmpb    $0, arg1_buf
    je      .arg_missing
    cmpb    $0, arg2_buf
    je      .arg_missing
    leal    arg1_buf, %edi
    call    .validate_numeric
    cmpl    $0, %eax
    je      .skip_val
    leal    arg2_buf, %edi
    call    .validate_numeric
    cmpl    $0, %eax
    je      .skip_val
    testl   %eax, %eax
    ret
.val_1_arg:
    cmpb    $0, arg1_buf
    je      .arg_missing
    leal    arg1_buf, %edi
    call    .validate_numeric
    cmpl    $0, %eax
    je      .skip_val
    testl   %eax, %eax
    ret
.arg_missing:
    leal    err_arg, %edi
    call    print_str
    xorl    %eax, %eax
    ret
.skip_val:
    xorl    %eax, %eax
    ret

 # # Tanya Shedde: Numeric and Range Validation (Exhaustive)
.validate_numeric:
    pushl   %ebx
    pushl   %ecx
    movl    %edi, %ebx
    xorl    %ecx, %ecx
.vn_len:
    movb    (%ebx, %ecx, 1), %al
    cmpb    $0, %al
    je      .vn_range
    incl    %ecx
    jmp     .vn_len
.vn_range:
    cmpl    $10, %ecx
    jg      .vn_overflow
    xorl    %ecx, %ecx
.vn_loop:
    movb    (%ebx, %ecx, 1), %al
    cmpb    $0, %al
    je      .vn_done
    cmpb    $'0', %al
    jl      .vn_error
    cmpb    $'9', %al
    jg      .vn_error
    incl    %ecx
    jmp     .vn_loop
.vn_done:
    movl    $1, %eax
    popl    %ecx
    popl    %ebx
    ret
.vn_overflow:
    leal    err_overflow, %edi
    call    print_str
    xorl    %eax, %eax
    popl    %ecx
    popl    %ebx
    ret
.vn_error:
    leal    err_numeric, %edi
    call    print_str
    xorl    %eax, %eax
    popl    %ecx
    popl    %ebx
    ret

 # ============================================================
 # Logic Routines
 # ============================================================

 # # Tanya Shedde: Help Command System
do_help:
    leal    help_msg, %edi
    call    print_str
    ret

do_add:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    arg2_buf, %edi
    call    str_to_int
    addl    %ebx, %eax
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_sub:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    arg2_buf, %edi
    call    str_to_int
    subl    %eax, %ebx
    movl    %ebx, %eax
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_mul:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    arg2_buf, %edi
    call    str_to_int
    imull   %ebx, %eax
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_div:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    arg2_buf, %edi
    call    str_to_int
    movl    %eax, %ecx
    movl    %ebx, %eax
    xorl    %edx, %edx
    idivl   %ecx
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_mod:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    arg2_buf, %edi
    call    str_to_int
    movl    %eax, %ecx
    movl    %ebx, %eax
    xorl    %edx, %edx
    idivl   %ecx
    movl    %edx, %eax
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_factorial:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ecx
    movl    $1, %eax
.fact_loop:
    cmpl    $1, %ecx
    jle     .fact_done
    imull   %ecx, %eax
    decl    %ecx
    jmp     .fact_loop
.fact_done:
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_fibonacci:
    pushl   %esi
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ecx
    cmpl    $0, %ecx
    je      .fib_zero
    cmpl    $1, %ecx
    je      .fib_one
    movl    $0, %eax
    movl    $1, %ebx
    movl    $2, %edx
.fib_loop:
    cmpl    %ecx, %edx
    jg      .fib_done
    movl    %ebx, %esi
    addl    %eax, %ebx
    movl    %esi, %eax
    incl    %edx
    jmp     .fib_loop
.fib_zero:
    movl    $0, %eax
    jmp     .fib_print
.fib_one:
    movl    $1, %eax
    jmp     .fib_print
.fib_done:
    movl    %ebx, %eax
.fib_print:
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    popl    %esi
    ret

do_power:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    arg2_buf, %edi
    call    str_to_int
    movl    %eax, %ecx
    movl    $1, %eax
.pow_loop:
    cmpl    $0, %ecx
    je      .pow_done
    imull   %ebx, %eax
    decl    %ecx
    jmp     .pow_loop
.pow_done:
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_isprime:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    result_lbl, %edi
    call    print_str
    movl    %ebx, %eax
    call    print_int
    cmpl    $2, %ebx
    jl      .not_prime
    je      .is_prime
    movl    $2, %ecx
.prime_loop:
    movl    %ecx, %eax
    imull   %ecx, %eax
    cmpl    %ebx, %eax
    jg      .is_prime
    movl    %ebx, %eax
    xorl    %edx, %edx
    divl    %ecx
    cmpl    $0, %edx
    je      .not_prime
    incl    %ecx
    jmp     .prime_loop
.is_prime:
    leal    msg_prime, %edi
    call    print_str
    ret
.not_prime:
    leal    msg_notprime, %edi
    call    print_str
    ret

do_iseven:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    result_lbl, %edi
    call    print_str
    movl    %ebx, %eax
    call    print_int
    testl   $1, %ebx
    jz      .is_even_msg
    leal    msg_odd, %edi
    call    print_str
    ret
.is_even_msg:
    leal    msg_even, %edi
    call    print_str
    ret

do_gcd:
    leal    arg1_buf, %edi
    call    str_to_int
    movl    %eax, %ebx
    leal    arg2_buf, %edi
    call    str_to_int
    movl    %eax, %ecx
.gcd_loop:
    cmpl    $0, %ecx
    je      .gcd_done
    movl    %ebx, %eax
    xorl    %edx, %edx
    divl    %ecx
    movl    %ecx, %ebx
    movl    %edx, %ecx
    jmp     .gcd_loop
.gcd_done:
    movl    %ebx, %eax
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
    call    print_str
    ret

do_abs:
    leal    arg1_buf, %edi
    call    str_to_int
    cmpl    $0, %eax
    jge     .abs_done
    negl    %eax
.abs_done:
    leal    result_lbl, %edi
    call    print_str
    call    print_int
    leal    newline, %edi
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
    movb    (%edi), %al
    movb    (%esi), %bl

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
    incl    %edi
    incl    %esi
    jmp     .cmp_loop

.cmp_equal:
    movl    $1, %eax
    ret

.cmp_not_equal:
    xorl    %eax, %eax
    ret

 # ============================================================
 # Utility Routines
 # ============================================================
str_to_int:
    xorl    %eax, %eax
    xorl    %ecx, %ecx
.s2i_loop:
    movb    (%edi), %cl
    cmpb    $0, %cl
    je      .s2i_done
    subb    $'0', %cl
    imull   $10, %eax
    addl    %ecx, %eax
    incl    %edi
    jmp     .s2i_loop
.s2i_done:
    ret

print_int:
    pushl   %ebx
    pushl   %ecx
    pushl   %edx
    pushl   %esi
    movl    $10, %ebx
    movl    $0, %ecx
    leal    num_buf, %esi
    addl    $31, %esi
    movb    $0, (%esi)
.pi_loop:
    xorl    %edx, %edx
    divl    %ebx
    addb    $'0', %dl
    decl    %esi
    movb    %dl, (%esi)
    incl    %ecx
    testl   %eax, %eax
    jnz     .pi_loop
    movl    $4, %eax
    movl    $1, %ebx
    movl    %ecx, %edx
    movl    %esi, %ecx
    int     $0x80
    popl    %esi
    popl    %edx
    popl    %ecx
    popl    %ebx
    ret

print_str:
    pushl   %edi
    pushl   %esi
    pushl   %edx
    pushl   %eax
    pushl   %ebx
    movl    %edi, %esi
    xorl    %edx, %edx
.ps_len:
    cmpb    $0, (%esi, %edx, 1)
    je      .ps_write
    incl    %edx
    jmp     .ps_len
.ps_write:
    movl    $4, %eax
    movl    $1, %ebx
    movl    %esi, %ecx
    int     $0x80
    popl    %ebx
    popl    %eax
    popl    %edx
    popl    %esi
    popl    %edi
    ret

