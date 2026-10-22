
.data
.org 0x300

input_port_address: .word 0x80
output_port_address: .word 0x84
input_buffer_address: .word 0x40
output_buffer_address: .word 0x00
stack_top_address: .word 0x1000

input_capacity: .word 0x40
output_pair_limit: .word 0x3d
max_run_length: .word 9
newline_character: .word 10
ascii_digit_zero: .word 48
overflow_value: .word -858993460

.text
.org 0x88

_start:
    movea.l stack_top_address, A4
    movea.l (A4), A7

    movea.l input_port_address, A4
    movea.l (A4), A2

    movea.l output_port_address, A4
    movea.l (A4), A3

    movea.l input_buffer_address, A4
    movea.l (A4), A0

    clr.l D4
    jsr read_input
    cmp.l 0, D0
    bne overflow

    movea.l input_buffer_address, A4
    movea.l (A4), A0

    movea.l output_buffer_address, A4
    movea.l (A4), A1

    clr.l D5
    jsr compress
    cmp.l 0, D0
    bne overflow

    clr.b (A1)
    jsr write_output
    halt

overflow:
    movea.l overflow_value, A4
    move.l (A4), D0
    move.l D0, (A3)
    halt

read_input:
    link A6, -4

read_loop:
    movea.l input_capacity, A4
    cmp.l (A4), D4
    bge read_overflow

    jsr read_character

    movea.l newline_character, A4
    cmp.b (A4), D0
    beq read_done

    move.b D0, (A0)+
    add.l 1, D4
    jmp read_loop

read_done:
    clr.l D0
    unlk A6
    rts

read_overflow:
    move.l 1, D0
    unlk A6
    rts

read_character:
    clr.l D0
    move.b (A2), D0
    rts

compress:
    link A6, -4

compress_loop:
    cmp.l 0, D4
    beq compress_done

    jsr count_run

    movea.l output_pair_limit, A4
    cmp.l (A4), D5
    bgt compress_overflow

    jsr emit_pair
    jmp compress_loop

compress_done:
    clr.l D0
    unlk A6
    rts

compress_overflow:
    move.l 1, D0
    unlk A6
    rts

count_run:
    clr.l D2
    move.b (A0)+, D2
    move.l 1, D3
    sub.l 1, D4

run_loop:
    cmp.l 0, D4
    beq run_done

    movea.l max_run_length, A4
    cmp.l (A4), D3
    bge run_done

    move.b (A0), D1
    cmp.b D2, D1
    bne run_done

    move.b (A0)+, D1
    add.l 1, D3
    sub.l 1, D4
    jmp run_loop

run_done:
    rts

emit_pair:
    link A6, -8

    move.l D2, -4(A6)
    move.l D3, -8(A6)

    move.l -8(A6), D0
    movea.l ascii_digit_zero, A4
    add.b (A4), D0
    jsr emit_character

    move.l -4(A6), D0
    jsr emit_character

    unlk A6
    rts

emit_character:
    move.b D0, (A1)+
    add.l 1, D5
    rts

write_output:
    movea.l output_buffer_address, A4
    movea.l (A4), A0
    clr.l D0

write_loop:
    cmp.l 0, D5
    beq write_done

    move.b (A0)+, D0
    move.l D0, (A3)
    sub.l 1, D5
    jmp write_loop

write_done:
    rts
