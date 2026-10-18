%include "lib.inc"
%include "dict.inc"
%include "words.inc"

section .rodata
not_found_message: db "Error: key not found", 10
not_found_length: equ $ - not_found_message
input_error_message: db "Error: input exceeds 255 characters", 10
input_error_length: equ $ - input_error_message

section .bss
input_buffer: resb 256

section .text
global _start
_start:
    ; Read a complete line, preserving spaces inside dictionary keys.
    xor r12d, r12d
.read:
    call read_char
    test eax, eax
    jz .input_ready
    cmp al, 10
    je .input_ready
    cmp r12, 255
    jae .input_error
    mov [input_buffer + r12], al
    inc r12
    jmp .read
.input_ready:
    mov byte [input_buffer + r12], 0
    mov rdi, input_buffer
    mov rsi, last_word
    call find_word
    test rax, rax
    jz .not_found

    lea rdi, [rax + 8]
    push rdi
    call string_length
    pop rdi
    lea rdi, [rdi + rax + 1]
    call print_string
    call print_newline
    xor edi, edi
    jmp exit

.not_found:
    mov eax, 1
    mov edi, 2
    mov rsi, not_found_message
    mov edx, not_found_length
    syscall
    mov edi, 1
    jmp exit
.input_error:
    mov eax, 1
    mov edi, 2
    mov rsi, input_error_message
    mov edx, input_error_length
    syscall
    mov edi, 2
    jmp exit
