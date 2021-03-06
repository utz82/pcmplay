; PCMplay 1.0
; 4 channel pcm sound player for CoCo/Dragon computers
; by utz 09'2015 * http://irrlichtproject.de 
; suggestions and improvements by Simon Jonassen and sixxie
;
; Copyright (c) 2015, utz / irrlicht project
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;     * Redistributions of source code must retain the above copyright
;       notice, this list of conditions and the following disclaimer.
;     * Redistributions in binary form must reproduce the above copyright
;       notice, this list of conditions and the following disclaimer in the
;       documentation and/or other materials provided with the distribution.
;     * Neither the name of the IRRLICHT PROJECT nor the
;       names of its contributors may be used to endorse or promote products
;       derived from this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL UTZ/IRRLICHT PROJECT BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

	org $f00


init
	pshs cc,d,dp,x,y,u	;preserve regs

	orcc #$50		;set I,F flags = di

 	lda #$7f		;setup keyboard matrix
 	sta $ff02

	; only DAC bits are outputs
	clr $ff21
	ldd #$fc34
	sta $ff20
	stb $ff21

	lda $ff23		;switch on DAC
	ora #$8	
	sta $ff23

	lda #$0f
	tfr a,dp
	
	setdp $0f

	sts srestore		;preserve stack pointer

	ldu #musicdata
	stu seqpntr		;force 8-bit offset - is it necessary? 5-bit offset would save space?
	bra rdseq
	
exit

srestore equ *+2
	lds #$0000		;restore stack pointer

	puls cc,d,dp,x,y,u	;restore regs and enable interrupts		
	rts
;*******************************************************************
rdseq0
	ldu #sloop		;reset sequence pointer to loop pos
	stu seqpntr

rdseq				;read sequence data
seqpntr equ *+1
	ldu #$0
	lds ,u++		;load actual pattern pointer
	;beq exit		;uncomment to disable looping
	beq rdseq0		;check for end of sequence

	stu seqpntr
	
;*******************************************************************
rdpat				;read pattern data
		
    	lda $ff00		;read keyboard
;    	bita #8			;check if space has been pressed
;    	beq exit
	ora #$80
	inca
	bne exit
	
	lda ,s+			;speed
	bmi rdseq
	sta speed

	ldy #freqtab	
	puls d			;freq1,2
	asla
	ldu a,y
	stu fch1
	aslb
	ldu b,y
	stu fch2
	
	puls d			;freq3,4
	asla
	ldu a,y
	stu fch3
	aslb
	ldu b,y
	stu fch4	
	
	puls d
	sta smpp1-1		;smp1
	stb smpp2-1		;smp2
	
	puls d
	sta smpp3-1		;smp3
	stb smp4		;smp4
	
speed equ *+2
	ldy #$0
		
	ldd #$0
	std cch1		;reset add counters
	std cch2
	std cch3
	std cch4
	sta smpp1		;reset sample pointers
	sta smpp2
	sta smpp3
	lda #$80
	sta smpp4

smp4 equ *+1
	ldx #$ff80

	ldu #$ff20		;set up pointer to DAC

;*******************************************************************
play
cch1 equ *+1
	ldd #$0		;3	;load counter ch1
fch1 equ *+1
	addd #$0	;4	;add base frequency ch1
	std cch1	;5	;and store back counter
	
	bcc wait1	;3
	inc smpp1	;6	;if carry, move pointer

skip1	
cch2 equ *+1
	ldd #$0		;3	;load counter ch2
fch2 equ *+1
	addd #$0	;4	;add base freq ch2
	std cch2	;5	;and store back
	
	bcc wait2	;3
	inc smpp2	;6	;if carry, move pointer

skip2
cch3 equ *+1
	ldd #$0		;3	;load counter ch3
fch3 equ *+1
	addd #$0	;4	;add base freq ch3
	std cch3	;5	;and store back
	
	bcc wait3	;3
	inc smpp3	;6	;if carry, move pointer
	
skip3
cch4 equ *+1
	ldd #$0		;3	;load counter ch2
fch4 equ *+1
	addd #$0	;4	;add base freq ch2
	std cch4	;5	;and store back

smpp4 equ *+1
	ldb #$80	;2
	adcb #0		;2
	stb smpp4	;4
	ldb b,x		;5	;load and add sample bytes

smpp1 equ *+2
	addb $ff00	;5
smpp2 equ *+2
	addb $ff00	;5
smpp3 equ *+2
	addb $ff00	;5
	stb ,u		;4	;store in DAC

	leay -1,y	;5	;decrement speed counter
	bne play	;3	;loop if not zero
			;115 ~7782Hz

	jmp rdpat

wait1
	brn *		;3
	bra skip1	;3
			;6
wait2
	brn *
	bra skip2
	
wait3
	brn *
	bra skip3

;*******************************************************************
	align $100	
samples
	include "samples.asm"
	
freqtab
	.dw $0			;silence
	include "notetab.inc"
	
musicdata		
	include "music.asm"	

