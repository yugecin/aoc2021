section .text
; If not using this name, my link.exe gives an unsuppressible warning that
; "entrypoint is not __stdcall with 12 bytes of args".
global __DllMainCRTStartup@12
__DllMainCRTStartup@12:
	mov eax, 1
	retn 0Ch

global aoc
aoc:
	push esi
	push ebx
	push edi

	; this'll work with a table containing the occurrences for each value
	; from AA to ZZ
	; then each iteration (step) apply the rule table to that table
	; (rule table says f.e. with AA -> B: put value of AA in AB and BA)
	; A=41 Z=5A
	; a rule table entry for AA -> B will look like "ABBA"
	; because AA results in AB and BA
	; NOP rule table entries look like "AA@@" (for "AA")
	; because AA results in AA and @@ (@@ is junkyard)

	; init rule table
	mov eax, 041414040h ; AA@@
	mov esi, rules
@@init_next_rule:
	mov dword [esi], eax
	add eax, 000010000h
	add esi, 4
	cmp esi, @@rules_end
	jl @@init_next_rule

	; read input rules
	mov ecx, (@@input_rules_end-input_rules)/4
@@read_next_input_rule:
	mov edx, dword [input_rules+ecx*4-4] ; -4 because ecx is max-1
	; "CN", 0, "A" -> edx=41004E43
	mov eax, edx
	shr eax, 16 ; ah is now the insertion part of the rule ("A")
	mov bx, dx ; "CN"
	mov bh, ah ; bx is now "CA"
	shr eax, 8 ; al is now the insertion part of the rule ("A")
	mov ah, dh ; ax is now "AN"
	shl eax, 16 ; eax is now "AN00"
	mov ax, bx ; eax is now "ANCA" (or "CAAN"? I'm really getting lost)
	           ; doesn't matter anyways
	and edx, 0FFFFh ; edx="4E43"
	sub edx, 04141h
	mov dword [rules+edx*4], eax ; from @@CN to CCCN
	loop @@read_next_input_rule

	; zero out values
	mov edi, junkyard
	mov ecx, (@@stuff_end-junkyard)/4
	xor eax, eax
	rep stosd

	; read input
	; reading unaligned words :/
	; -1 because f.e. input "ABA" has length 3 but only 2 sequences AB,BA
	mov ecx, @@input_template_end-input_template-1
	xor eax, eax
@@read_next_input_template_part:
	mov ax, word [input_template+ecx-1] ; -1 because ecx is +1
	sub ax, 04141h
	inc dword [values+eax*4]
	loop @@read_next_input_template_part

	; do the steps
	mov esi, values
	mov edi, values2
	mov ecx, 10 ; num steps
@@nextstep:
	mov ebx, ecx
	; clear destination (edi)
	mov edx, edi
	mov ecx, 05A5Ah-04141h
	xor eax, eax
	rep stosd
	mov edi, edx

	mov ecx, 05A5Ah-04141h
@@nextvalue:
	mov eax, dword [esi+ecx*4-4] ; value
	test eax, eax
	jz @@zero
	movzx edx, word [rules+ecx*4-4] ; rulept1
	sub dx, 04141h
	add dword [edi+edx*4], eax ; valuept1
	movzx edx, word [rules+ecx*4-4+2] ; rulept2
	sub dx, 04141h
	add dword [edi+edx*4], eax ; valuept2
@@zero:
	loop @@nextvalue
	xchg esi, edi
	mov ecx, ebx
	loop @@nextstep

	; count result (values we want are now in esi)
	; since the keys of the values are pairs, use the latter letter
	mov ecx, 05A5Ah-04141h
	xor eax, eax
@@countnext:
	mov al, ch ; the letter
	add al, 041h
	mov edx, dword [esi+ecx*4-4] ; -4 because ecx is +1
	add dword [result+eax*4], edx
	loop @@countnext
	; and add the first letter from the template, since it's not in there
	mov al, byte [input_template]
	inc dword [result+eax*4]

	; now get the min/max values
	mov edi, 0 ; max
	mov ebx, 0FFFFFFFFh ; min
	mov ecx, 05Ah
@@minmaxnext:
	mov eax, dword [result+ecx*4-4]
	test eax, eax
	jz @@skipzero
	cmp eax, ebx
	jae @@notmin
	mov ebx, eax
@@notmin:
	cmp eax, edi
	jbe @@notmax
	mov edi, eax
@@notmax:
@@skipzero:
	loop @@minmaxnext

	mov eax, edi
	sub eax, ebx
	xor edx, edx ; 64bit return value

	pop edi
	pop ebx
	pop esi
	retn

section .bss
	rules resd 05A5Ah-04141h
@@rules_end:
	; two values tables, because we switch every iteration
	junkyard resd 04141h-04040h ; @@ values will end up here
	values resd 05A5Ah-04141h
	junkyard2 resd 04141h-04040h ; @@ values will end up here
	values2 resd 05A5Ah-04141h
	result resd 05Ah
@@stuff_end:

%include "day14input.asm"
