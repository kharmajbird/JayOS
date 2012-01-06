@ECHO OFF

\win\qemu.exe -L win -m 128 -cdrom jlfs-x86.iso -append qemu -boot d -user-net -localtime -redir tcp:5555::22

