STSEG  SEGMENT  PARA  STACK  "STACK"
    DB 64 DUP ( "STACK" ) 
STSEG  ENDS

DSEG  SEGMENT  PARA  PUBLIC  "DATA"
    msg_x db 'input x: $'
    msg_z db 'z = $'
    z dw 0
    x dw 0
DSEG  ENDS 



CODE  SEGMENT PARA PUBLIC  "CODE"
MAIN  PROC  FAR 
ASSUME  CS: CODE, DS: DSEG, SS:STSEG
    push DS
    XOR ax, ax
    push ax
    mov ax, DSEG
    mov DS, ax
    
    
    mov ah, 9
    lea dx, msg_x          
    int 21h
    call input_number     
    
    mov word [x], ax
    
    
    
    cmp word [x], 5
    jle less_equ_5       
    mov ax, 35
    imul word [x]       
    imul word [x]
    sub ax, 15
    jmp endmath
less_equ_5:             ; прыгаем сюда если число меньше или равно пяти
    cmp word [x], 0
    jle less_equ_0
    mov ax, 10
    mov bx, word [x]    
    idiv bx
    jmp endmath
less_equ_0:             ; прыгаем сюда если число меньше или равно нулю
    mov ax, 215         
    sub ax, word [x]    
endmath:
    mov word[z], ax    
    mov ah, 09h
    lea dx, msg_z       
    int 21h
    mov ax, word [z]    
    call output_number  ; выводим наш результат
    
    mov ah, 4ch         ; выход
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