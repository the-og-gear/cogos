// Multiboot structure definitions

// Bootloader magic value
pub const MULTIBOOT_BOOTLOADER_MAGIC: u32 = 0x2BADB002;

// Magic value, for future updating
const MAGIC: u32 = 0x1BADB002;

// Multiboot header struct definition
pub const MultibootHeader = extern struct {
    magic: u32 = MAGIC,             // Magic value, as set in specifications
    flags: u32,                     // Feature flags requested by OS
    checksum: u32,                  // Checksum - based on value of flags and magic
    
    // These are currently unused and require flags[16] to be set
    header_addr: u32 = 0,
    load_addr: u32,
    load_end_addr: u32,
    bss_end_addr: u32,
    entry_addr: u32,

    // Video mode information, only passed if flags[2] is set
    mode_type: u32,
    width: u32,
    height: u32,
    depth: u32,
};

// Multiboot info struct definition
pub const MultibootInfo = extern struct {
    flags: u32,                     // Feature flags for entries passed back by bootloader

    // Only exists if flags[12] is set
    framebuffer_addr: u64 = 0,
    framebuffer_pitch: u32 = 0,
    framebuffer_width: u32 = 0,
    framebuffer_height: u32 = 0,
};