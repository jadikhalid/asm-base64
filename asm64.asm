section .data
    base64_table db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    msg_usage    db "Usage: ./asm64 [-d] <input_file>", 10
    len_usage    equ $ - msg_usage
    
    decode_table db 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
                 db 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
                 db 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 62, 255, 255, 255, 63
                 db 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 255, 255, 255, 255, 255, 255
                 db 255, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
                 db 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 255, 255, 255, 255, 255
                 db 255, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40
                 db 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 255, 255, 255, 255, 255

section .bss
    is_decode   resb 1
    buffer_in   resb 4
    buffer_out  resb 4
    fd_in       resq 1

section .text
    global _start

_start:
    pop rax                 ; argc
    cmp rax, 2
    jl  show_usage

    pop rax                 ; skip argv[0]
    pop rdi                 ; argv[1]

    mov byte [is_decode], 0
    cmp byte [rdi], '-'
    jne open_file
    
    cmp byte [rdi+1], 'd'
    jne show_usage
    mov byte [is_decode], 1
    pop rdi                 ; next arg is the filename

open_file:
    mov rax, 2              ; sys_open
    mov rsi, 0              ; O_RDONLY
    syscall
    cmp rax, 0
    jl  exit_error
    mov [fd_in], rax

main_loop:
    cmp byte [is_decode], 1
    je  do_decode

    ; --- MODE ENCODE ---
    mov rax, 0              ; sys_read
    mov rdi, [fd_in]
    mov rsi, buffer_in
    mov rdx, 3
    syscall
    cmp rax, 0
    je  close_and_exit
    
    mov r12, rax            ; Sauvegarde du nombre d'octets lus
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    mov al, [buffer_in]
    mov bl, [buffer_in+1]
    mov cl, [buffer_in+2]

    ; Char 1 (toujours présent)
    mov dl, al
    shr dl, 2
    movzx rsi, dl
    mov r8b, [base64_table + rsi]
    mov [buffer_out], r8b

    ; Char 2 (toujours présent)
    mov dl, al
    and dl, 0x03
    shl dl, 4
    mov r9b, bl
    shr r9b, 4
    or  dl, r9b
    movzx rsi, dl
    mov r8b, [base64_table + rsi]
    mov [buffer_out+1], r8b

    ; Char 3 & 4 (dépendent du padding)
    cmp r12, 3
    je  full_3
    cmp r12, 2
    je  pad_1
    jmp pad_2

full_3:
    mov dl, bl
    and dl, 0x0F
    shl dl, 2
    mov r9b, cl
    shr r9b, 6
    or  dl, r9b
    movzx rsi, dl
    mov r8b, [base64_table + rsi]
    mov [buffer_out+2], r8b
    mov dl, cl
    and dl, 0x3F
    movzx rsi, dl
    mov r8b, [base64_table + rsi]
    mov [buffer_out+3], r8b
    jmp write_out

pad_1:
    mov dl, bl
    and dl, 0x0F
    shl dl, 2
    movzx rsi, dl
    mov r8b, [base64_table + rsi]
    mov [buffer_out+2], r8b
    mov byte [buffer_out+3], '='
    jmp write_out

pad_2:
    mov byte [buffer_out+2], '='
    mov byte [buffer_out+3], '='

write_out:
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer_out
    mov rdx, 4
    syscall
    cmp r12, 3
    je  main_loop
    jmp close_and_exit

do_decode:
    ; --- MODE DECODE ---
    mov rax, 0
    mov rdi, [fd_in]
    mov rsi, buffer_in
    mov rdx, 4
    syscall
    cmp rax, 0
    je  close_and_exit

    xor r8, r8
    xor r9, r9
    xor r10, r10
    xor r11, r11

    ; Chargement et décodage via table
    movzx rbx, byte [buffer_in]
    mov r8b, [decode_table + rbx]
    movzx rbx, byte [buffer_in+1]
    mov r9b, [decode_table + rbx]
    movzx rbx, byte [buffer_in+2]
    mov r10b, [decode_table + rbx]
    movzx rbx, byte [buffer_in+3]
    mov r11b, [decode_table + rbx]

    ; Reconstruction
    mov al, r8b
    shl al, 2
    mov dl, r9b
    shr dl, 4
    or  al, dl
    mov [buffer_out], al

    mov al, r9b
    shl al, 4
    mov dl, r10b
    shr dl, 2
    or  al, dl
    mov [buffer_out+1], al

    mov al, r10b
    shl al, 6
    or  al, r11b
    mov [buffer_out+2], al

    ; Gestion simplifiée du nombre d'octets à écrire (en ignorant le padding '=' en entrée)
    mov rdx, 3
    cmp byte [buffer_in+3], '='
    jne skip_pad_check
    mov rdx, 2
    cmp byte [buffer_in+2], '='
    jne skip_pad_check
    mov rdx, 1
skip_pad_check:
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer_out
    syscall
    jmp main_loop

show_usage:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_usage
    mov rdx, len_usage
    syscall
    jmp exit_error

close_and_exit:
    mov rax, 3
    mov rdi, [fd_in]
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall