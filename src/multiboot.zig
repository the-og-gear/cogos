// Multiboot structure definitions

// Bootloader magic value
pub const MULTIBOOT_BOOTLOADER_MAGIC: u32 = 0x2BADB002;

// Magic value, for future updating
const MAGIC: u32 = 0x1BADB002;

// Multiboot header struct definition
pub const MultibootHeader = extern struct {
    magic: u32 = MAGIC, // Magic value, as set in specifications
    flags: u32, // Feature flags requested by OS
    checksum: u32, // Checksum - based on value of flags and magic

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
    flags: u32, // Feature flags for entries passed back by bootloader

    // Only exists if flags[0] is set
    mem_upper: u32, // 4-7
    mem_lower: u32, // 8-11

    // Only exists if flags[1] is set
    boot_device: u32, // 12-15

    // Only exists if flags[2] is set
    cmdlin: u32, // 16-19

    // Only exists if flags[3] is set
    mods_count: u32, // 20-23
    mods_addr: u32, // 24-27

    // Only exists if flags[4] or flags[5] is set.
    // This is currently actually a dummy data structure. It needs reworked later.
    tabsize: u32, // 28-31
    strsize: u32, // 32-25
    addr: u32, // 36-39
    reserved: u32, // 40-43

    // Only exists if flags[6] is set
    mmap_length: u32, // 44-47
    mmap_addr: u32, // 48-51

    // Only exists if flags[7] is set
    drives_length: u32, // 52-55
    drives_addr: u32, // 56-59

    // Only exists if flags[8] is set
    config_table: u32, // 60-63

    // Only exists if flags[9] is set
    boot_loader_name: u32, // 64-67

    // Only exists if flags[10] is set
    apm_table: u32, // 68-71

    // Only exists if flags[11] is set
    vbe_control_info: u32, // 72-75
    vbe_mode_info: u32, // 76-79
    vbe_mode: u16, // 80-81
    vbe_interface_seg: u16, // 82-83
    vbe_interface_off: u16, // 84-85
    vbe_interface_len: u16, // 86-87

    // Only exists if flags[12] is set
    framebuffer_addr: u64 = 0, // 88-95
    framebuffer_pitch: u32 = 0, // 96-99
    framebuffer_width: u32 = 0, // 100-103
    framebuffer_height: u32 = 0, // 104-107
};
