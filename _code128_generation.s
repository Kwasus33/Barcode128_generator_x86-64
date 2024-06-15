BITS 64

section .data

codes   dw  0x6cc, 
        dw  0x66c, 
        dw  0x666, 
        dw  0x498,	
        dw  0x48c, 
        dw  0x44c, 
        dw  0x4c8, 
        dw  0x4c4, 
        dw  0x464, 
        dw  0x648, 
        dw  0x644, 
        dw  0x624, 
        dw  0x59c, 
        dw  0x4dc, 
        dw  0x4ce, 
        dw  0x5cc, 
        dw  0x4ec, 
        dw  0x4e6, 
        dw  0x672, 
        dw  0x65c, 
        dw  0x64e, 
        dw  0x6e4, 
        dw  0x674, 
        dw  0x76e, 
        dw  0x74c, 
        dw  0x72c, 
        dw  0x726, 
        dw  0x764, 
        dw  0x734, 
        dw  0x732, 
        dw  0x6d8, 
        dw  0x6c6, 
        dw  0x636, 
        dw  0x518, 
        dw  0x458, 
        dw  0x446, 
        dw  0x588, 
        dw  0x468, 
        dw  0x462, 
        dw  0x688, 
        dw  0x628, 
        dw  0x622, 
        dw  0x5b8, 
        dw  0x58e, 
        dw  0x46e, 
        dw  0x5d8, 
        dw  0x5c6, 
        dw  0x476, 
        dw  0x776, 
        dw  0x68e, 
        dw  0x62e, 
        dw  0x6e8, 
        dw  0x6e2, 
        dw  0x6ee, 
        dw  0x758, 
        dw  0x746, 
        dw  0x716, 
        dw  0x768, 
        dw  0x762, 
        dw  0x71a, 
        dw  0x77a, 
        dw  0x642, 
        dw  0x78a, 
        dw  0x530, 
        dw  0x50c, 
        dw  0x4b0, 
        dw  0x486, 
        dw  0x42c, 
        dw  0x426, 
        dw  0x590, 
        dw  0x584, 
        dw  0x4d0, 
        dw  0x4c2, 
        dw  0x434, 
        dw  0x432, 
        dw  0x612, 
        dw  0x650, 
        dw  0x7ba, 
        dw  0x614, 
        dw  0x47a, 
        dw  0x53c, 
        dw  0x4bc, 
        dw  0x49e, 
        dw  0x5e4, 
        dw  0x4f4, 
        dw  0x4f2, 
        dw  0x7a4, 
        dw  0x794, 
        dw  0x792, 
        dw  0x6de, 
        dw  0x6f6, 
        dw  0x7b6, 
        dw  0x578, 
        dw  0x51e, 
        dw  0x45e, 
        dw  0x5e8, 
        dw  0x5e2, 
        dw  0x7a8, 
        dw  0x7a2, 
        dw  0x5de, 
        dw  0x5ee, 
        dw  0x75e, 
        dw  0x7ae, 
        dw  0x684, 
        dw  0x690, 
        dw  0x69c, 
        dw  0x18eb


section .text
    global _code128_generation


img_width		EQU 0
img_height		EQU 4
img_linebytes	EQU 8
img_bitsperpel	EQU 12
img_pImg		EQU	16

startB_offset	EQU 104
stop_offset		EQU 212
divisor 		EQU 103 


_code128_generation:
    push rbp
    mov rbp, rsp
    push rbx
	push rsi
	push rdi
    ; stack addresses every 8 bytes (64bits)
    add rsi, [rdi + img_pImg]   ;rdi -> imgInfo *im, rsi -> x
    mov rdi, rsi
    mov rsi, rdx                ; rdx -> Text ptr
    mov r9b, cl                 ; rcx -> check Sign
                                ; r8 -> bar Size
	mov cl, 0x0                 ; works as a toggle

save_start_sign:
    xor eax, eax
    mov eax, startB_offset
	jmp load_sign_encoding

encode128_loop:
	xor eax, eax
	lodsb		                ; saves to AL sign from ESI, increaments ESI
    
	test al, al
    jz save_check_sign

    sub al, 32	                ; ascii and encoding table position difference - '0' in ascii is 48 in encoding table it's 16
    
load_sign_encoding:	
    mov dx, [codes + eax * 2]	; halfwords are stored every 2 bytes in 'codes' table
    xor ch, ch

separate_bits:
	cmp ch, 11		            ; checks if counter is 0
	je encode128_loop

    mov ax, dx  
	and ax, 0x400		        ; 11-bits mask with 11th bit from LSB set to 1
	shl dx, 1
    inc ch

    mov al, r8b                 ; barSize - limited to max 255

set_barsize_loop:               ;for pixels multipliction as given in barSize
    cmp al, 0
    je separate_bits
    
    movzx ebx, cl
    add edi, ebx
    dec al

    xor cl, 0x1

    cmp ah, 0
    je set_barsize_loop

set_pixel:
	mov ah, 0xF0
    shl cl, 2
	shr ah, cl                  ; in cl is 0 or 4 so it sets mask in ch to 0xF0 or 0x0F
    shr cl, 2                   ; shifts cl back to previous value

	xor [edi], ah               ; *pPix ^= mask
    jmp set_barsize_loop

save_check_sign:
    movzx eax, r9b
	mov dx, [codes + eax * 2]   ; dx stores checkSign value
    xor ch, ch

separate_check_sign_bits:
	mov ax, dx
	and ax, 0x400
	shl dx, 1
    inc ch

    cmp ch, 11
	jg save_stop_sign           ; jumps is at the end, it's easier to read code this way but while ch == 11 above operations are not needed

    mov al, r8b

set_barsize_loop_check_sign:
    cmp al, 0
    je separate_check_sign_bits
    
    movzx ebx, cl
    add edi, ebx
    dec al

    xor cl, 0x1

    cmp ah, 0
    je set_barsize_loop_check_sign

set_check_sign_pixels:
	mov ah, 0xF0
    shl cl, 2
	shr ah, cl
    shr cl, 2

    xor [edi], ah
    jmp set_barsize_loop_check_sign

save_stop_sign:
    mov eax, stop_offset
    mov dx, [codes + eax]
    xor ch, ch

separate_stop_sign_bits:
	mov ax, dx
	and ax, 0x1000
	shl dx, 1
    inc ch

    cmp ch, 13
	jg end

    mov al, r8b

set_barsize_loop_stop_sign:
    cmp al, 0
    je separate_stop_sign_bits
    
    movzx ebx, cl
    add edi, ebx
    dec al

    xor cl, 0x1

    cmp ah, 0
    je set_barsize_loop_stop_sign

set_stop_sihn_pixels:
	mov ah, 0xF0
    shl cl, 2
	shr ah, cl
    shr cl, 2

    xor [edi], ah
    jmp set_barsize_loop_stop_sign

end:
	mov rax, rdi
    pop rdi
	pop rsi
    pop rbx
	mov rsp, rbp
    pop rbp
    ret

