#!/bin/sh

./xm2pcmplay.pl
#lwasm -b -9 -s -lmain.lst -o test.bin main.asm
lwasm -b -9 -o test.bin main.asm
# if [ "$?" = "0" ]
# then
# 	/usr/bin/xroar -ao-fragments 1 -machine cocous -type "EXEC &HF00" test.bin
# fi