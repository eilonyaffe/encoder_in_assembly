section .data
    flag_in db "IFLAG", 10, 0
    flag_out db "OFLAG", 10, 0
    Infile dd 0
    Outfile dd 1
    newline db 10,0
    buff db 0

section .text
    global _start
    global encode
    global handle_input
    global handle_output
    WRITE EQU 4
    READ EQU 3
    EXIT EQU 1
    OPEN EQU 5
    STDOUT EQU 1

_start:
    push ebp
    mov ebp, esp
    pushad

    mov ecx, [ebp+8]
    mov edi, 2

input_output:
    call handle_input
    call handle_output

loop:
    mov eax, READ
    mov ebx, [Infile]
    mov ecx, buff
    mov edx, 1
    int 0x80

    cmp eax, 0
    je quit
    call encode

    mov eax, WRITE
    mov ebx, [Outfile]
    mov ecx, buff
    int 0x80
    jmp loop

encode:
    mov al, [buff]
    cmp al, 'a'
    jl check_case
    cmp al, 'z'
    jg end_encode
    inc al
    cmp al, 'z'
    jle end_encode
    mov al, 'a'

check_case:
    cmp al, 'A'
    jl end_encode
    cmp al, 'Z'
    jg end_encode
    inc al
    cmp al, 'Z'
    jle end_encode
    mov al, 'A'

end_encode:
    mov [ecx], al
    ret
    
write_newl:
    mov eax, WRITE
    mov edx, 1
    mov ecx, newline
    mov ebx, [Outfile]
    int 0x80
    ret

handle_input:
    mov ecx, [ebp+8]
    mov edi, 2

try_inputfile:
    cmp byte [ecx], '-'
    jnz next_arg_inputfile
    inc ecx
    cmp byte [ecx], 'i'
    jnz next_arg_inputfile
    inc ecx

    mov eax, OPEN
    mov ebx, ecx ; after inc
    mov ecx, 2|64 ; Flags: read-write (O_RDWR) and create if not found (O_CREAT)
    mov edx, 0777 ; File permissions
    int 0x80
    mov [Infile], eax

    mov eax, WRITE
    mov ecx, flag_in
    mov ebx, STDOUT
    mov edx, 7
    int 0x80
    ret

next_arg_inputfile:
    inc edi
    mov ecx, [ebp+4*edi]
    cmp ecx, 0
    jz ending_inputfile
    jmp try_inputfile

ending_inputfile:
    ret

handle_output:
    mov ecx, [ebp+8]
    mov edi, 2

try_outputfile:
    cmp byte [ecx], '-'
    jnz next_arg_outputfile
    inc ecx
    cmp byte [ecx], 'o'
    jnz next_arg_outputfile
    inc ecx

    mov eax, OPEN
    mov ebx, ecx ; after inc
    mov ecx, 2|64|0x400 ; Flags: read-write (O_RDWR) and create if not found (O_CREAT), append (O_APPEND)
    mov edx, 0777 ; File permissions
    int 0x80
    mov [Outfile], eax

    mov eax, WRITE
    mov ecx, flag_out
    mov ebx, STDOUT
    mov edx, 7
    int 0x80

    ret

next_arg_outputfile:
    inc edi
    mov ecx, [ebp+4*edi]
    cmp ecx, 0
    jz ending_outputfile
    jmp try_outputfile

ending_outputfile:
    ret



quit:
    call write_newl
    popad
    mov esp, ebp
    pop ebp

    mov eax, EXIT
    mov ebx, 0
    int 0x80
