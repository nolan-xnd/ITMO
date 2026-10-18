%ifndef COLON_INC
%define COLON_INC

; A node is: next pointer (8 bytes), NUL-terminated key, then value.
; 'last_word' always names the most recently defined node.
%ifndef last_word
%define last_word 0
%endif

%macro colon 2
%2:
    dq last_word
    db %1, 0
%undef last_word
%define last_word %2
%endmacro

%endif
