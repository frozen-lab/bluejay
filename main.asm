bits 64
default rel
global _start

section .rodata
  file db "shell.nix", 0x00

section .bss
  buf resb 0x01

section .text
_start:
  mov rax, 0x02
  lea rdi, [file]
  xor rsi, rsi                  ; flags = O_READONLY
  xor rdx, rdx                  ; mode = NA
  syscall

  test rax, rax
  jz error_exit

  mov r12, rax

  jmp exit

error_exit:
  mov rax, 0x3C
  mov rdi, 0x01
  syscall

exit:
  mov rax, 0x3C
  xor rdi, rdi
  syscall
