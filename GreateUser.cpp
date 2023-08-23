#include <iostream>
#include <windows.h>
#include <lm.h>

void CreateUserAndAddToUsersGroup(LPCTSTR userName, LPCTSTR password)
{
    USER_INFO_1 userInfo;
    userInfo.usri1_name = const_cast<LPWSTR>(userName);
    userInfo.usri1_password = const_cast<LPWSTR>(password);
    userInfo.usri1_priv = USER_PRIV_USER;
    userInfo.usri1_home_dir = nullptr;
    userInfo.usri1_comment = nullptr;
    userInfo.usri1_flags = UF_SCRIPT;
    userInfo.usri1_script_path = nullptr;
  
    NET_API_STATUS status;
    DWORD paramErr;
  
    status = NetUserAdd(nullptr, 1, reinterpret_cast<PBYTE>(&userInfo), &paramErr);
  
    if (status == NERR_Success)
    {
        LOCALGROUP_MEMBERS_INFO_3 groupInfo;
        groupInfo.lgrmi3_domainandname = const_cast<LPWSTR>(userName);
        status = NetLocalGroupAddMembers(nullptr, L"Users", 3, reinterpret_cast<PBYTE>(&groupInfo), 1);
  
        if (status == NERR_Success)
        {
            std::cout << "用户创建成功并已加入Users组！" << std::endl;
        }
        else
        {
            std::cout << "用户创建成功，但加入Users组失败！" << std::endl;
        }
    }
    else
    {
        std::cout << "用户创建失败！错误代码：" << status << std::endl;
    }
}

int main(int argc, char* argv[])
{
    if (argc != 3)
    {
        std::cout << "使用格式: example.exe user password" << std::endl;
        return 1;
    }
  
    LPCTSTR userName = argv[1];
    LPCTSTR password = argv[2];
  
    CreateUserAndAddToUsersGroup(userName, password);
  
    return 0;
}
