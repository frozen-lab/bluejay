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
  mov rsi, 0x8000               ; O_DIRECTORY
  xor rdx, rdx
  syscall

  test rax, rax
  js error_exit

  mov r12, rax                  ; fd of opened cwd

  ;; getdents64 syscall
  mov rax, 217
  mov rdi, r12
  lea rsi, [dent_buf]
  mov rdx, 8192
  syscall

  mov r13, rax                  ; sizeof(dent_buf)

parse_loop:
  lea rcx, [dent_buf]           ; pointer to dent_buf
  xor rbx, rbx                  ; offset into dent_buf

.init_loop:
  cmp rbx, r13
  jae .done                     ; close the loop

  ;; entry starts at (dent_buf + rbx)
  mov r11, rbx
  add r11, 19                   ; offset to first char in d_name

  xor rdx, rdx                  ; sizeof(file)
  lea rsi, [file]               ; pointer to file buf

.loop:
  mov r12, rcx
  add r12, rdx
  add r12, r11

  mov al, [r12]

  cmp al, 0x00
  je .loop_end

  mov [rsi + rdx], al
  inc rdx

  jmp .loop

.loop_end:
  mov byte [rsi + rdx], 0x00
  inc rdx

.print_file:
  mov rax, 0x01
  mov rdi, 0x01
  syscall

.next:
  add rdx, r10
  jmp .init_loop

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
