#include <windows.h>

extern int main_asm(); // 汇编代码中的主函数

int main() {
    main_asm(); // 调用汇编代码中的主函数
    return 0;
}
