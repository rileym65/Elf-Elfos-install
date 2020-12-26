; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

include    bios.inc
include    kernel.inc

           org     8000h
           lbr     0ff00h
;           db      'rinstall',0
           db      'install',0
           dw      9000h
           dw      endrom+7000h
           dw      2000h
           dw      endrom-2000h
           dw      2000h
           db      0

table:     equ     8000h
;table:     equ     3000h

           org     2000h
           br      start

include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0

start:     ldi     high msg
           phi     rf
           ldi     low msg
           plo     rf
           sep     scall
           dw      o_msg

           ldi     high fildes         ; need to setup file descriptor
           phi     rf
           ldi     low fildes
           plo     rf
           inc     rf                  ; point to dta entry
           inc     rf
           inc     rf
           inc     rf
           ldi     high dta            ; setup dta
           str     rf
           inc     rf
           ldi     low dta
           str     rf

           ldi     high table          ; point to utils table
           phi     ra
           ldi     low table
           plo     ra
           ldn     ra                  ; get byte from table
           smi     0c0h                ; see if jump instruction
           lbnz    mainlp              ; jump if not
           inc     ra                  ; move past jump
           inc     ra
           inc     ra
mainlp:    ldn     ra                  ; get byte from tale
           lbz     maindone            ; jump if done
           sep     scall               ; call for entry
           dw      entry
mainlp2:   lda     ra                  ; get byte from entry
           lbnz     mainlp2            ; loop until zero found
           glo     ra                  ; point to next entry
           adi     10
           plo     ra
           ghi     ra
           adci    0
           phi     ra
           lbr     mainlp              ; and loop back for next entry

entry:     ldi     high instmsg        ; point to message
           phi     rf
           ldi     low instmsg
           plo     rf
           sep     scall               ; and display it
           dw      o_msg
           glo     ra                  ; save entry address
           plo     rf                  ; and put copy in rf
           stxd
           ghi     ra
           phi     rf
           stxd
           sep     scall               ; display filename
           dw      o_msg
           ldi     high inst2msg       ; point to message
           phi     rf
           ldi     low inst2msg
           plo     rf
           sep     scall               ; and display it
           dw      o_msg
           sep     scall               ; get key from user
           dw      o_readkey
           plo     re                  ; save a copy
           smi     'Y'                 ; check against upper case y
           lbz     entryyes            ; jump if yes
           glo     re                  ; retrieve copy
           smi     'y'                 ; check against lower case y
           lbz     entryyes            ; jump if yes
           lbr     entryno             ; jump if anything else

entryyes:  ldi     high instalmsg      ; display skipped message
           phi     rf
           ldi     low instalmsg
           plo     rf
           sep     scall
           dw      o_msg
           ghi     ra                  ; transfer filename
           phi     rf
           glo     ra
           plo     rf
           ldi     high fildes         ; get file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           ldi     1                   ; create if it does not exist
           plo     r7
           sep     scall               ; open/create the file
           dw      o_open
entry1:    lda     ra                  ; move past filename
           lbnz     entry1
           glo     ra                  ; put execution header address in rf
           adi     4
           plo     rf
           ghi     ra
           adci    0
           phi     rf
           ldi     0                   ; 6 bytes in header
           phi     rc
           ldi     6
           plo     rc
           sep     scall               ; write the header
           dw      o_write
           lda     ra                  ; get rom start address
           phi     rf                  ; and place into rf
           stxd                        ; into memory as well
           lda     ra
           plo     rf
           str     r2                  ; into memory as well
           inc     ra                  ; point to low byte of end
           ldn     ra                  ; get it 
           sm                          ; subtract start
           plo     rc                  ; and place into count
           irx                         ; point to high byte
           dec     ra
           ldn     ra
           smb
           phi     rc
           sep     scall               ; write block to file
           dw      o_write
close:     sep     scall               ; close the file
           dw      o_close
           lbr     entrydn

entryno:   ldi     high skipped        ; display skipped message
           phi     rf
           ldi     low skipped
           plo     rf
           sep     scall
           dw      o_msg
entrydn:   irx                         ; recover pointer
           ldxa
           phi     ra
           ldx
           plo     ra
           sep     sret                ; and return to caller

maindone:  lbr     o_wrmboot           ; return to os

msg:       db     'Binary utilities installer'
crlf:      db     10,13,0
instmsg:   db     'Install ',0
inst2msg:  db     ' ? ',0
skipped:   db     ' Skipped',10,13,0
instalmsg: db     ' Installing...',10,13,0

endrom:    equ    $

fildes:    ds     20
dta:       ds     512           

