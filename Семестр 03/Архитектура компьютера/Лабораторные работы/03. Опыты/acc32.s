.text
.org 0x00
_start: ; 21 bytes
    load_addr input_addr
    load_acc
    beqz done
    bltz error
    store_addr number

loop: ; 50 bytes
    load_addr min
    sub max
    bgtz prepare_max

    load_addr min
    add max
    shiftr one
    store_addr mid
    mul mid
    sub number
    beqz prepare_mid
    bltz less
    bgtz greater

less: ; 18 bytes
    load_addr mid
    add one
    store_addr min
    jmp loop

greater: ; 18 bytes
    load_addr mid
    sub one
    store_addr max
    jmp loop

prepare_mid: ; 15 bytes
    load_addr mid
    store_addr result
    jmp done

; 122 bytes used till this place

.text
.org 0x88
prepare_max:
    load_addr max
    store_addr result
    jmp done

error:
    load_addr error_value
    store_addr result
    jmp done

done:
    load_addr result
    store_ind output_addr
    halt


.data
error_value: .word -1
result: .word 0
number: .word 0
one: .word 1
mid: .word 0
min: .word 0
max: .word 46340
input_addr: .word 0x80
output_addr: .word 0x84