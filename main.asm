bits 64
default rel
global _start

section .bss
  cwd_buf resb 4096
  dent_buf resb 8192
  file resb 4096

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
  mov rsi, 0x10000              ; O_DIRECTORY
  xor rdx, rdx
  syscall

  test rax, rax
  js error_exit

  mov r12, rax                  ; fd of opened cwd

  ;; read dir entries in cwd w/ getdents64 syscall
  mov rax, 217
  mov rdi, r12
  lea rsi, [dent_buf]
  mov rdx, 8192
  syscall

  test rax, rax
  js error_exit

  mov r13, rax                  ; sizeof(dent_buf)

parse_loop:
  xor rbx, rbx                  ; current offset to dent_buf

.entry_loop:
  cmp rbx, r13
  jge .done

  ; get current entry addr
  lea rcx, [dent_buf + rbx]

  ; Extract d_reclen (2 bytes at offset 16)
  movzx r14, word [rcx + 16]

  test r14, r14
  jz .done

  ; get filename (offset 19)
  lea rsi, [rcx + 19]
  lea rdi, [file]
  xor rdx, rdx                  ; size counter
.copy_loop:
  mov al, [rsi + rdx]

  test al, al
  jz .add_newline

  mov [rdi + rdx], al
  inc rdx

  jmp .copy_loop

.add_newline:
  mov byte [rdi + rdx], 0x0A
  inc rdx

.print:
  ; NOTE: rdx already contains sizeof(file)
  mov rax, 0x01
  mov rdi, 0x01
  lea rsi, [file]
  syscall

.next:
  ; Advance to next entry using preserved d_reclen
  add rbx, r14

  jmp .entry_loop

.done:
  jmp exit

error_exit:
  mov rax, 0x3C
  mov rdi, 0x01
  syscall

exit:
  mov rax, 0x3C
  xor rdi, rdi
  syscall
