#ifndef __RUN_IN_THREAD__
#define __RUN_IN_THREAD__

#include <windef.h>

#define EXPAND( x ) x

#define __NARGS(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, VAL, ...) VAL
#define NARGS_1(...) EXPAND(__NARGS(__VA_ARGS__, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0))
 
#define RunInThread(fn, ...) \
    _RunInThread(fn, NARGS_1(__VA_ARGS__), 0, 0, __VA_ARGS__)

HANDLE
__fastcall
_RunInThread(PVOID function, DWORD nParams, DWORD Reserved, DWORD Reserved2, ...);

#endif
