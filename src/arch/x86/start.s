.global _start
.type _start, @function

_start:
    mov $0x80000, %esp  // Set up the stack pointer

    push %ebx           // Multiboot info structure, arg 2
    push %eax           // Multiboot magic, arg 1

    call kmain          // Call the kernel

    // Halt the CPU
    cli
    hlt