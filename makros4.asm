OUTPUT_STR MACRO STR
    PUSH AX
    push dx
    MOV AH, 09h
    MOV DX, OFFSET STR
    INT 21h
    pop dx
    POP AX
ENDM


NEW_LINE MACRO
    push ax
    push dx
    mov dl, 10
    mov ah, 2
    int 21h
    pop dx
    pop ax
endm

EXIT MACRO
    mov ah,4ch
    int 21h
endm

STSEG  SEGMENT  PARA  STACK  "STACK"
    DB 64 DUP ( "STACK" ) 
STSEG  ENDS

DSEG  SEGMENT  PARA  PUBLIC  "DATA"
    array_1d dw 10 DUP(0)
    first_ex_msg db 'input array of 10 numbers', 0ah , 24h
    first_ex_msg_out db 'sum : $'
    min_msg db 'min element: ', 24h
    max_msg db 'max element: ', 24h
    sort_msg db 'sorted array: ', 0ah ,24h
DSEG  ENDS 



CODE  SEGMENT PARA PUBLIC  "CODE"
MAIN  PROC  FAR 
ASSUME  CS: CODE, DS: DSEG, SS:STSEG
    push DS
    XOR ax, ax
    push ax
    mov ax, DSEG
    mov DS, ax
    
    output_str first_ex_msg
    mov cx, 0
start_loop_inp_num:             ; ввод массива
    cmp cx, 20
    je end_loop_inp_num
    push cx
    call input_number
    pop cx
    lea bx, array_1d
    add bx, cx
    mov word [bx], ax
    add cx, 2
    jmp start_loop_inp_num
end_loop_inp_num:
    new_line
    
    mov cx, 0
    mov ax, 0
    lea bx, array_1d
sum_loop:                       ; цикл прощета суммы
    cmp cx, 20
    je end_sum_loop
    add ax, word [bx]
    add bx, 2
    add cx, 2
    jmp sum_loop    
end_sum_loop:
    mov bx, ax
    mov ah, 9h
    lea dx, first_ex_msg_out
    int 21h
    mov ax, bx
    call output_number          ; вывод суммы
    new_line
    mov ax, word [array_1d] ; min element
    mov dx, word [array_1d] ; max element
    mov cx, 0
    lea bx, array_1d
min_max_loop:               ; цикл поиска минимума и максимума 
    cmp cx, 20
    je end_min_max_lopp
    cmp ax, word [bx]
    jle not_min_element
    mov ax, word [bx]
not_min_element:
    
    cmp dx, word [bx]
    jge not_max_element
    mov dx, word [bx]
not_max_element:
    add bx, 2
    add cx, 2
    jmp min_max_loop
end_min_max_lopp:           ; конец цикла
    
    mov cx, ax
    mov bx, dx
    output_str min_msg
    
    mov ax, cx
    call output_number
    new_line
    
    output_str max_msg
    mov ax, bx
    call output_number      ; вывод результата
    new_line
    

sort_main_loop:             ; цикл сортировки
    mov di, 0               ; errors 
    mov cx, 0
    lea bx, array_1d     
    mov ax, word [bx]
    add bx, 2           
sort_step:                  
    cmp cx, 18              
    je end_sort_step        
    cmp ax, word [bx]       
    jle ok_step 
    inc di                  
    push cx
    mov cx, ax
    mov si, word [bx]
    sub bx, 2
    mov word [bx], si
    add bx, 2
    mov word [bx], cx
    pop cx
ok_step:
    mov ax, word [bx]
    add cx, 2
    add bx, 2
    jmp sort_step
end_sort_step:              ; конец цикла сортировки

    cmp di, 0
    jne sort_main_loop
end_sort:
    
    output_str sort_msg
    
    mov cx, 0
    lea bx, array_1d
sorted_array:               ; вывод сортированного массива
    cmp cx, 20
    je end_sorted
    mov ax, word [bx]
    call output_number
    mov dl, 32
    mov ah, 2
    int 21h
    add bx, 2
    add cx, 2
    jmp sorted_array
end_sorted:  
    new_line
    mov ah, 4ch
    mov al, 1
    int 21h
MAIN ENDP

input_number PROC
    mov dx, 0
    mov ax, 0
    mov cx, 0
    mov bx, 0
    mov di, 1
start_read:
    mov ah, 01h    
    int 21h
    cmp al, 32
    je end_read
    cmp al, 10
    je end_read
    cmp al, 13
    je end_read
    cmp al, 45
    jne not_minus
    cmp dx, 0
    jne read_number_err
    mov di, -1
    jmp start_read
not_minus:
    cmp al, 48
    jge num_greater_48
    jmp read_number_err
num_greater_48:
    cmp al, 57
    jle num_less_57
    jmp read_number_err
num_less_57:
    sub al, 48
    xor ch, ch      
    mov cl, al
    mov ax, dx
    mov bx, 10
    imul bx
    add ax, cx
    mov dx, ax    
    jmp start_read 

end_read:
    mov ax, dx
    imul di
    ret
read_number_err:
    mov ax, 0
    ret
input_number ENDP

output_number PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov dx, 0
    mov bx, 10
    mov cx, 0
    cmp ax, 0
    je out_null
    cmp ax, 0
    jg out_greater_null
    push ax
    push dx
    mov dl, 45
    mov ah, 2
    int 21h
    pop dx
    pop ax
    mov bx, -1
    imul bx
    mov bx, 10
out_greater_null:
    cmp ax, 0
    je end_output_number
    mov dx, 0
    idiv bx
    add dx, 48
    push dx
    inc cx
    jmp out_greater_null
end_output_number:
    pop dx
    mov ah, 2
    int 21h
    loop end_output_number
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
out_null:
    mov dl, 48
    mov ah, 2
    int 21h
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
output_number ENDP


CODE ENDS 
END MAIN 