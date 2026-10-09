.text
.org 0x88
_start:
    load_addr 0x80
    beqz done
    bltz error
    store_addr number

loop:
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

less:
    load_addr mid
    add one
    store_addr min
    jmp loop

greater:
    load_addr mid
    sub one
    store_addr max
    jmp loop

prepare_mid:
    load_addr mid
    store_addr result
    jmp done

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
    store_addr 0x84
    halt


.data
error_value: .word -1
result: .word 0
number: .word 0
one: .word 1
mid: .word 0
min: .word 0
max: .word 46340