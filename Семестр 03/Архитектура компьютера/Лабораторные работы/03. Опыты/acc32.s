.data
error_value: .word -1
number: .word 0
one: .word 1
mid: .word 0
min: .word 0
max: .word 46340
input_addr: .word 0x80
output_addr: .word 0x84

.text
.org 0x20

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

; 121 bytes out of 128 used till this place. 7 bytes free before MMIO

.text
.org 0x88

greater:
    load_addr mid
    sub one
    store_addr max
    jmp loop

prepare_mid:
    load_addr mid
    jmp done

prepare_max:
    load_addr max
    jmp done

error:
    load_addr error_value

done:
    store_ind output_addr
    halt