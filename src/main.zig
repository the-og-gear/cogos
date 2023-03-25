const MAGIC = @as(u32, 0x1BADB002);
const FLAGS = @as(u32, (1 << 2));

// Attempt to place the multiboot header at the beginning of the binary
pub export var multiboot_header: multiboot.MultibootHeader linksection(".multiboot") = .{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = ~(MAGIC +% FLAGS) +% 1,

    .header_addr = 0,
    .load_addr = 0,
    .load_end_addr = 0,
    .bss_end_addr = 0,
    .entry_addr = 0,

    // Video mode information, since flags[2] is set
    .mode_type = 1, // 1 = text mode
    .width = 80, // Width and height in character count
    .height = 25,
    .depth = 0,
    // Depth is always 0 in text mode
};

const vga = @import("vga.zig");
const multiboot = @import("multiboot.zig");
const std = @import("std");

// Set up the stack
export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

// Main kernel entry
export fn kmain(magic: u32, info: *const multiboot.MultibootInfo) void {
    std.mem.doNotOptimizeAway(multiboot_header);

    // Set the stack pointer to the correct location
    _ = .{ .stack = stack_bytes_slice };
    std.debug.assert(magic == multiboot.MULTIBOOT_BOOTLOADER_MAGIC);

    // Write a string to the VGA memory
    vga.println("Test");
    vga.clear();
    vga.println("-------");
    vga.println(" CogOS ");
    vga.println("-------");

    _ = info;
}
