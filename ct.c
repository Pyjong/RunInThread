#include <windows.h>
#include "RunInThread.h"


void printfn(UINT i, UINT j, UINT k)
{
    //printf("haha %d: %d\n", i, GetThreadId(GetCurrentThread()));
    printf("haha %d %d %d\n", i, j , k);
}

void printfn2(UINT i, UINT j, UINT k, UCHAR* str)
{
    //printf("haha %d: %d\n", i, GetThreadId(GetCurrentThread()));
    printf("haha %d %d %d %s\n", i, j , k, str);
}

void lprintfn(UINT i, UINT j, UINT k, UINT l, UINT m, ULONGLONG n, ULONGLONG o)
{
    printf("serious %d %d %d %d %d %lld %lld\n", i, j , k, l , m, n, o);
}

int main()
{
    ULONGLONG i = 5;
    ULONGLONG h = 7;
    
    //printf("%d\n", sizeof(i, (ULONGLONG)4000, (ULONGLONG)2));
    
    RunInThread(printfn, 7, 99, 100);
    RunInThread(printfn2, i, 4000, 2, (const char*)"hello hello");
    RunInThread(lprintfn, h, 20, 20, 20, 30, 30LL, 30LL);
    
    /*printf("size = %d\n", size(i));
    printf("size = %d\n", size(h));
    printf("size = %d\n", size((const char*)"hahahahaha"));
    printf("size = %d\n", sizeof("hahahahaha"));*/
    
    //printfn(2);
    //printfn(2);
    Sleep(2000);
}