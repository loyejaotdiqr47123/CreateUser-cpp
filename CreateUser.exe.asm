section .data
    successMsg db "用户创建成功！", 0
    failureMsg db "用户创建失败！", 0
    netapi32Lib db "netapi32.dll", 0
    pNetUserAdd db "NetUserAdd", 0
    pNetLocalGroupAddMembers db "NetLocalGroupAddMembers", 0
    userName db 256 dup(0)
    password db 256 dup(0)
    groupName db "Users", 0

section .text

global main

extern GetCommandLineA
extern CommandLineToArgvA
extern NetUserAdd
extern NetLocalGroupAddMembers

main:
    ; 获取命令行参数
    call GetCommandLineA
    mov esi, eax ; save command line address
    
    push 0 ; argument count
    push esi ; command line
    call CommandLineToArgvA
    add esp, 8
    mov edi, eax ; save argument list pointer
    
    ; 参数个数
    mov ecx, dword [edi]
    cmp ecx, 3
    jne end
    
    ; 参数1
    mov eax, dword [edi + 4]
    mov ebx, userName
    mov ecx, 256
    rep movsb
    
    ; 参数2
    mov eax, dword [edi + 8]
    mov ebx, password
    mov ecx, 256
    rep movsb
    
    ; 加载 netapi32.dll
    push netapi32Lib
    call LoadLibraryA
    mov ecx, eax ; save library handle
    
    ; 获取 NetUserAdd 函数地址
    push pNetUserAdd
    push ecx ; library handle
    call GetProcAddress
    mov ebx, eax ; save function address
    
    ; 获取 NetLocalGroupAddMembers 函数地址
    push pNetLocalGroupAddMembers
    push ecx ; library handle
    call GetProcAddress
    mov ecx, eax ; save function address
    
    ; 创建用户名结构体
    push 0 ; level
    push 2 ; V2_USER_INFO
    push 0 ; reserved
    push 0 ; SID (we don't need it)
    push password ; password
    push userName ; username
    push 0 ; home directory
    push 0 ; comment
    mov esi, esp ; save struct pointer
    
    ; 调用 NetUserAdd
    push 0 ; parm_err
    call ebx ; function address
    add esp, 4 * 9
    
    cmp eax, 0 ; 检查返回值
    jne fail ; 跳转到失败处理
    
    ; 添加到本地组Users
    push 0 ; level
    push esi ; user info (NetUserAdd)
    push groupName ; local group name
    push 0 ; Comment
    mov ebx, esp ; save struct pointer
    
    ; 调用 NetLocalGroupAddMembers
    push 0 ; total entries
    call ecx ; function address
    add esp, 4 * 4
    
    jmp end
    
fail:
    ; 用户创建失败提示
    push failureMsg
    call MessageBoxA
    add esp, 8
    
    jmp end
    
end:
    ; 用户创建成功提示
    push successMsg
    call MessageBoxA
    add esp, 8
    
    ret
