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

.text
.org 0x28
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


.text
.org 0x88
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

prepare_max:
    load_addr max
    jmp for_output

error:
    load_addr error_value
    jmp for_output

for_output:
    store_addr result

done:
    store_ind output_addr
    halt