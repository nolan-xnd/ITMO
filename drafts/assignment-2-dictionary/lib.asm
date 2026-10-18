; Library API follows the user's Assignment 1 lib.asm (System V AMD64 ABI).
section .text
global exit, string_length, print_string, print_char, print_newline
global print_uint, print_int, string_equals, read_char, read_word
global parse_uint, parse_int, string_copy

exit:
    mov eax, 60
    syscall

string_length:
    xor eax, eax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

print_string:
    push rdi
    call string_length
    mov rdx, rax
    pop rsi
    mov edi, 1
    mov eax, 1
    syscall
    ret

print_char:
    push rdi
    mov eax, 1
    mov edi, 1
    mov rsi, rsp
    mov edx, 1
    syscall
    pop rdi
    ret

print_newline:
    mov edi, 10
    jmp print_char

print_uint:
    sub rsp, 40
    lea rsi, [rsp + 39]
    mov byte [rsi], 0
    mov rax, rdi
    mov r8d, 10
.convert:
    xor edx, edx
    div r8
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jne .convert
    mov rdi, rsi
    call print_string
    add rsp, 40
    ret

print_int:
    test rdi, rdi
    jns print_uint
    push rdi
    mov edi, '-'
    call print_char
    pop rdi
    neg rdi                 ; handles INT64_MIN as unsigned magnitude
    jmp print_uint

string_equals:
.loop:
    mov al, [rdi]
    cmp al, [rsi]
    jne .not_equal
    test al, al
    je .equal
    inc rdi
    inc rsi
    jmp .loop
.equal:
    mov eax, 1
    ret
.not_equal:
    xor eax, eax
    ret

read_char:
    sub rsp, 8
    xor eax, eax
    xor edi, edi
    mov rsi, rsp
    mov edx, 1
    syscall
    test rax, rax
    jle .eof
    movzx eax, byte [rsp]
    add rsp, 8
    ret
.eof:
    xor eax, eax
    add rsp, 8
    ret

; rdi = buffer, rsi = total capacity including terminating zero.
; Returns rax=buffer and rdx=length; rax=0 on failure.
read_word:
    push r12
    push r13
    push r14
    sub rsp, 16
    mov r12, rdi
    mov r13, rsi
    xor r14d, r14d
.skip:
    call read_char
    test eax, eax
    jz .finish
    cmp al, ' '
    je .skip
    cmp al, 9
    je .skip
    cmp al, 10
    je .skip
.next:
    cmp r14, r13
    jae .fail
    lea rdx, [r14 + 1]
    cmp rdx, r13
    jae .fail
    mov [r12 + r14], al
    inc r14
    call read_char
    test eax, eax
    jz .finish
    cmp al, ' '
    je .finish
    cmp al, 9
    je .finish
    cmp al, 10
    jne .next
.finish:
    test r13, r13
    jz .fail
    mov byte [r12 + r14], 0
    mov rax, r12
    mov rdx, r14
    jmp .done
.fail:
    xor eax, eax
    xor edx, edx
.done:
    add rsp, 16
    pop r14
    pop r13
    pop r12
    ret

parse_uint:
    xor eax, eax
    xor edx, edx
.loop:
    movzx ecx, byte [rdi + rdx]
    sub ecx, '0'
    cmp ecx, 9
    ja .done
    imul rax, rax, 10
    add rax, rcx
    inc rdx
    jmp .loop
.done:
    ret

parse_int:
    cmp byte [rdi], '-'
    je .negative
    cmp byte [rdi], '+'
    je .positive
    jmp parse_uint
.negative:
    push rdi
    inc rdi
    call parse_uint
    pop rdi
    test rdx, rdx
    jz .done
    neg rax
    inc rdx
.done:
    ret
.positive:
    push rdi
    inc rdi
    call parse_uint
    pop rdi
    test rdx, rdx
    jz .done
    inc rdx
    ret

; rdi = source, rsi = buffer, rdx = buffer capacity.
; Returns string length or zero if the source does not fit.
string_copy:
    xor eax, eax
.loop:
    cmp rax, rdx
    jae .fail
    mov cl, [rdi + rax]
    mov [rsi + rax], cl
    test cl, cl
    jz .done
    inc rax
    jmp .loop
.fail:
    xor eax, eax
.done:
    ret
