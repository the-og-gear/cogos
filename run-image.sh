#!/bin/bash

qemu_start() {
    qemu-system-x86_64 disk.iso
}

qemu_debug() {
    qemu-system-x86_64 -s -S disk.iso
}

qemu_"$@"