.global graphics_mode
.type graphics_mode, @function

.global vga_mode
.type vga_mode, @function

graphics_mode:
    push %eax
    mov $0x00, %ah
    mov $0x13, %al
    int $0x10
    pop %eax
    ret

vga_mode:
    push %eax
    mov $0x00, %ah
    mov $0x03, %al
    int $0x10
    pop %eax
    ret