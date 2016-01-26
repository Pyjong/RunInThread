#include <windows.h>
#include "RunInThread.h"


void printfn(UINT i, UINT j, UINT k)
{
    //printf("haha %d: %d\n", i, GetThreadId(GetCurrentThread()));
    printf("haha %d %d %d\n", i, j , k);
}

int main()
{
    ULONGLONG i = 5;
    ULONGLONG h = 7;
    
    //printf("%d\n", sizeof(i, (ULONGLONG)4000, (ULONGLONG)2));
    
    RunInThread(printfn, (ULONGLONG)7, (ULONGLONG)99, (ULONGLONG)100);
    RunInThread(printfn, i, (ULONGLONG)4000, (ULONGLONG)2);
    RunInThread(printfn, h, (ULONGLONG)20, (ULONGLONG)20);
    
    /*printf("size = %d\n", size(i));
    printf("size = %d\n", size(h));
    printf("size = %d\n", size((const char*)"hahahahaha"));
    printf("size = %d\n", sizeof("hahahahaha"));*/
    
    //printfn(2);
    //printfn(2);
    Sleep(2000);
}