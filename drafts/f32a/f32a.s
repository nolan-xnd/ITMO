.data
.org 0x00
buf: .byte '________________________________'

.text
.org 0x88
_start:
    1 a!

loop:
    @p 0x80
    255 and
    dup 10 xor
    if done

    a -32 +
    -if overflow

    dup -65 +
    -if check_upper
    store ;

check_upper:
    dup -91 +
    -if store
    32 +

store:
    !+
    loop ;

done:
    drop
    a -1 +
    0x5f5f5f5f !
    @p 0
    0xffffff00 and
    +
    !p 0
    1 a!

output:
    a
    @p 0
    255 and
    1 +
    xor
    if finish

    @+
    255 and
    !p 0x84
    output ;

overflow:
    drop
    0xCCCCCCCC
    !p 0x84

finish:
    halt