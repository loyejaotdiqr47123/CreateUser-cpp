section .data
    username db 0
    password db 0

section .bss
    user_info resb 660

section .text
    global main
    extern NetUserAdd, printf

main:
    ; 获取命令行参数
    mov rsi, [rdx + 8]   ; argv[1] 用户名
    mov rdi, [rdx + 16]  ; argv[2] 密码

    mov rcx, rsi
    call strlen

    mov r8, rax          ; 用户名长度
    mov rsi, rsi          ; 用户名

    mov rcx, rdi
    call strlen

    mov rdx, rax          ; 密码长度
    mov rdi, rdi          ; 密码

    ; 创建用户
    push rbp
    mov rbp, rsp

    mov r8, 3             ; USER_PRIV_USER
    mov r9, 1             ; UF_SCRIPT

    lea r10, [user_info]
    mov rax, NetUserAdd
    call rax

    pop rbp

    ; 输出结果
    cmp rax, 0
    je success
    jmp failure

success:
    lea rdi, [success_msg]
    jmp show_message

failure:
    lea rdi, [failure_msg]

show_message:
    lea rsi, [format]
    call printf

    ret

strlen:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    jz .done
    inc rax
    jmp .loop
.done:
    ret

section .data
    success_msg db "用户创建成功！", 10, 0
    failure_msg db "用户创建失败！", 10, 0
    format db "%s", 10, 0
