# encoder_in_assembly

An encoder written entirely in Intel 80x86 32-bit assembly, using raw Linux system calls with no standard library dependencies. Basic utility functions are provided via `util.c`.

## What It Does

- Prints all command-line arguments to stdout, each on a new line, using the `write` system call only.
- Encodes characters by reading input (default: stdin), incrementing alphabetic characters (from `'A'` to `'z'`) by 1, and writing output (default: stdout).
- Supports input and output redirection via command-line arguments:
  - `-i{file}` — read input from file
  - `-o{file}` — write output to file
- Lists all files in the current directory using the `getdents` system call.
- When invoked with `-a{prefix}`, appends a simple virus payload to each file in the current directory whose name begins with the given prefix:
  - The payload prints `"Hello, Infected File"` when the infected file is executed.
  - A message `VIRUS ATTACHED` is printed next to affected filenames during listing.

## Technologies

- Intel 80x86 32-bit assembly
- Linux system calls: `read`, `write`, `open`, `close`, `exit`, `getdents`, `lseek`
- Minimal C (used only for directory listing and utility functions)

## Usage

Compile using `nasm` and `gcc`:
