format PE GUI
entry start

include 'win32a.inc'

section '.text' code readable executable

  start:
        ; get handle to calling process
        push    0
        call    [GetModuleHandleA]

        mov [_modHWD],eax
        mov edi,eax
        xor eax,eax

        ; make page writeable
        push    _oldProt
        push    4                       ; option PAGE_READWRITE
        push    1                       ; size
        push    [_modHWD]         ; address of starting page
        call    [VirtualProtect]

        ; erase header
        xor     ecx, ecx
        mov     ch, 0x10        ; set counter to 0x1000
        xor     eax, eax        ; fill with 0 bytes     
        rep stosb               ; will erase 0x1000 bytes
                                    ; starting at edi = handle

        ; restore page permissions
        push    _junk         ; old protect
        push    [_oldProt]      ; option PAGE_READWRITE
        push    1                       ; size
        push    [_modHWD]         ; address of starting page
        call    [VirtualProtect]

        ; show our message
        push    0                   ; type MB_OK
        push    _caption        ; dialog title 
        push    _message        ; message
        push    0                   ; no owner window
        call    [MessageBoxA]

        push    0                   ; success
        call    [ExitProcess]

section '.data' data readable writeable

  _caption db 'MalwareAnalysisForHedgehogs',0
  _message db 'Try dumping',0
  _oldProt dd 0
  _junk dd 0
  _modHWD dd 0
section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
          user,'USER32.DLL'

  import kernel,\
         GetModuleHandleA, 'GetModuleHandleA',\
         ExitProcess,'ExitProcess',\
         VirtualProtect,'VirtualProtect'

  import user,\
         MessageBoxA, 'MessageBoxA'

section '.reloc' fixups data readable discardable