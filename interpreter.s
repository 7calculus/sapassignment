
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

    
