/*
 * snakev1.asm
 *
 *  Created: 2019-02-12 14:29:24
 *   Author: felst140
 */ 


 /*
 * SNAKE.asm
 *
 *  Created: 2019-02-07 11:35:14
 *   Author: felst140
 */
  
 /*
	r17=blue
	r18=green
	r19=red
	r20=anod
 */
	jmp INIT

	.org OVF1addr ; $010
	jmp FDISP ;int_0
	
	.org $2A
	
 INIT:
	;Sätter pekare
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16
	;alla a-portar ut
	ldi r16, $FF
	out DDRA, r16
	

	ldi r16, (1<<TOIE0) | (1<<OCIE1A) 
	out TIMSK,r16
	ldi r16,0
	out TCNT0,r16
	 
	ldi r16, (1<<CS10) |(1<<CS11)| (1<<WGM12)
	out TCCR1B,r16

	ldi r16, HIGH(156250)
	out OCR1AH, r16
	ldi r17, LOW(156250)
	out OCR1AL, r17

	/*ldi r16, HIGH(1500)
	out OCR1AH, r16
	ldi r17, LOW(1500)
	out OCR1AL, r17*/
	clr r17
	sts INCEN,r17
	sts INCEN2,r17
	sei

SPI_INIT:
	ldi r16, (1<<DDB5) | (1<<DDB7) | (1<<DDB4) | (1<<DDB0)
	out DDRB, r16
	ldi r16, (1<<SPE) | (1<<MSTR) | (1<<SPR0) | (1<<SPR1)
	out SPCR, r16
	
;PROGRAMLOOP
PROG:
	jmp PROG
	


FDISP:
	lds r17,INCEN
	brcs GO
	jmp ZERO2
GO:
	lds r17,INCEN2
	cpi r17,0
	breq LOAD
	lsl r17
	brcs ZERO2
	ldi r18,0
	ldi r19,0
	ldi r20,$FE
	call LIGHTDISP
	jmp DONE
ZERO2:
	ldi r17,0
	ldi r18,0
	ldi r19,0
	ldi r20,$FF
	call LIGHTDISP
	jmp DONE
LOAD:
	ldi r17,1
	sts INCEN2,r17
	call LIGHTDISP
DONE:

TDISP:
	lds r17,INCEN
	cpi r17,0
	breq ZERO
	lsl r17
	ldi r18,0
	ldi r19,0
	ldi r20,$FE
	call LIGHTDISP
	brcs FORT
	sts INCEN,r17
	jmp FORT
ZERO:
	ldi r17,$1
	sts INCEN,r17
	call LIGHTDISP
	jmp SDISP
FORT:
	
	

SDISP:
	ldi r17,0
	ldi r18,1
	ldi r19,0 
	ldi	r20,$EF
	call LIGHTDISP
	sts INCEN2,r17
	jmp FORTS
ONE:
	ldi r17,1
	sts INCEN2,r17
	call LIGHTDISP
FORTS:

FIDISP:
	ldi r17,0
	ldi r18,5
	ldi r19,0
	ldi r20,$0
	call LIGHTDISP
	call LATCH
	reti

LIGHTDISP:
	call BLUE
	call GREEN
	call RED
	call ANOD
	ret

ANOD:
	mov r16,r20
	call SPI_SEND
	ret

LATCH:
	sbi portb, 0
	nop
	cbi portb, 0
	ret
RED:
	mov r16,r19
	call SPI_SEND
	ret

GREEN:
	mov r16,r18
	call SPI_SEND
	ret

BLUE:
	mov r16,r17
	call SPI_SEND
	ret


SPI_SEND:
	out SPDR, r16
WAIT:
 	sbis SPSR, SPIF
	rjmp WAIT
	ret

END:
	jmp PROG

	


CLEAR_OLD:
	clr r17
	clr r18
	clr r19
	ldi r20,255
	call LIGHTDISP
	ret

LOOP:
	
	 ldi  r18, 4
    ldi  r19, 229
L1: dec  r19
    brne L1
    dec  r18
    brne L1
	ret

.dseg
INCEN:
	.byte 1
INCEN2:
	.byte 1