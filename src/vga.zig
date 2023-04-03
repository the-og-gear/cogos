const std = @import("std");

pub const VGA_WIDTH = 80;
pub const VGA_HEIGHT = 25;
pub const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;
pub var vga = VGA{
    .vram = @intToPtr([*]VGAEntry, 0xB8000)[0..0x4000],
    .cursor = 80 * 2,
    .foreground = Color.White,
    .background = Color.Black,
};

// Color codes
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

// Character with attributes
pub const VGAEntry = packed struct {
    char: u8,
    foreground: Color,
    background: Color,
};

pub fn print(format: []const u8) void {
    vga.writeString(format);
}
pub fn println(format: []const u8) void {
    vga.writeString(format);
    vga.writeNewline();
}
pub fn clear() void {
    vga.clear();
}

// I really wish printing integers at runtime didn't look like this much of a mess, but. Here we are.
// So, have some art.
//    ,---,                                                  ___                                                 ___      ,---,
// ,`--.' |                                                ,--.'|_                ,---,                        ,--.'|_  ,--.' |
// |   :  :                 .---.                  ,---,   |  | :,'             ,---.'|                        |  | :,' |  |  :
// :   |  '                /. ./|              ,-+-. /  |  :  : ' :             |   | :                        :  : ' : :  :  :
// |   :  |             .-'-. ' |  ,--.--.    ,--.'|'   |.;__,'  /              |   | |   ,---.     ,--.--.  .;__,'  /  :  |  |,--.
// '   '  ;            /___/ \: | /       \  |   |  ,"' ||  |   |             ,--.__| |  /     \   /       \ |  |   |   |  :  '   |
// |   |  |         .-'.. '   ' ..--.  .-. | |   | /  | |:__,'| :            /   ,'   | /    /  | .--.  .-. |:__,'| :   |  |   /' :
// '   :  ;        /___/ \:     ' \__\/: . . |   | |  | |  '  : |__         .   '  /  |.    ' / |  \__\/: . .  '  : |__ '  :  | | |
// |   |  '        .   \  ' .\    ," .--.; | |   | |  |/   |  | '.'|        '   ; |:  |'   ;   /|  ," .--.; |  |  | '.'||  |  ' | :
// '   :  |         \   \   ' \ |/  /  ,.  | |   | |--'    ;  :    ;        |   | '/  ''   |  / | /  /  ,.  |  ;  :    ;|  :  :_:,'
// ;   |.'           \   \  |--";  :   .'   \|   |/        |  ,   /         |   :    :||   :    |;  :   .'   \ |  ,   / |  | ,'
// '---'              \   \ |   |  ,     .-./'---'          ---`-'           \   \  /   \   \  / |  ,     .-./  ---`-'  `--''
//                     '---"     `--`---'                                     `----'     `----'   `--`---'
var vgaIntegerPrintBuffer: [21]u8 = undefined;
fn intToString(int: u32, buf: []u8) ![]const u8 {
    return try std.fmt.bufPrint(buf, "{}", .{int});
}
pub fn writeInt(int: anytype) void {
    const intAsString = intToString(int, &vgaIntegerPrintBuffer) catch unreachable;
    print(intAsString);
}

pub const VGA = struct {
    vram: []VGAEntry,
    cursor: usize,
    foreground: Color,
    background: Color,

    // Clear the screen
    pub fn clear(self: *VGA) void {
        std.mem.set(VGAEntry, self.vram[0..VGA_SIZE], self.entry(' '));
        self.cursor = 0;
    }

    // Print a character
    fn writeChar(self: *VGA, char: u8) void {
        if (self.cursor == VGA_WIDTH * VGA_HEIGHT - 1) {
            self.scrollDown();
        }

        switch (char) {
            // Newline
            '\n' => {
                self.writeChar(' ');
                while (self.cursor % VGA_WIDTH != 0)
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

    // Write a string
    pub fn writeString(self: *VGA, string: []const u8) void {
        for (string) |char| self.writeChar(char);
    }

    // Write a newline
    pub fn writeNewline(self: *VGA) void {
        self.writeChar('\n');
    }

    // Scroll one line down
    fn scrollDown(self: *VGA) void {
        const first = VGA_WIDTH;
        const last = VGA_SIZE - VGA_WIDTH;
        std.mem.copy(VGAEntry, self.vram[0..last], self.vram[first..VGA_SIZE]);
        std.mem.set(VGAEntry, self.vram[last..VGA_SIZE], self.entry(' '));

        self.cursor -= VGA_WIDTH;
    }

    // Build an entry with current foreground and background
    fn entry(self: *VGA, char: u8) VGAEntry {
        return VGAEntry{
            .char = char,
            .foreground = self.foreground,
            .background = self.background,
        };
    }
};
