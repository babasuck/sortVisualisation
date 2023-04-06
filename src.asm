; GUI
include win64.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include msvcrt.inc
includelib msvcrt.lib
include gdi32.inc
includelib gdi32.lib
includelib alglib.lib 

extern __imp_rand_arr:qword
extern __imp_output_arr:qword
extern __imp_selectionSort:qword
extern __imp_insertionSort:qword
extern __imp_setHwnd:qword
extern __imp_bubbleSort:qword
;-----------MENU-----------
IDR_MAINMENU = 30
M_RESET = 0
M_SORT = 1
M_EXIT = 2
M_ABOUT = 3

stacksz = 8 * 13
arrsize = 200
w = 1015
h = 600
start_x = 0
start_y = 5
between = 5
rect_w = 5

.code

WinMain proc
sub rsp, stacksz
;------------------------------------
;Allocate WNDCLASSA
;------------------------------------
mov rcx, sizeof WNDCLASSA
call malloc
mov rbx, rax
mov rcx, rax
mov rdx, 0
mov r8, sizeof WNDCLASSA
call memset
;------------------------------------
;Fill WNDCLASSA struct
;------------------------------------
mov rax, offset Wndproc
mov qword ptr [rbx + WNDCLASSA.lpfnWndProc], rax
xor rcx, rcx
call GetModuleHandleA
mov qword ptr [rbx + WNDCLASSA.hInstance], rax
mov rcx, 0
mov rdx, IDC_ARROW
call LoadCursorA
mov qword ptr [rbx + WNDCLASSA.hCursor], rax
mov rcx, 001E1E1Eh
call CreateSolidBrush
mov qword ptr [rbx + WNDCLASSA.hbrBackground], rax
mov rax, offset winstr
mov qword ptr [rbx + WNDCLASSA.lpszClassName], rax
mov qword ptr [rbx + WNDCLASSA.lpszMenuName], IDR_MAINMENU
mov rcx, rbx
call RegisterClassA
;------------------------------------
;Create Window
;------------------------------------
xor rcx, rcx
call GetModuleHandleA
xor rcx, rcx			;dwExStyle
mov rdx, offset winstr	;lpClassName
mov r8, rdx				;lpWindowName
mov r9,  WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_VISIBLE ;dwStyle
mov qword ptr [rsp + 20h], 0		;x
mov qword ptr [rsp + 28h], 0		;y
mov qword ptr [rsp + 30h], w		;w
mov qword ptr [rsp + 38h], h		;h
mov qword ptr [rsp + 40h], 0		;hWndParent
mov qword ptr [rsp + 48h], 0		;hMenu
mov qword ptr [rsp + 50h], rax		;hInstance
mov qword ptr [rsp + 58h], 0		;lpParam
call CreateWindowExA
mov rbx, rax 						;hWnd
mov rcx, rax
call __imp_setHwnd
;------------------------------------
;Allocate MSG
;------------------------------------
mov rcx, sizeof MSG
call malloc
mov rsi, rax  						; MSG
mov rcx, rax
mov rdx, 0
mov r8, sizeof MSG
call memset
;------------------------------------
; Messages dispatcher
;------------------------------------
@@:
	mov rcx, rsi
	mov rdx, rbx
	xor r8, r8
	xor r9, r9
	call GetMessageA
	mov rcx, rsi 
	call DispatchMessageA
	jmp @b
call ExitProcess
ret
WinMain endp


Wndproc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
local hdc:qword
sub rsp, stacksz
mov qword ptr [rbp + 16], rcx
cmp edx, WM_DESTROY
		je wmDESTROY
cmp edx, WM_CREATE
		je wmCREATE
cmp edx, WM_PAINT
		je wmPAINT
cmp edx, WM_LBUTTONDOWN
		je wmLBUTTONDOWN
cmp edx, WM_RBUTTONDOWN
		je wmRBUTTONDOWN
cmp edx, WM_COMMAND
		je wmCOMMAND
	call DefWindowProcA
	jmp wmBYE
wmDESTROY: 
		xor rcx, rcx
		call ExitProcess
;------------------------------------
wmCREATE:
		;------------------------------------
		; PAINTSTRUCT alloc
		;------------------------------------
		mov rcx, sizeof PAINTSTRUCT
		call malloc
		mov ps, rax
		mov rcx, rax
		xor rdx, rdx
		mov r8, sizeof PAINTSTRUCT
		call memset
		;------------------------------------
		; client RECT alloc
		;------------------------------------
		mov rcx, sizeof RECT
		call malloc
		mov clientRect, rax
		mov rcx, rax
		xor rdx, rdx
		mov r8, sizeof RECT
		call memset
		mov rcx, qword ptr [rbp + 16]
		mov rdx, clientRect
		call GetClientRect
		;--------------------------------
		; Init array and fill it randomly
		;------------------------------------
		mov rcx, arrsize
		mov rdx, 4
		call calloc
		mov p_arr, rax
		mov rcx, rax
		mov rdx, arrsize
		call __imp_rand_arr
		;------------------------------
		; Init Text
		;------------------------------
		mov rcx, offset font_str
		call AddFontResourceA
		mov rcx, sizeof LOGFONT
		call malloc
		mov roadradio_p, rax
		mov rcx, rax
		xor rdx, rdx
		mov r8, sizeof LOGFONT
		call memset
		mov rbx, roadradio_p
		mov dword ptr [rbx + LOGFONT.lfHeight], 20
		mov dword ptr [rbx + LOGFONT.lfWeight], FW_NORMAL
		add rbx, LOGFONT.lfFaceName
		mov rcx, rbx
		mov rdx, LF_FACESIZE
		mov r8, offset font_str
		call strcpy_s
		mov rcx, roadradio_p
		call CreateFontIndirectA
		mov hFont, rax
		mov rcx, offset _buffer
		mov rdx, offset current_alg
		mov r8, offset ins_str
		call wsprintfA
		mov str_len, eax
		jmp wmBYE
;------------------------------------
wmPAINT:
	    mov rcx, qword ptr [rbp + 16]
		mov rdx, ps
		call BeginPaint
		mov hdc, rax
		;------------------------------------
		mov rcx, hdc
		mov rdx, 001E1E1Eh
		call SetBkColor
		mov rcx, hdc
		mov rdx, 00ffffffh
		call SetTextColor
		mov rcx, hdc
		mov rdx, hFont
		call SelectObject
		mov rcx, hdc
		mov rdx, 0
		mov r8, 0
		mov r9, offset _buffer
		mov eax, str_len
		mov [rsp + 20h], rax
		call TextOutA
		mov rbx, p_arr
		xor rax, rax
		xor rsi, rsi
			@@:
				cmp rsi, arrsize
				je @f
				;------------------------------------
				; Select Pen
				;------------------------------------
				lea eax, color
				mov edi, dword ptr [rbx + rsi * 4]
				mov ecx, dword ptr [eax + edi * 4]
				call CreateSolidBrush
				mov rcx, hdc
				mov rdx, rax
				call SelectObject
				mov rcx, rax
				call DeleteObject
				;------------------------------------
				mov rcx, hdc
				mov rax, clientRect
				mov eax, dword ptr [rax + RECT.bottom]
				mov [rsp + 20h], rax
				sub eax, dword ptr [rbx + rsi * 4]
				mov r8, rax
				mov rax, 5
				mov r10, rsi 
				inc r10
				mul r10
				mov r9, rax
				mov rax, 5
				mul rsi
				mov rdx, rax
				call Rectangle
				inc rsi
				jmp @b
			@@:
		;------------------------------------
		mov rcx, qword ptr [rbp + 16]
		mov rdx, ps
		call EndPaint
	jmp wmBYE
wmLBUTTONDOWN:
	mov al, bSorting
	test al, al
	jnz wmBYE
	xor rcx, rcx
	xor rdx, rdx
	mov r8, offset SortThread
	mov r9, 0
	mov qword ptr [rsp + 20h], 0
	mov qword ptr [rsp + 28h], 0
	call CreateThread
	jmp wmBYE
wmRBUTTONDOWN:
	mov al, bSorting
	test al, al
	jnz wmBYE
	mov rcx, p_arr
	mov rdx, arrsize
	call __imp_rand_arr
	mov rcx, qword ptr [rbp + 16]
	mov rdx, 0
	mov r8, TRUE
	call InvalidateRect
	jmp wmBYE
wmCOMMAND:
	cmp r8d, M_EXIT
		je wmEXIT
	cmp r8d, M_SORT
		je wmLBUTTONDOWN
	cmp r8d, M_RESET
		je wmRBUTTONDOWN
	cmp r8d, M_ABOUT
		je wmABOUT
	jmp wmBYE
wmABOUT:
	mov rcx, 0
	mov rdx, offset infostr
	mov r8, offset winstr
	mov r9, MB_OK
	call MessageBoxA
	jmp wmBYE
wmBYE:
		ret
wmEXIT:
	mov rcx, 1
	call ExitProcess
ret
Wndproc endp

