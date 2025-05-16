bits 64
default rel
global _start

section .rodata
  file db "shell.nix", 0x00

section .bss
  cwd_buf resb 4096
  buf resb 0x01

section .text
_start:
  mov rax, 79
  lea rdi, [cwd_buf]
  mov rsi, 4096
  syscall

  test rax, rax
  js error_exit

  mov rax, 0x01
  mov rdi, 0x01
  lea rsi, [cwd_buf]
  mov rdx, 4096
  syscall

  jmp exit

error_exit:
  mov rax, 0x3C
  mov rdi, 0x01
  syscall

exit:
  mov rax, 0x3C
  xor rdi, rdi
  syscall
