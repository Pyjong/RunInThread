#ifndef __RUN_IN_THREAD__
#define __RUN_IN_THREAD__

#include <windef.h>

#define EXPAND( x ) x

#define __NARGS(_0, _1, _2, _3, _4, VAL, ...) VAL
#define NARGS_1(...) EXPAND(__NARGS(__VA_ARGS__, 5, 4, 3, 2, 1, 0))
    
#define LIST0
#define LIST1(a) sizeof(a), a
#define LIST2(a, b) sizeof(a), a, sizeof(b), b
#define LIST3(a,b,c) sizeof(a), a, sizeof(b), b, sizeof(c), c
#define LIST4(a,b,c,d) sizeof(a), a, sizeof(b), b, sizeof(c), c, sizeof(d), d
#define LIST5(a,b,c,d,e) sizeof(a), a, sizeof(b), b, sizeof(c), c, sizeof(d), d, sizeof(e), e
#define LIST6(a,b,c,d,e,f) sizeof(a), a, sizeof(b), b, sizeof(c), c, sizeof(d), d, sizeof(e), e, sizeof(f), f
#define LIST7(a,b,c,d,e,f,g) sizeof(a), a, sizeof(b), b, sizeof(c), c, sizeof(d), d, sizeof(e), e, sizeof(f), f, sizeof(g), g
#define LIST8(a,b,c,d,e,f,g,h) sizeof(a), a, sizeof(b), b, sizeof(c), c, sizeof(d), d, sizeof(e), e, sizeof(f), f, sizeof(g), g, sizeof(h), h

#define LIST_ALL_imp_2(n, ...) EXPAND(LIST##n(__VA_ARGS__))
#define LIST_ALL_imp_1(n, ...) LIST_ALL_imp_2(n, __VA_ARGS__)
#define LIST_ALL(...) LIST_ALL_imp_1(NARGS_1(__VA_ARGS__), __VA_ARGS__)
 
#define RunInThread(fn, ...) \
    _RunInThread(fn, NARGS_1(__VA_ARGS__) * 8, 0, 0, LIST_ALL(__VA_ARGS__))
 
HANDLE
__fastcall
_RunInThread(PVOID function, DWORD szParams, DWORD Reserved, DWORD Reserved2, ...);

#endif
