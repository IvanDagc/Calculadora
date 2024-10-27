section .data
    msg_intro db "Bienvenido a la calculadora en ensamblador", 0xA, 0xD
    prompt_num1 db "Ingrese el primer número: ", 0xA, 0xD
    prompt_num2 db "Ingrese el segundo número: ", 0xA, 0xD
    prompt_op db "Ingrese la operación (+, -, *, /, %): ", 0xA, 0xD
    error_zero db "Error: División por cero", 0xA, 0xD
    error_op db "Error: Operación inválida", 0xA, 0xD
    msg_res db "Resultado: ", 0xA, 0xD
    exit_msg db "Escriba 'exit' para salir o cualquier tecla para continuar.", 0xA, 0xD

section .bss
    num1 resb 10
    num2 resb 10
    result resb 10
    buffer resb 30
    operation resb 2
section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_intro
    mov edx, 36
    int 0x80

loop:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_num1
    mov edx, 26
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, num1
    mov edx, 10
    int 0x80
    call parse_number1

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_num2
    mov edx, 26
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, num2
    mov edx, 10
    int 0x80
    call parse_number2

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_op
    mov edx, 35
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, operation
    mov edx, 2
    int 0x80

    mov al, [operation]
    cmp al, '+'
    je suma
    cmp al, '-'
    je resta
    cmp al, '*'
    je multiplicacion
    cmp al, '/'
    je division
    cmp al, '%'
    je modulo

    mov eax, 4
    mov ebx, 1
    mov ecx, error_op
    mov edx, 24
    int 0x80
    jmp loop

suma:
    mov eax, [num1]
    add eax, [num2]
    jmp mostrar_res

resta:
    mov eax, [num1]
    sub eax, [num2]
    jmp mostrar_res

multiplicacion:
    mov eax, [num1]
    imul eax, [num2]
    jmp mostrar_res

division:
    mov eax, [num2]
    cmp eax, 0
    je error_div_cero
    mov eax, [num1]
    cdq
    idiv dword [num2]
    jmp mostrar_res

modulo:
    mov eax, [num2]
    cmp eax, 0
    je error_div_cero
    mov eax, [num1]
    cdq
    idiv dword [num2]
    mov eax, edx
    jmp mostrar_res

error_div_cero:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_zero
    mov edx, 23
    int 0x80
    jmp loop

mostrar_res:
    add eax, '0'
    mov [result], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_res
    mov edx, 11
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, exit_msg
    mov edx, 60
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 4
    int 0x80

    cmp dword [buffer], 0x747865
    je salir

    jmp loop

salir:
    mov eax, 1
    mov ebx, 0
    int 0x80

parse_number1:
    mov esi, num1
    xor eax, eax
    xor ebx, ebx
    mov bl, [esi]          
    cmp bl, '-'
    jne parse_positive1
    inc esi                
    call parse_digits1
    neg eax                
    ret

parse_positive1:
    call parse_digits1
    ret

parse_digits1:
    mov ecx, 10
convert_loop1:
    mov bl, [esi]
    cmp bl, 0xA             
    je end_parse1
    sub bl, '0'
    imul eax, ecx
    add eax, ebx
    inc esi
    jmp convert_loop1
end_parse1:
    mov [num1], eax
    ret

parse_number2:
    mov esi, num2
    xor eax, eax
    xor ebx, ebx
    mov bl, [esi]
    cmp bl, '-'
    jne parse_positive2
    inc esi
    call parse_digits2
    neg eax
    ret

parse_positive2:
    call parse_digits2
    ret

parse_digits2:
    mov ecx, 10
convert_loop2:
    mov bl, [esi]
    cmp bl, 0xA
    je end_parse2
    sub bl, '0'
    imul eax, ecx
    add eax, ebx
    inc esi
    jmp convert_loop2
end_parse2:
    mov [num2], eax
    ret
