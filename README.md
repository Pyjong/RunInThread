# RunInThread
Auxiliary assembly function for x64 C to run threaded functions.

Eliminates the need to create context for WINAPI CreateThread function. Instead you just call RunInThread(function_ptr,...), 
eg.: HANDLE ThreadHandle = RunInThread(memcpy, dst, src, n);

The function works only with __fastcall functions. Parameters are copied to the created thread's stack so if passing local stack addresses
you are free to mangle the values as you please.
