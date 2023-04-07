const std = @import("std");

/// Default VGA width
pub const VGA_WIDTH = 80;
/// Default VGA height
pub const VGA_HEIGHT = 25;
/// Default VGA size
pub const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;
/// The actual VGA instance being used. Please do not directly modify!
pub var vga = VGA{
    .vram = @intToPtr([*]VGAEntry, 0xB8000)[0..0x4000], // Magic VGA bullshittery, go!
    .cursor = 80 * 2,
    .foreground = Color.White,
    .background = Color.Black,
};

/// VGA color codes. Both foreground and background use the same code.
pub const Color = enum(u4) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

/// A single text-mode VGA entry struct
pub const VGAEntry = packed struct {
    /// The associated character for this entry
    char: u8,
    /// The foreground color code
    foreground: Color,
    /// The background color code
    background: Color,
};

/// Print a string to the VGA buffer
pub fn print(format: []const u8) void {
    vga.writeString(format);
}

/// Print a string followed by a newline to the VGA buffer
pub fn println(format: []const u8) void {
    vga.writeString(format);
    vga.writeNewline(); // This is what actually prints the newline, because comptime stuff sucks and I'm lazy
}

/// Clear the VGA buffer
pub fn clear() void {
    vga.clear();
}

/// Print buffer for integers
var printBuffer: [21]u8 = undefined;

/// Converts an unsigned integer to a string.
/// Pass in a 64-bit wide unsigned integer, a buffer to use, and get back a string. Very simple.
fn uintToString(int: u64, buf: []u8) ![]const u8 {
    return try std.fmt.bufPrint(buf, "{}", .{int});
}

/// Writes an unsigned integer to the screen using the VGA print function.
pub fn writeUint(int: u64) void {
    const intAsString = uintToString(int, &printBuffer) catch unreachable;
    print(intAsString);
}

/// Converts a signed 64-bit wide integer into a string.
/// Give it a 64-bit signed int and a buffer, get back a string.
fn intToString(int: i64, buf: []u8) ![]const u8 {
    return try std.fmt.bufPrint(buf, "{}", .{int});
}

/// Write a signed integer to the screen using the VGA print function.
pub fn writeInt(int: i64) void {
    const intAsString = intToString(int, printBuffer);
    print(intAsString);
}

/// Set the VGA size. This is very useful for coming in from the bootloader
pub fn set_size(wide: u32, high: u32) void {
    vga.width = wide;
    vga.height = high;
    vga.size = wide * high;
}

/// The actual meat of the VGA module, the VGA struct
pub const VGA = struct {
    /// A slice of VGA entries. This is the actual video memory, usually located at 0xB8000
    vram: []VGAEntry,
    /// The cursor location
    cursor: usize,
    /// The current foreground color
    foreground: Color,
    /// The current background color
    background: Color,

    /// The actual VGA width
    width: u32 = VGA_WIDTH,
    /// The actual VGA height
    height: u32 = VGA_HEIGHT,
    /// The actual VGA size
    size: u32 = VGA_SIZE,

    /// Clear the VGA buffer
    pub fn clear(self: *VGA) void {
        std.mem.set(VGAEntry, self.vram[0..self.size], self.entry(' ')); // This essentially is setting the entire slice to be space characters to effectively clear the screen
        self.cursor = 0; // Then we set the cursor position to 0 so we are back at the start of the buffer
    }

    /// Print a character at the current cursor position in the VGA buffer
    fn writeChar(self: *VGA, char: u8) void {
        // Scroll the buffer if we're at the bottom of the screen
        if (self.cursor == self.width * self.height - 1) {
            self.scrollDown();
        }

        // Handle special characters
        switch (char) {
            // Newline
            '\n' => {
                self.writeChar(' ');
                while (self.cursor % self.width != 0)
                    self.writeChar(' ');
            },
            // Tab
            '\t' => {
                self.writeChar(' ');
                while (self.cursor % 4 != 0)
                    self.writeChar(' ');
            },
            // Backspace
            '\x08' => {
                self.cursor -= 1;
                self.vram[self.cursor] = self.entry(' ');
            },
            // Any other character
            else => {
                self.vram[self.cursor] = self.entry(char);
                self.cursor += 1;
            },
        }
    }

    /// Write a string to the VGA buffer starting at the current cursor position
    pub fn writeString(self: *VGA, string: []const u8) void {
        // This in essence loops over the entire string, character by character, and prints it. This does not support escape characters!
        for (string) |char| self.writeChar(char);
    }

    /// Write a newline to the VGA buffer
    pub fn writeNewline(self: *VGA) void {
        self.writeChar('\n');
    }

    /// Scroll the VGA buffer by one line down
    fn scrollDown(self: *VGA) void {
        const first = self.width; // The end of the first line
        const last = self.size - self.width; // The start of the last line
        std.mem.copy(VGAEntry, self.vram[0..last], self.vram[first..self.size]); // Copy everything following the first line up
        std.mem.set(VGAEntry, self.vram[last..self.size], self.entry(' ')); // And set the last line to all spaces

        self.cursor -= self.width; // Set the cursor to the beginning of the last line
    }

    /// Build a VGAEntry with current foreground and background colors
    fn entry(self: *VGA, char: u8) VGAEntry {
        return VGAEntry{
            .char = char,
            .foreground = self.foreground,
            .background = self.background,
        };
    }
};
