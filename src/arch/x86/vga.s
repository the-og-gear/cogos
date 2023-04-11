.global set_80_50_mode;
.type set_80_50_mode, @function;

set_80_50_mode:
    mov $0x1112, %ax
    xor %bl, %bl
    int $0x10
    ret