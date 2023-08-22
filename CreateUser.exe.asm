section .data
    username db 'NewUser',0
    password db 'P@ssw0rd',0
    domain db 0
    info db '添加用户成功！',0
    error_info db '添加用户失败！错误代码：%d',0

section .text
    global main
    extern NetUserAdd
    extern NetLocalGroupAddMembers

main:
    
    push dword 0      
    push dword username
    push dword 1      
    push dword domain
    push dword password
    push dword 0      
    push dword 0      

    
    call NetUserAdd

    test eax, eax
    jnz error
    
    
    push dword 0    
    push dword 'Users'
    push dword domain
    push dword username

    
    call NetLocalGroupAddMembers

    test eax, eax
    jnz error

    push dword info
    call print

    jmp done

error:
    push eax
    push dword error_info
    call printf
    pop eax

done:
    ret

printf:
    pusha
    pushfd

    mov eax, 4          
    mov ebx, 1          
    mov ecx, esp        
    mov edx, 0x7FFFFFFF 
    int 0x80            

    popfd
    popa
    ret
