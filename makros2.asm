OUTPUT_STR MACRO STR
    PUSH AX
    push dx
    MOV AH, 09h
    MOV DX, OFFSET STR
    INT 21h
    pop dx
    POP AX
ENDM

GET_CHAR MACRO
    MOV AH, 1h
    INT 21h
ENDM

EXIT MACRO
    mov ah,4ch
    int 21h
endm

IDEAL
MODEL SMALL
STACK 512

DATASEG;
buf DB "             ", 13, 10, '$'
error_message DB "Error! Input data out of bounds!", 13, 10, '$' 
result_buf DB "result:       ", 13, 10, '$' 


CODESEG
Start:
    
    mov ax,@data; 
    mov ds, ax  
    mov es, ax  
    
    mov al,7               
    push cx                 
    mov cx,ax               
    mov ah,0Ah              
    mov [buf],al         
    mov [buf+1],0    
    mov dx,offset buf   
    int 21h                 
    mov al,[buf+1]       
    add dx,2                
    mov ah,ch               
    pop cx 
    
    push bx                 
    push dx

    test al,al              
    jz flag1_error         
    mov bx,dx               
    mov bl,[bx]             
    cmp bl,'-'              
    jne general       
    inc dx                  
    dec al                  
general:
    call read1   
    jc flag1_error          
    cmp bl,'-'             
    jne plus          
    cmp ax,32767            
    ja flag1_error          
    jmp middle_f            
plus:
    cmp ax,32767            
    ja flag1_error          
 
middle_f:
    clc                     
    jmp flag1_exit         
flag1_error:
    output_str error_message 
    xor dx, dx
    xor ax,ax             
    exit
flag1_exit:
    pop dx                 
    pop bx
    

    mov bx, [ds:0002] 
    cmp bl, 02Dh 
    je negative;
    jmp positive;
negative:
    mov bx, offset result_buf
    mov [bx+8], '-'
positive:
    mov bx, 4
    mul bx
    mov bx, offset result_buf
    call output

exit 
    
PROC read1
    push cx                
    push dx
    push bx
    push si
    push di
 
    mov si,dx               
    mov di,10               
    mov cl,al               
    jcxz flag_error        
    xor ax,ax               
    xor bx,bx              
 
l1:
    mov bl,[si]             
    inc si                  
    cmp bl,'0'             
    jl flag_error          
    cmp bl,'9'              
    jg flag_error          
    sub bl,'0'              
    mul di                  
    jc flag_error         
    add ax,bx               
    jc flag_error          
    loop l1           
    jmp flag_end          
 
flag_error:
    xor ax,ax               
    stc                     

flag_end:
    pop di                 
    pop si
    pop bx
    pop dx
    pop cx
    ret
ENDP


PROC output  
    mov di,offset result_buf    
    mov cx, 9
    loop1:
        INC di
        loop loop1
    push cx 
    push dx
    push bx
    mov bx,10   
    XOR CX,CX 
a:   XOR dx,dx
    DIV bx      
    PUSH DX     
    INC CX
    TEST AX,AX
    JNZ a
b:   POP AX
    ADD AL,'0'  
    STOSb       
    LOOP b     
    call last_p
ret 
ENDP output

 

PROC last_p
    pop bx      
    POP dx
    POP cx 
    mov dx, offset result_buf 
    mov ah,9
    int 21h
    xor dx, dx
    exit
    ret
ENDP 
end Start
