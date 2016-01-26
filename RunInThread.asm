; -------------------------------------------------------
; Module name: RunInThread.asm
;
; Author: Pyjong (koutnji2@gmail.com)
;
; Description:
;
;   Module exports _RunInThread. The purpose of the
;   function is to spare the programmer of tedious
;   context forwarding to threaded functions by co-
;   pying __VA_ARGS__ in place of PVOID parameter
;   from CreateThread.
;
; -------------------------------------------------------

extern CreateThread
extern CreateEventA
extern SetEvent
extern WaitForSingleObject
extern CloseHandle
global _RunInThread



bits 64

struc Context_int
    .pFnAddr:     resq 1
    .hEvent:      resq 1
    .pParamAddr:  resq 1
    .nParams:     resq 1
    .size:
endstruc

section .text

; rcx = parameter size in bytes, preserved
; rdx = parameter address, preserved
; r9  = destination, preserved
CopyParam:
    
    sub  rsp,     10h
    mov  [rsp],   rdx
    mov  [rsp+8h],rcx
    xor  rax,     rax
    add  rdx,     rcx
    dec  rdx
    
.L1:
    shl  rax, 8
    mov  al,  [rdx]
    dec  rdx
    loop CopyParam.L1
    
    mov [r9], rax
    
    mov rdx, [rsp]
    mov rcx, [rsp+8h]
    add rsp, 10h
    ret

RunInThread_int:
; ------------------------------------------------------------
; Classic StartAddress - ?? fastcall (*fn)(Context_int* ctx);
;
; Description:
;
;   Pretty much memcpy that calls SetEvent(ctx->hEvent) to
;   signal copying has finished. We also move the ret addr
;   under the parameters.
;
; Note:
;
;   In x64 calling convention is not WINAPI as stated by msdn.
;   It is __fastcall.
;
; ------------------------------------------------------------
    
    %define locVar_FnAddr (rsp + 28h + 20h - 08h)
    %define locVar_rcx    (rsp + 28h + 20h - 10h)
    %define locVar_rdx    (rsp + 28h + 20h - 18h)
    %define locVar_r8     (rsp + 28h + 20h - 20h)
    %define locVar_r9     (rsp + 28h + 20h - 28h)
    %define stack_params  (rsp + 20h - 08h)
    
    mov [rsp + 10h], rbx    ; consider this an optimization
                            ; rbx is going to be used as variable paramters size
    ;mov [rsp + 08h], rcx    ; save pointer to context
    
    sub rsp, 28h + 20h    ; 38h locVars + 20h params + ?? params
    
    ; ------------------------------------------
    ; Stack layout (after local allocations):
    ;
    ;   system return address       8 bytes
    ;   locVar_FnAddr               8 bytes
    ;   locVar_rcx                  8 bytes
    ;   locVar_rdx                  8 bytes
    ;   locVar_r8                   8 bytes
    ;   locVar_r9                   8 bytes
    ;   stack params for Fn         nParams - register params size
    ;   param r9                    8 bytes
    ;   param r8                    8 bytes
    ;   param rdx                   8 bytes
    ;   param rcx                   8 bytes
    ;   local cleanup return addr   8 bytes  - allocated by call
    ; ------------------------------------------
    
    ;
    ; Copy parameters
    ;
    
    ; Set up
    mov r8,  rcx                            ; r8  = ctx
    mov rcx, [r8 + Context_int.nParams]    ; rcx = ctx->nParams
    mov rdx, [r8 + Context_int.pParamAddr]  ; rdx = ctx->pParamAddr
    mov r9,  [r8 + Context_int.pFnAddr]     ; r9  = ctx->pFnAddr
    mov [locVar_FnAddr], r9                 ; locVar = pFnAddr

    test rcx, rcx
    jz   RunInThread_int.cya
    
    ; These are going to be copied into registers right before jumping
    
    ; copy rcx to local variable
    lea  r9,  [locVar_rcx]
    mov  rax, [rdx]
    mov [r9],  rax
    dec qword [r8 + Context_int.nParams] 
    jz .cya
    
    ; copy rdx to local variable
    add  rdx, 8
    
    lea  r9,  [locVar_rdx]
    mov  rax, [rdx]
    mov [r9],  rax
    dec qword [r8 + Context_int.nParams]
    jz .cya
    
    ; copy r8 to local variable
    add  rdx, 8
    
    lea  r9,  [locVar_r8]
    mov  rax, [rdx]
    mov [r9],  rax
    dec qword [r8 + Context_int.nParams]
    jz .cya
    
    ; copy r9 to local variable
    add  rdx, 8
    
    lea  r9,  [locVar_r9]
    mov  rax, [rdx]
    mov [r9],  rax
    dec qword [r8 + Context_int.nParams]
    jz .cya
    
    ;
    ; Now copy the rest of the parameters from __VA_ARGS__ in RunInThread
    ; to stack.
    ;
    mov     rcx, [r8 + Context_int.nParams]
    sal     rcx, 3
    sub     rsp, rcx                            ; now we know how many bytes do the stack paramters need
    ;lea     rsp, [rsp - rcx*8]
    sar     rcx, 3
    
