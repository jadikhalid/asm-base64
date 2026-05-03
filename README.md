# ASM64 - High-Performance Base64 CLI

A robust, zero-dependency Base64 encoder and decoder written in **x86-64 Assembly** for Linux.

## Why this project?

As a Software Engineer, I believe understanding the underlying architecture of our systems is key to building better software. This project demonstrates:

- **Direct System Calls**: No standard C library (libc) used.
- **Bitwise Mastery**: Efficient data transformation using CPU registers.
- **Memory Management**: Optimized buffer handling at the byte level.

## Features

- ✅ Full Base64 Encoding with padding support (`=`).
- ✅ Full Base64 Decoding using a fast lookup table.
- ✅ CLI support with `-d` flag.
- ✅ Minimal executable size (< 2KB).

## Installation & Usage

```bash
# Build the project
make

# Encode a file
./asm64 my-file.txt

# Decode a file
./asm64 -d encoded-file.txt
```
