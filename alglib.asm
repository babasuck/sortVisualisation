; DLL
include win64aMin.inc 

_size = 10

.code

DllEntry proc hInstDLL:HINSTANCE, reason:DWORD, reserved1:DWORD
	   mov  rax, 1
	   ret
DllEntry Endp

; SORTS
;------------------------------------

bubbleSort proc <5, 8, 4> arr:qword, len:dword
local demmy:qword
xor rdi, rdi
xor rsi, rsi
dec edi
i_loop:          ; rdi - i, rsi - j
	inc edi 
	cmp edi, len
	jnl @f
	mov esi, edi
		j_loop:
			inc  esi ; j++
			cmp esi, len
			jnl i_loop
			mov eax, dword ptr [rcx + rdi * 4] ; arr[i]
			mov ebx, dword ptr [rcx + rsi * 4] ; arr[j
			cmp eax, ebx ; arr[i] > arr[j] ?
			jng j_loop
			xchg eax, ebx
			mov dword ptr [rcx + rdi * 4], eax
			mov dword ptr [rcx + rsi * 4], ebx
			jmp j_loop
@@:
ret
bubbleSort endp


insertionSort proc <5, 8, 4> arr:qword, len:dword
xor rdi, rdi	; i
xor rsi, rsi	; j
xor r9, r9  	; key
i_loop:
		inc edi
		cmp edi, len
		jnl @f
		mov eax, edi
		dec eax
		mov esi, eax
		mov r9d, dword ptr [rcx + rdi * 4]
		j_loop:
			cmp esi, 0
			jl change
			cmp r9d, dword ptr [rcx + rsi * 4]
			jnl change
			mov eax, esi
			inc eax
			mov ebx, dword ptr [rcx + rsi * 4]
			mov dword ptr [rcx + rax * 4], ebx
			dec esi
			jmp j_loop
		change:
			mov eax, esi
			inc eax
			mov dword ptr [rcx + rax * 4], r9d
			jmp i_loop
@@:
ret
insertionSort endp

selectionSort proc <5, 8, 4> arr:qword, len:dword
local demmy:qword
xor rdi, rdi	; i
xor rsi, rsi	; j
xor r8, r8		; min
xor r9, r9		; min_i
dec edi
i_loop:         
	inc edi 
	cmp edi, len
	jnl @f
	mov esi, edi ; j = i
	mov r8d, dword ptr [rcx + rdi * 4] ; min = arr[i]
	mov r9, rdi				; min_i = r9
		j_loop:
			inc esi ; j++
			cmp esi, len
			jnl change
			cmp dword ptr [rcx + rsi * 4], r8d ; arr[j] < min ?
			jnl j_loop
			mov r8d, dword ptr [rcx + rsi * 4]
			mov r9d, esi
			jmp j_loop
		change:
			mov eax, dword ptr [rcx + rdi * 4]
			mov dword ptr [rcx + r9 * 4], eax
			mov dword ptr [rcx + rdi * 4], r8d
			jmp i_loop
@@:
ret
selectionSort endp

output_arr proc <5, 8, 4> arr:qword, len:dword
local buffer[12]:byte, hOut:qword
invoke AllocConsole
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov hOut, rax
xor rsi, rsi
mov rdi, arr
@@:
	cmp esi, len
	je @f
	mov eax, dword ptr [rdi + rsi * 4]
	invoke wsprintfA, &buffer, &fstr, eax
	invoke WriteConsoleA, hOut, &buffer, eax, 0, 0
	inc esi
	jmp @b
@@:
invoke WriteConsoleA, hOut, &newln, 3, 0, 0
ret
output_arr endp

rand_arr proc <5, 8, 4> arr:qword, len:dword
local demmy:qword
xor rsi, rsi
invoke Sleep, 5
invoke GetTickCount
invoke srand, eax
@@:
cmp esi, len
je @f
invoke rand
and	eax, 111111111b ; [0, 511] 
mov rbx, arr
mov dword ptr [rbx + rsi * 4], eax
inc esi
jmp @b
@@:
ret
rand_arr endp

.data
fstr db " %d", 0 
newln db 13, 10, 0
end