.L1:
    add     rdx, 8
    mov     rax, [rdx]
    mov    [rsp + rcx*8 + 18h], rax
    loop    RunInThread_int.L1
    
.cya:
    ; Call SetEvent to signalize copying has been done
    mov  rbx, r8                        ; save rbx
    mov  rcx, [r8 + Context_int.hEvent] ; Context.hEvent
    call SetEvent                       ;
    
    ; set regs, we don't care about the garbage on stack
    ; valid behaviour for fastcalls
    mov rcx, [rbx + Context_int.nParams]
    lea rbx, [rcx*8]
    
    mov rcx, [locVar_rcx + rbx]
    mov rdx, [locVar_rdx + rbx]
    mov r8,  [locVar_r8  + rbx]
    mov r9,  [locVar_r9  + rbx]
    
    ; Jump to requested fn
    call     [locVar_FnAddr + rbx]

RunInThread_cleanup:

    add rsp, 28h + 20h
    add rsp, rbx
    mov rbx, [rsp + 10h]  ; restore original rbx
    
    ret
    
    
    
_RunInThread:
; ------------------------------------------------------------------------------
; HANDLE __fastcall _RunInThread(DWORD WINAPI (*fn)(PVOID), DWORD nParams, ...)
;
;   Description:
;
;       Function creates Context_int structure and calls CreateThread on
;       RunInThread_int with Context_int as parameter.
;
;       RunInThread_int copies parameters from Context_int to it's stack in
;       place of it's parameters.
;
;   Return value:
;
;       pass CreateThread()
;
; ------------------------------------------------------------------------------
    
    mov     [rsp + 8h],  rcx
    mov     [rsp + 10h], rdx
    mov     [rsp + 18h], r8
    mov     [rsp + 20h], r9
    sub     rsp, Context_int.size + 30h + 8h  ; 30h for args to make calls
                                              ; 8h  for thread handle
    
    %define retaddr_ptr (rsp + Context_int.size + 38h)
    %define context_ptr (retaddr_ptr - Context_int.size)
    %define hThread_ptr (retaddr_ptr - Context_int.size - 08h)
    
    ;
    ; CreateEvent
    ;
    xor rcx, rcx
    xor rdx, rdx
    xor r8,  r8
    xor r9,  r9
    call CreateEventA
    
    ; rcx = &Context_int;
    lea     rcx, [context_ptr]
    
    ; Context_int.hEvent = CreateEvent()
    mov     [rcx + Context_int.hEvent], rax
    
    ; Context_int.pFnAddr = fn;
    ; rax = "spilled" rcx
    mov     rax, [retaddr_ptr + 08h]
    mov     [rcx + Context_int.pFnAddr], rax
    
    ; Context_int.nParams = nParams;
    mov     rax, [retaddr_ptr + 10h]
    mov     [rcx + Context_int.nParams], rax
    
    ; Context_int.pParamAddr = ...;
    lea     rax, [retaddr_ptr + 28h]
    mov     [rcx + Context_int.pParamAddr], rax
    
    ; Call CreateThread
    xor     rcx, rcx
    xor     rdx, rdx
    mov     r8,  RunInThread_int
    lea     r9,  [context_ptr]
    mov     [rsp + 20h], rcx
    mov     [rsp + 28h], rcx
    call    CreateThread
    mov     [hThread_ptr], rax
    
    test    rax, rax
    jz      _RunInThread.good_ending    ; failure, but no memory corruption
    
    ; WaitForSingleObject(Context.hEvent, INFINITE)
    mov     rcx, [context_ptr + Context_int.hEvent]
    xor     rdx, rdx
    dec     rdx                         ; INFINITE = -1
    call    WaitForSingleObject
    
    test    rax, rax
    jnz     _RunInThread.bad_ending     ; bad bad very baaad if this happened
    
    ; CloseHandle(Context_int.hEvent)
    mov     rcx, [context_ptr + Context_int.hEvent]
    call    CloseHandle
    
.good_ending:
    ; rax = thread handle
    mov     rax, [hThread_ptr]
    add     rsp, Context_int.size + 38h
    ret
    
    ; probably gonna crash anyway
.bad_ending:
    mov     rcx, [hThread_ptr]
    call    CloseHandle                 ; CloseHandle(hThread)
    xor     rax, rax
    add     rsp, Context_int.size + 38h
    ret