;------------------------------------
; Sorting Thread routine
;------------------------------------
SortThread proc
local demmy:qword
sub rsp, stacksz
mov bSorting, 1
mov rcx, p_arr
mov rdx, arrsize
call __imp_insertionSort
mov bSorting, 0
ret
SortThread endp
;------------------------------------
.data
color dd 80FFh,82FDh,84FBh,86F9h,88F7h,8AF5h,8CF3h,8EF1h,90EFh,92EDh,94EBh,96E9h
dd 98E7h,9AE5h,9CE3h,9EE1h,0A0DFh,0A2DDh,0A4DBh,0A6D9h,0A8D7h,0AAD5h,0ACD3h
dd 0AED1h,0B0CFh,0B2CDh,0B4CBh,0B6C9h,0B8C7h,0BAC5h,0BCC3h,0BEC1h,0C0BFh,0C2BDh
dd 0C4BBh,0C6B9h,0C8B7h,0CAB5h,0CCB3h,0CEB1h,0D0AFh,0D2ADh,0D4ABh,0D6A9h,0D8A7h
dd 0DAA5h,0DCA3h,0DEA1h,0E09Fh,0E29Dh,0E49Bh,0E699h,0E897h,0EA95h,0EC93h,0EE91h
dd 0F08Fh,0F28Dh,0F48Bh,0F689h,0F887h,0FA85h,0FC83h,0FE81h,0FF7Fh,2FF7Dh,4FF7Bh
dd 6FF79h,8FF77h,0AFF75h,0CFF73h,0EFF71h,10FF6Fh,12FF6Dh,14FF6Bh,16FF69h,18FF67h
dd 1AFF65h,1CFF63h,1EFF61h,20FF5Fh,22FF5Dh,24FF5Bh,26FF59h,28FF57h,2AFF55h
dd 2CFF53h,2EFF51h,30FF4Fh,32FF4Dh,34FF4Bh,36FF49h,38FF47h,3AFF45h,3CFF43h
dd 3EFF41h,40FF3Fh,42FD3Dh,44FB3Bh,46F939h,48F737h,4AF535h,4CF333h,4EF131h
dd 50EF2Fh,52ED2Dh,54EB2Bh,56E929h,58E727h,5AE525h,5CE323h,5EE121h,60DF1Fh
dd 62DD1Dh,64DB1Bh,66D919h,68D717h,6AD515h,6CD313h,6ED111h,70CF0Fh,72CD0Dh
dd 74CB0Bh,76C909h,78C707h,7AC505h,7CC303h,7EC101h,80C000h,81BF00h,82BE00h
dd 83BD00h,84BC00h,85BB00h,86BA00h,87B900h,88B800h,89B700h,8AB600h,8BB500h
dd 8CB400h,8DB300h,8EB200h,8FB100h,90B000h,91AF00h,92AE00h,93AD00h,94AC00h
dd 95AB00h,96AA00h,97A900h,98A800h,99A700h,9AA600h,9BA500h,9CA400h,9DA300h
dd 9EA200h,9FA100h,9FA000h,0A09F00h,0A19E00h,0A29D00h,0A39C00h,0A49B00h
dd 0A59A00h,0A69900h,0A79800h,0A89700h,0A99600h,0AA9500h,0AB9400h,0AC9300h
dd 0AD9200h,0AE9100h,0AF9000h,0B08F00h,0B18E00h,0B28D00h,0B38C00h,0B48B00h
dd 0B58A00h,0B68900h,0B78800h,0B88700h,0B98600h,0BA8500h,0BB8400h,0BC8300h
dd 0BD8200h,0BE8100h,0BE8000h,0BF7F00h,0C07E00h,0C17D00h,0C27C00h,0C37B00h
dd 0C47A00h,0C57900h,0C67800h,0C77700h,0C87600h,0C97500h,0CA7400h,0CB7300h
dd 0CC7200h,0CD7100h,0CE7000h,0CF6F00h,0D06E00h,0D16D00h,0D26C00h,0D36B00h
dd 0D46A00h,0D56900h,0D66800h,0D76700h,0D86600h,0D96500h,0DA6400h,0DB6300h
dd 0DC6200h,0DD6100h,0DD6000h,0DD5F01h,0DD5E02h,0DD5D03h,0DD5C04h,0DD5B05h
dd 0DD5A06h,0DD5907h,0DD5808h,0DD5709h,0DD560Ah,0DD550Bh,0DD540Ch,0DD530Dh
dd 0DD520Eh,0DD510Fh,0DD5010h,0DD4F11h,0DD4E12h,0DD4D13h,0DD4C14h,0DD4B15h
dd 0DD4A16h,0DD4917h,0DD4818h,0DD4719h,0DD461Ah,0DD451Bh,0DD441Ch,0DD431Dh
dd 0DD421Eh,0DD411Fh,0DD4020h,0DC3F21h,0DB3E22h,0DA3D23h,0D93C24h,0D83B25h
dd 0D73A26h,0D63927h,0D53828h,0D43729h,0D3362Ah,0D2352Bh,0D1342Ch,0D0332Dh
dd 0CF322Eh,0CE312Fh,0CD3030h,0CC2F31h,0CB2E32h,0CA2D33h,0C92C34h,0C82B35h
dd 0C72A36h,0C62937h,0C52838h,0C42739h,0C3263Ah,0C2253Bh,0C1243Ch,0C0233Dh
dd 0BF223Eh,0BE213Fh,0BE2040h,0BD1F41h,0BC1E42h,0BB1D43h,0BA1C44h,0B91B45h
dd 0B81A46h,0B71947h,0B61848h,0B51749h,0B4164Ah,0B3154Bh,0B2144Ch,0B1134Dh
dd 0B0124Eh,0AF114Fh,0AE1050h,0AD0F51h,0AC0E52h,0AB0D53h,0AA0C54h,0A90B55h
dd 0A90056h,0A80057h,0A70058h,0A60059h,0A5005Ah,0A4005Bh,0A3005Ch,0A2005Dh
dd 0A1005Eh,0A0005Fh,9F0060h,9E0061h,9D0062h,9C0063h,9B0064h,9A0065h,990066h
dd 980067h,970068h,960069h,95006Ah,94006Bh,93006Ch,92006Dh,91006Eh,90006Fh
dd 8F0070h,8E0071h,8D0072h,8C0073h,8B0074h,8A0075h,8A0072h,890072h,880072h
dd 870072h,860072h,850072h,840072h,830072h,820072h,810072h,800072h,7F0072h
dd 7E0072h,7D0072h,7C0072h,7B0072h,7A0072h,790072h,780072h,770072h,760072h
dd 750072h,740072h,730072h,720072h,710072h,700072h,6F0072h,6E0072h,6D0072h
dd 6C0072h,6B0072h,6B0072h,6A0073h,690074h,680075h,670076h,660077h,650078h
dd 640079h,63007Ah,62007Bh,61007Ch,60007Dh,5F007Eh,5E007Fh,5D0080h,5C0081h
dd 5B0082h,5A0083h,590084h,580085h,570086h,560087h,550088h,540089h,53008Ah
dd 52008Bh,51008Ch,50008Dh,4F008Eh,4E008Fh,4D0090h,4C0091h,4C0092h,4B0093h
dd 4A0094h,490095h,480096h,470097h,460098h,450099h,44009Ah,43009Bh,42009Ch
dd 41009Dh,40009Eh,3F009Fh,3E00A0h,3D00A1h,3C00A2h,3B00A3h,3A00A4h,3900A5h
dd 3800A6h,3700A7h,3600A8h,3500A9h,3400AAh,3300ABh,3200ACh,3100ADh,3000AEh
dd 2F00AFh,2E00B0h,2D00B1h,2D00B2h,2C00B3h,2B00B4h,2A00B5h,2900B6h,2800B7h
dd 2700B8h,2600B9h,2500BAh,2400BBh,2300BCh,2200BDh,2100BEh,2000BFh,1F00C0h
dd 1E00C1h,1D00C2h,1C00C3h,1B00C4h,1A00C5h,1900C6h,1800C7h,1700C8h,1600C9h
dd 1500CAh,1400CBh,1300CCh,1200CDh,1100CEh,1000CFh,0F00D0h,0E00D1h,3800CFh
dd 3700D0h,3600D1h,3500D2h,3400D3h,3300D4h,3200D5h,3100D6h,3000D7h,2F00D8h
dd 2E00D9h,2D00DAh,2C00DBh,2B00DCh,2A00DDh,2900DEh,2800DFh,2700E0h,2600E1h
dd 2500E2h,2400E3h,2300E4h,2200E5h,2100E6h,2000E7h,1F00E8h,1E00E9h,1D00EAh
dd 1C00EBh,1B00ECh,1A00EDh,1900EEh,1800EFh,1700F0h,1600F1h,1500F2h,1400F3h
dd 1300F4h,1200F5h,1100F6h,1000F7h,0F00F8h,0E00F9h,0D00FAh,0C00FBh,0B00FCh
winstr db "Sort Visualisation", 0
infostr db "Written on MASM based on alglib.dll", 13, 10, "Copyright. By Mantissa", 13, 10, "Specialy for wasm.in 04.04.2023.", 0
current_alg db "Current sort algorithm: %s", 13, 0
ins_str db "Insertion", 0
font_str db "./roadradio_bold.otf", 0
hFont dq ?
str_len dd ?
p_arr dq ?
ps dq ?
clientRect dq ?
roadradio_p dq ?
_buffer db 128 dup(?)
bSorting db ?
end

