section .data
    user_msg db '用户开通成功！', 0
    password_msg db '请输入密码：', 0
    fail_msg db '用户开通失败！', 0
    user GROUP  db 'users', 0
    nerr equ 2226 ;Error code for user already exist

section .text
    global _start

_start:
    ; 检查命令行参数
    cmp dword [esp+4], 3
    jne invalid_args

    ; 获取用户名和密码
    mov eax, [esp+8] ; 用户名（argv[1]）
    mov ecx, [esp+12] ; 密码（argv[2]])

    ; 开通用户
    push 0 ; options (reserved)
    push ecx ; password
    push eax ; username
    push 0 ; level (USER_PRIV_USER)
    push 1 ; new_user
    push offset user ; local_group
    push 0 ; flags
    call NetUserAdd
    add esp, 28 ; 清理堆栈

    ; 检查开通用户的结果
    cmp eax, 0
    je success
    cmp eax, nerr
    je already_exist
    jmp fail

success:
    ; 输出成功提示
    mov eax, 4 ; file descriptor: STDOUT
    mov ebx, 1 ; buffer
    mov ecx, user_msg ; message
    mov edx, 13 ; message length
    int 0x80 ; system call

    ; 退出程序
    mov eax, 1 ; system call number for exit
    xor ebx, ebx ; exit status
    int 0x80 ; system call

already_exist:
    ; 输出用户已存在提示
    mov eax, 4 ; file descriptor: STDOUT
    mov ebx, 1 ; buffer
    mov ecx, fail_msg ; message
    mov edx, 13 ; message length
    int 0x80 ; system call

    ; 退出程序
    mov eax, 1 ; system call number for exit
    xor ebx, ebx ; exit status
    int 0x80 ; system call

fail:
    ; 输出失败提示
    mov eax, 4 ; file descriptor: STDOUT
    mov ebx, 1 ; buffer
    mov ecx, fail_msg ; message
    mov edx, 13 ; message length
    int 0x80 ; system call

    ; 退出程序
    mov eax, 1 ; system call number for exit
    xor ebx, ebx ; exit status
    int 0x80 ; system call

invalid_args:
    ; 输出参数错误提示
    mov eax, 4 ; file descriptor: STDOUT
    mov ebx, 1 ; buffer
    mov ecx, invalid_args_msg ; message
    mov edx, 14 ; message length
    int 0x80 ; system call

    ; 退出程序
    mov eax, 1 ; system call number for exit
    xor ebx, ebx ; exit status
    int 0x80 ; system call
