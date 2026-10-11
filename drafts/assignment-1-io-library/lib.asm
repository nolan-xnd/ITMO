; NASM x86-64, Linux, System V AMD64 ABI.
; Arguments: rdi, rsi, rdx. Results: rax (and rdx for parsers/read_word).
; Buffers are on the stack; rsp is aligned to 16 before every call.

section .text
global exit, string_length, print_string, print_char, print_newline
global print_uint, print_int, string_equals, read_char, read_word
global parse_uint, parse_int, string_copy

exit:
    mov eax, 60
    syscall
    ud2

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
    push rdi                    ; Save pointer and align stack.
    call string_length
    pop rsi
    mov rdx, rax
.write:
    test rdx, rdx
    jz .done
    mov eax, 1                  ; write(1, pointer, remaining).
    mov edi, 1
    syscall
    cmp rax, -4                 ; Retry EINTR.
    je .write
    test rax, rax
    jle .done
    add rsi, rax                ; Handle partial writes.
    sub rdx, rax
    jmp .write
.done:
    ret

print_char:
    push rdi                    ; Low byte is the character.
.write:
    mov eax, 1
    mov edi, 1
    mov rsi, rsp
    mov edx, 1
    syscall
    cmp rax, -4
    je .write
    add rsp, 8
    ret

print_newline:
    mov edi, 10
    jmp print_char              ; Tail call: same entry alignment.

print_uint:
    sub rsp, 40                 ; 20 digits + NUL, aligned for call.
    lea rsi, [rsp + 39]
    mov byte [rsi], 0
    mov rax, rdi
    mov ecx, 10
.digit:
    xor edx, edx
    div rcx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .digit
    mov rdi, rsi
    call print_string
    add rsp, 40
    ret

print_int:
    test rdi, rdi
    jns print_uint
    push rdi                    ; Save number across print_char.
    mov edi, '-'
    call print_char
    pop rdi
    neg rdi                     ; INT64_MIN becomes unsigned 2^63.
    jmp print_uint

string_equals:
    xor eax, eax
.loop:
    mov dl, [rdi]
    cmp dl, [rsi]
    jne .done
    test dl, dl
    jz .equal
    inc rdi
    inc rsi
    jmp .loop
.equal:
    mov eax, 1
.done:
    ret

read_char:
    sub rsp, 8
.read:
    xor eax, eax                ; read(0, stack_buffer, 1).
    xor edi, edi
    mov rsi, rsp
    mov edx, 1
    syscall
    cmp rax, -4
    je .read
    cmp rax, 1
    jne .empty
    movzx eax, byte [rsp]
    jmp .done
.empty:
    xor eax, eax
.done:
    add rsp, 8
    ret

read_word:
    push r12
    push r13
    push r14                    ; Three pushes align stack for call.
    mov r12, rdi                ; Buffer pointer.
    mov r13, rsi                ; Capacity, including NUL.
    xor r14d, r14d              ; Word length.
    test r13, r13
    jz .fail
    mov byte [r12], 0
.skip:
    call read_char
    test al, al
    jz .fail                    ; No word before EOF.
    cmp al, ' '
    je .skip
    cmp al, 9
    je .skip
    cmp al, 10
    je .skip
.store:
    lea rdx, [r14 + 1]
    cmp rdx, r13                ; Reserve one byte for NUL.
    jae .fail
    mov [r12 + r14], al
    inc r14
    mov byte [r12 + r14], 0
    call read_char
    test al, al
    jz .success                 ; EOF also finishes a word.
    cmp al, ' '
    je .success
    cmp al, 9
    je .success
    cmp al, 10
    jne .store
.success:
    mov rax, r12
    mov rdx, r14
    jmp .done
.fail:
    xor eax, eax
    xor edx, edx
.done:
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
    jmp parse_uint
.negative:
    inc rdi
    sub rsp, 8
    call parse_uint
    add rsp, 8
    test rdx, rdx
    jz .done                    ; A bare minus is not a number.
    neg rax
    inc rdx
.done:
    ret

string_copy:
    xor eax, eax                ; Current index / resulting length.
.copy:
    cmp rax, rdx                ; Check before every write, including NUL.
    jae .fail
    mov cl, [rdi + rax]
    mov [rsi + rax], cl
    test cl, cl
    jz .done
    inc rax
    jmp .copy
.done:
    ret
.fail:
    xor eax, eax
    ret
