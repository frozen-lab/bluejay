bits 64
default rel
global _start

section .bss
  cwd_buf resb 4096
  dent_buf resb 8192

section .text
_start:
  ;; read the current working dir
  mov rax, 79
  lea rdi, [cwd_buf]
  mov rsi, 4096
  syscall

  test rax, rax
  js error_exit

  ;; open cwd
  mov rax, 0x02
  lea rdi, [cwd_buf]
  mov rsi, 0x8000               ; O_DIRECTORY
  xor rdx, rdx
  syscall

  test rax, rax
  js error_exit

  mov r12, rax

  ;; getdents64 syscall
  mov rax, 217
  mov rdi, r12
  lea rsi, [dent_buf]
  mov rdx, 8192
  syscall

  ;; print the dent buf
  mov rdx, rax                  ; len of the buffer
  mov rax, 0x01
  mov rdi, 0x01
  lea rsi, [dent_buf]
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
