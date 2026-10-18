section .text

global find_word
; rdi = NUL-terminated search key, rsi = head node
; rax = matching node address, or zero
find_word:
.next_node:
    test rsi, rsi
    jz .not_found
    lea r8, [rsi + 8]        ; key starts just after the next pointer
    mov r9, rdi
.compare:
    mov al, [r9]
    cmp al, [r8]
    jne .advance
    test al, al
    jz .found
    inc r8
    inc r9
    jmp .compare
.advance:
    mov rsi, [rsi]
    jmp .next_node
.found:
    mov rax, rsi
    ret
.not_found:
    xor eax, eax
    ret
