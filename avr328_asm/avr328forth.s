;/*
 ;* ----------------------------------------------------------------------------
; *  avrforth.c
 ;* Auteur : Nunzio Spitaleri 
; * 
 ;*
 ;* ----------------------------------------------------------------------------
 ;*/
;#define __AVR_ATmega328__
;#include <avr/io.h>
;#include "project.h
.NOLIST
;.DEVICE	atmega328
.INCLUDE "m328def.inc"
.INCLUDE "macro.h"
.LIST
;***********************************************************************;
; data segmùent
;***********************************************************************; 
.DSEG
.LIST
.ORG $100 
	; decompte pour delay
lastword:	.BYTE 2	;last word
dict:		.BYTE 2
free_ram:	.BYTE 2	
DP_save:	.BYTE 2	
stack_save:	.BYTE 2	
newword:	.BYTE 2
newdict:	.BYTE 2
base:		.BYTE 1
etat:		.BYTE 1
type_find:	.BYTE 1
save_z:		.BYTE 2
curs_screen:	.BYTE 1
curs_buf:	.BYTE 1
.EQU	t_inbuf=10
inbuf:		.BYTE	t_inbuf
.EQU	t_wordbuf=41
wordbuf:	.BYTE	t_wordbuf
tabram_end:
;***********************************************************************;
; Interruptions
;***********************************************************************; 
.CSEG
.ORG 0

jmp	Reset
 ;Reset Handler
jmp Ext_int0_vect
 ;IRQ0 Handler
jmp Ext_int1_vect
 ;IRQ1 Handler
jmp Pc_int0_vect
 ;IRQ0 Handler
jmp Pc_int1_vect
 ;IRQ1 Handler
jmp Pc_int2_vect
 ;IRQ2 Handler
jmp Wdt_int_vect
 ;IRQ2 Handler
jmp Tim2_compA_vect
 ;Timer2 Compare Handler
jmp Tim2_compB_vect
 ;Timer2 Compare Handler
jmp Tim2_ovf_vect
 ;Timer2 Overflow Handler
jmp Tim1_capt_vect
 ;Timer1 Capture Handler
jmp Tim1_compA_vect
 ;Timer1 CompareA Handler
jmp Tim1_compB_vect
 ;Timer1 CompareB Handler
jmp Tim1_ovf_vect
 ;Timer1 Overflow Handler
jmp Tim0_compA_vect
 ;Timer0 Compare Handler
jmp Tim0_compB_vect
 ;Timer0 Compare Handler
jmp Tim0_ovf_vect
 ;Timer0 Overflow Handler
jmp Spi_stc_vect
 ;SPI Transfer Complete Handler
jmp Usart_rx_vect
 ;Usart RX Com_vectplete Handler
jmp Usart_udr_vect
 ;UDR Empty Handler
jmp Usart_tx_vect
 ;Usart TX Complete Handler
jmp Adc_complete_vect
 ;Adc Conversion Complete Handler
jmp Ee_rdy_vect
 ;EEPROM Ready Handler
jmp Ana_comp_vect
 ;Analog Comparator Handler
jmp Twi_int_vect
 ;Two-wire Serial Interface Handler
jmp Spm_rdy_vect
 ;Store Program Memory Ready Handler
;***********************************************************************; 
;Interruptions non utilisées
;***********************************************************************;
Ext_int0_vect:
 ;IRQ0
Ext_int1_vect:
 ;IRQ1
Pc_int0_vect:
 ;IRQ0
Pc_int1_vect:
 ;IRQ1
Pc_int2_vect:
 ;IRQ2
Wdt_int_vect:
 ;IRQ2 Handler
Tim2_compA_vect:
 ;Timer2 Comparaison
Tim2_compB_vect:
 ;Timer2 Comparaison
Tim2_ovf_vect:
 ;Timer2 Overflow
Tim1_capt_vect:
 ;Timer1 Capture
Tim1_compA_vect:
 ;Timer1 CompareA
Tim1_compB_vect:
 ;Timer1 CompareB
Tim1_ovf_vect:
	adiw	r25:r24,1
	cbi	TIFR1,TOV1
	reti
 ;Timer1 Overflow
Tim0_compA_vect:
 ;Timer0 Compare
Tim0_compB_vect:
 ;Timer0 Compare
Tim0_ovf_vect:
 ;Timer0 Overflow
Spi_stc_vect:
 ;SPI Transfer Complete Handler
Usart_rx_vect:
 ;Usart RX Complete
     ;   push    r16
;	lds	r16,UCSR0A
  ;      cpi     r16,SOH
  ;      breq  Usart_rx_vect1
  ;      pop r16
  ;      reti	
  ;      push    r17
   ;     clr     r17
Usart_rx_vect1: 
;	cpi	r16,0x52  ;recoit "R"
;	breq	Usart_reset
;;	dec    r17
;	brne   Usart_rx_vect1
;	pop    r17
;	pop    r16
;	reti
Usart_reset: 
;	ldi    r16,high(reset)
   ;     push    r16
;	ldi    r16,low(reset)
  ;      push    r16
   ;     reti
Usart_udr_vect:
 ;UDR Empty
Usart_tx_vect:
 ;Usart TX Complete
Ana_comp_vect: ;Analog Comparator
	in	r12,SREG
	cli
	lds	r16,OCR2A
	lds	r17,ACSR
	sbrc	r17,ACIS0
	rjmp	Ana_comp_vect1
	sbr	r17,ACIS0
	sts	ACSR,r17
	cpi	r16,0xFF
	breq	Ana_comp_vect2
	inc	r13
	rjmp	Ana_comp_vect2
Ana_comp_vect1:
	lds	r17,ACSR
	cbr	r17,ACIS0
	sts	ACSR,r17
	or	r13,r13
	breq	Ana_comp_vect1
	dec	r13
Ana_comp_vect2:
	sts	OCR2A,r13
	sei
	sts	SREG,r12
	reti
	
Adc_complete_vect:
 ;Adc Conversion Complète
Ee_rdy_vect:
 ;EEPROM Ready
Twi_int_vect:
 ;Two-wire Serial Interface Handler 
Spm_rdy_vect:
 ;Store Program Memory Ready
	reti
 ;Fin de l’interruption

.SET link=0
nunzio:		.DB	0x10,"Nunzio Spitaleri "
Sysname:	.DB	0x10,"  Avrforth v0.1  "
error_return:	.DB	0x0A," erreur SP "
Send_compile:		.DB	0x08," compile "
Send_code:		.DB	0x05,"code "
	
Reset:
	Cli
	ldi	r16,HIGH(RAMEND) ; set stack register
	out	SPH,r16
	ldi	r16,LOW(RAMEND)
	out	SPL,r16
	ldi	r16,0xFF
	call	Initport
	call	Init_delay
	;call	Init_twi
	;call	testlcd
	;call	lcd_init
	call	Usart0_init
	;call	Spi_init
	call	Init_pwm2
	call	Init_adc
Reset01:
	call 	InitForth
	;call 	Vlist
	;call	Usart1_init
	;ldi	r16,0x05
	;call	lcd_gotoxy1
	;ldi	ZL, LOW(Sysname)
	;ldi	ZH, HIGH(Sysname)
	;st	X+,ZL
	;st	X+,ZH
	;call 	Sendlcd
	;ldi	r16,0x14
	;call	lcd_gotoxy1
	;ldi	ZL, LOW(nunzio)
	;ldi	ZH, HIGH(nunzio)
	;st	X+,ZL
	;st	X+,ZH
	;call 	Sendlcd
	call	Start2
	;call 	Dtest
	;call 	Led
	;call	debug
	ENV0_R16	ACK
	call 	Vlist
	call	_LF
	ENV0_R16	0x4F
	ENV0_R16	0x4B
	call	Receive0
Reset1:
	rjmp	Reset1	
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Initport: 
	ldi	r16, 0x1C ;DDRB = 0x0A ;pour pwm2A
	out	DDRB , r16
	
	ldi	r16, 0x07 ;DDRB = 0x07
	;out	PORTB , r16
	;ldi	r16, 3 	;DDRC = 0
	out	DDRC , r16
	ldi	r16, 0xC2 ;DDRD = 0xF2
	out	DDRD , r16
	sbi	portd,2 ; pullup
	sbi	portd,3 ; pullup
	sbi	portd,6
	cbi	portd,7
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Init twi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init_twi: 
	ldi	r16, TWBRVAL ;pour scl=200k avec prescaler=1
	sts	TWBR , r16
	ldi	r16,(1<<TWEN)
	sts	TWCR , r16
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;/
InitForth:
	pop	r3
	pop	r2
	ldi	YL,LOW(lastword) ; forth tab
	ldi	YH,HIGH(lastword)
	ldi	r17,0x20
	clr	r16
	out	EEARH,r16
InitForth1:
	sbic EECR,EEPE
	rjmp InitForth1
InitForth2:
	out	EEARL,r16
	sbi	EECR,EERE
	in	r1,EEDR
	st	Y+,r1
	inc	r16
	dec	r17
	brne	InitForth2
	lds	XL,(DP_save)
	lds	XH,(DP_save+1)
	ldi	YL,0
	ldi	YH,0x05
	sbiw	YH:YL,0x38
	ldi	r16,0x20
InitForth3:
	st	X+,r16
	sbiw	YH:YL,0x01
	brne	InitForth3
	lds	XL,(DP_save)
	lds	XH,(DP_save+1)
	ldi	r19,low(error_sp)
	ldi	r20,high(error_sp)
	ldi	r16,HIGH(RAMEND) ; set stack register
	out	SPH,r16
	ldi	r16,LOW(RAMEND)
	out	SPL,r16
	ldi	r16,0x10
InitForth4:
	push	r19
	push	r20
	dec	r16
	brne	InitForth4
	push	r2
	push	r3
	ldi	r16,NORMAL
	sts	etat,r16
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Usart0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Usart0_init:
; Set baud rate
    ldi	r16, LOW(UBRRVAL0)
    sts	UBRR0L,r16
    ldi	r16, HIGH(UBRRVAL0)
    sts	UBRR0H,r16
    ldi	r16, 0
    sts	UCSR0A,r16
; Enable receiver and transmitter and interrupt
    ldi	r16, (1<<RXEN0)+(1<<TXEN0);| (1 << RXCIE0)
    sts	UCSR0B,r16
; Set frame format: 8data, 1 stop bit
   ; ldi	r16,(1 << UCSZ01)+(1 << UCSZ00);+(1 << USBS0);;
ldi r16,0x06 ; (1<<USBS0)|(3<<UCSZ00)
    sts	UCSR0C,r16
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;/
.DB	" recv0",0x5,1<<EXEC
.DW	link
Recv0:
.SET link=recv0
	ld	r25,-X
	ld	r24,-X
	push	r24
	push	r25
Recv0_1:
	REC0_DP
	sbiw	r25:r24,1
	brne	Recv0_1
	pop	r25
	pop	r24
	st	X+,r24
	st	X+,r25
	ret
	
.DB	" send0",0x5,1<<EXEC
.DW	link
Send0:
.SET link=Send0
	ld	r25,-X
	ld	r24,-X
Send0_1:
	ld	r21,-X 
	ENV0
	sbiw	r25:r24,1
	brne	Send0_1
	ret
.DB	" rcom0",0x5,1<<EXEC
.DW	link
rcom0:
.SET link=Rcom0
rcom0_1:
	lds	r22,UCSR0A
	sbrs	r22,RXC0
	rjmp	rcom0_1
	lds	r22,UDR0
	st	X+,r22
	clr	r22
	st	X+,r22
	ret
.DB	"rflag0",0x6,1<<EXEC
.DW	link
rflag0:
.SET link=rflag0
	lds	r22,UCSR0A
	sbrs	r22,RXC0
	rjmp	rflag0_1
	sez
	ret
rflag0_1:
	clz
	ret
	

.DB     "com0",0x4,1<<EXEC
.DW	link
com0:
.SET link=com0
	ld	r16,-X
com0_1:
	lds	r23,UCSR0A
	sbrs	r23,UDRE0
	rjmp	com0_1
	sts	UDR0,r16
	ret
.DB	"S",0x22,0x2,1<<compile
.DW	link
Sguil:
.SET link=Sguil
	ret
	ENV0_R16	ESC
	ENV0_R16	0x22	; S"
	call	Word0
	ldi	r20,low(_Sguil)
	ldi	r21,high(_Sguil)
	COMPILE20
	ldi	YL,LOW(wordbuf)	;tampon wordbuf
	ldi	YH,HIGH(wordbuf)
	ld 	r16,Y+
	mov	r18,r16
Sguil1:
	ld	r17,Y+
	st	X+,r17
	ld	r17,Z+
	dec	r16
	brne	Sguil1
	clr	r17
	st	X+,r17
	ld	r17,Z+
	sbrc	r18,0
	ret
	st	X+,r17
	ld	r17,Z+
	ret
_Sguil:
	pop	ZH
	pop	Zl
	lsl	Zl
	rol	ZH
_Sguil1:
	lpm	r21,Z+
	cpi	r21,0
	breq	_Sguil2
	ENV0
	rjmp	_Sguil1
_Sguil2:
	lsr	ZH
	ror	Zl
	brcc	_Sguil3
	adiw	ZH:ZL,1
_Sguil3: 
	push	ZL
	push	ZH
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; spi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Spi_init:
	ldi	r17,(1<<SS)|((1<<MOSI)|1<<SCK)	;(SS,MOSI,SCK) as output
	in	r16,DDRB
	or	r16,r17
	out	DDRB,r16
	sbi	portb,SS
; Enable SPI, Master, set clock rate fck/16
	ldi	r16,(1<<SPE)|(1<<MSTR)|(1<<SPR0)
	out	SPCR,r16
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Init pwm2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init_pwm2: 
	ldi	r16, 0x0A ;DDRB = 0x0A ;pour pwm2A
	out	DDRB , r16
	ldi	r16, 0x83 ;
	sts	TCCR2A,r16
	ldi	r16, 0x02
	sts	TCCR2B , r16
	ldi	r16, 0x0 ;
	sts	OCR2A , r16
	ret

.DB     "pwm2",0x4,1<<EXEC
.DW	link
pwm2:
.SET link=pwm2
	ld	r16,-X
	ld	r16,-X
	sts	OCR2A , r16
	ret	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Init adc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init_adc: 
	ldi	r16, (1<<REFS1)|(1<<REFS0) ; adc0
	sts	ADMUX,r16
	ldi	r16, (1<<ADEN)
	sts	ADCSRA,r16
	ret

.DB     "adcn",0x4,1<<EXEC
.DW	link
Adcn:
.SET link=adcn
	ld	r17,-X
	ld	r17,-X
	andi	r17,0x0F
	ldi	r16, (1<<REFS1)|(1<<REFS0)
	or	r16,r17
	sts	ADMUX,r16 ; select analog port
	ldi	r16, (1<<ADEN)|(1<<ADSC)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	sts	ADCSRA,r16 ; start convect
	ret	
.DB     "r_adcn",0x6,1<<EXEC
.DW	link
R_adcn:
.SET link=R_adcn
	lds	r16,ADCSRA
	sbrc	r16,ADSC
	rjmp	R_adcn
	lds	r16,ADCL
	st	X+,r16
	lds	r16,ADCH
	st	X+,r16
	ret	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; lcd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DB     "lcd_init",0x8,1<<EXEC
.DW	link
lcd_init:
.SET link=lcd_init
	PAUSE	1500
	ldi	r16,0x3C
	st	X+,r16
	ldi	r16,0x38
	st	X+,r16
	ldi	r16,0x3C
	st	X+,r16
	ldi	r16,0x03
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	410
	ldi	r16,0x3C
	st	X+,r16
	ldi	r16,0x38
	st	X+,r16
	ldi	r16,0x3C
	st	X+,r16
	ldi	r16,0x03
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	10
	ldi	r16,0x3C
	st	X+,r16
	ldi	r16,0x38
	st	X+,r16
	ldi	r16,0x3C
	st	X+,r16
	ldi	r16,0x03
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	10
	ldi	r16,0x2C	;4 bits
	st	X+,r16
	ldi	r16,0x28
	st	X+,r16
	ldi	r16,0x2C
	st	X+,r16
	ldi	r16,0x03
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	1000
	ldi	r16,0x8C	;4 bits
	st	X+,r16
	ldi	r16,0x88
	st	X+,r16
	ldi	r16,0x8C
	st	X+,r16
	ldi	r16,0x2C
	st	X+,r16
	ldi	r16,0x28
	st	X+,r16
	ldi	r16,0x2C
	st	X+,r16
	ldi	r16,0x06
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	100
	ldi	r16,0x8C	;display off
	st	X+,r16
	ldi	r16,0x88
	st	X+,r16
	ldi	r16,0x8C
	st	X+,r16
	ldi	r16,0x0C
	st	X+,r16
	ldi	r16,0x08
	st	X+,r16
	ldi	r16,0x0C
	st	X+,r16
	ldi	r16,0x06
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	100
	ldi	r16,0x6C	;entry set mode
	st	X+,r16
	ldi	r16,0x68
	st	X+,r16
	ldi	r16,0x6C
	st	X+,r16
	ldi	r16,0x0C
	st	X+,r16
	ldi	r16,0x08
	st	X+,r16
	ldi	r16,0x0C
	st	X+,r16
	ldi	r16,0x06
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	10
	ldi	r16,0xCC	;cursor move
	st	X+,r16
	ldi	r16,0xC8
	st	X+,r16
	ldi	r16,0xCC
	st	X+,r16
	ldi	r16,0x1C
	st	X+,r16
	ldi	r16,0x18
	st	X+,r16
	ldi	r16,0x1C
	st	X+,r16
	ldi	r16,0x06
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	10
	ldi	r16,0xFC	;display on
	st	X+,r16
	ldi	r16,0xF8
	st	X+,r16
	ldi	r16,0xFC
	st	X+,r16
	ldi	r16,0x0C
	st	X+,r16
	ldi	r16,0x08
	st	X+,r16
	ldi	r16,0x0C
	st	X+,r16
	ldi	r16,0x06
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	PAUSE	10
	call	Lcd_clr1
	ret
testlcd:
	
	ldi	r16,0x0
testlcd1:
	st	X+,r16
	push	r16
	ldi	r16,0x01
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	call	Testled
	pop	r16
	inc	r16
	jmp	testlcd1
	
.DB	"emit",0x4,1<<EXEC
.DW	link
Emit:
.SET link=Emit	
	ld	r16,-X
	ld	r16,-X
Emit1:
	push r16
	lsl	r16
	lsl	r16
	lsl	r16
	lsl	r16
	ori	r16,0x0D
	st	X+,r16
	push	r16
	andi	r16,0xFB
	st	X+,r16
	pop	r16
	st	X+,r16
	pop	r16
	andi	r16,0xF0
	ori	r16,0x0D
	st	X+,r16
	push	r16
	andi	r16,0xFB
	st	X+,r16
	pop	r16
	st	X+,r16
	ldi	r16,0x06
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	lds	r16,curs_screen
	inc	r16
	sts	curs_screen,r16
	jmp	lcd_gotoxy1
	
.DB	" lcd_com",0x7,1<<EXEC
.DW	link
Lcd_com:
.SET link=Lcd_com	
	ld	r16,-X
Lcd_com1:
	push r16
	lsl	r16
	lsl	r16
	lsl	r16
	lsl	r16
	ori	r16,0x0C
	st	X+,r16
	push	r16
	andi	r16,0xFB
	st	X+,r16
	pop	r16
	st	X+,r16
	pop	r16
	andi	r16,0xF0
	ori	r16,0x0C
	st	X+,r16
	push	r16
	andi	r16,0xFB
	st	X+,r16
	pop	r16
	st	X+,r16
	ldi	r16,0x06
	st	X+,r16
	ldi	r16,SLA_W
	st	X+,r16
	call	FTwi_s
	ret
	
.DB	"lcd_gotoxy",0xA,1<<EXEC
.DW	link
lcd_gotoxy:
.SET link=lcd_gotoxy
	lds	r16,curs_screen
lcd_gotoxy1:
	cpi	r16,(LCD_START_LINE1+LCD_DISP_LENGTH)
	brne	lcd_gotoxy2
	ldi	r16,LCD_START_LINE2
	jmp	lcd_gotoxy6
lcd_gotoxy2:
	cpi	r16,(LCD_START_LINE2+LCD_DISP_LENGTH)
	brne	lcd_gotoxy3
	ldi	r16,LCD_START_LINE3
	jmp	lcd_gotoxy6
lcd_gotoxy3:
	cpi	r16,(LCD_START_LINE3+LCD_DISP_LENGTH)
	brne	lcd_gotoxy4
	ldi	r16,LCD_START_LINE4
	jmp	lcd_gotoxy6
lcd_gotoxy4:
	cpi	r16,(LCD_START_LINE4+LCD_DISP_LENGTH)
	brne	lcd_gotoxy5
	ldi	r16,LCD_START_LINE1
	jmp	lcd_gotoxy6
lcd_gotoxy5:
	ret
lcd_gotoxy6:
	sts	curs_screen,r16
	ori	r16,0x80
	call	Lcd_com1
	ret
	
.DB	" sendlcd",0x7,1<<EXEC
.DW	link
Sendlcd:
.SET link=Sendlcd	
	PUSHZ
	clr	r16
	ld	ZH, -X
	ld	ZL, -X
	lsl	ZL
	rol	ZH
	lpm	r16,z+
Sendlcd1:
	push r16
	lpm	r16,z+
	call	Emit1
	pop r16
	dec	r16
	brne	Sendlcd1
	POPZ
	ret
.DB	" display",0x7,1<<EXEC
.DW	link
Display0:
.SET link=Display0	
	ld	r16,-X
Display1:
	push	r16
	ld	r16,-X
	call	Emit1
	pop	r16
	dec	r16
	brne	Display1
	ret
.DB	"dispcom0",0x8,1<<EXEC
.DW	link
dispcom0:
.SET link=dispcom0
	REC0	
	mov	r16,r22 
dispcom01:
	push	r16
	REC0
	mov	r16,r22
	call	Emit1
	pop	r16
	dec	r16
	brne	dispcom01
	ret
.DB	"lcd_home",0x8,1<<EXEC
.DW	link
Lcd_home1:
.SET link=Lcd_home1
	ldi	r16,(1<<LCD_HOME)
	call	Lcd_com1
	clr	r16
	sts	curs_screen,r16
	PAUSE	152
	ret
	
.DB	" lcd_clr",0x7,1<<EXEC
.DW	link
Lcd_clr1:
.SET link=Lcd_clr1
	ldi	r16,(1<<LCD_CLR)
	call	Lcd_com1
	clr	r16
	sts	curs_screen,r16
	PAUSE	152
	ret
error_sp:
	ldi	ZL, LOW(error_return)
	ldi	ZH, HIGH(error_return)
	st	X+,ZL
	st	X+,ZH
	call 	Sendlcd
	ret
.DB	".",0x22,0x2,1<<compile
.DW	link
pguil:
.SET link=pguil
	ret
	ENV0_R16	ESC
	ENV0_R16	0x22	; ."
	call	Word0
	ldi	r20,low(_pguil)
	ldi	r21,high(_pguil)
	COMPILE20
	ldi	YL,LOW(wordbuf)	;tampon wordbuf
	ldi	YH,HIGH(wordbuf)
	ld 	r16,Y+
	mov	r18,r16
pguil1:
	ld	r17,Y+
	st	X+,r17
	ld	r17,Z+
	dec	r16
	brne	pguil1
	clr	r17
	st	X+,r17
	ld	r17,Z+
	sbrc	r18,0
	ret
	st	X+,r17
	ld	r17,Z+
	ret
_pguil:
	pop	ZH
	pop	Zl
	lsl	Zl
	rol	ZH
_pguil1:
	lpm	r16,Z+
	cpi	r16,0
	breq	_pguil2
	call	Emit1
	rjmp	_pguil1
_pguil2:
	sbrc	ZL,0
	adiw	ZH:ZL,1 
	lsr	ZH
	ror	Zl
	brcc	_pguil3
	adiw	ZH:ZL,1
_pguil3:
	push	ZL
	push	ZH
	ret
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init_delay:
	ldi	r16, (1<<WGM01) ; 0x02 ;mode CTC, compare avec A
	out	TCCR0A , r16
	;ldi	r16, 0x82 ; compare avec A et presacler osc/8
	;sts	TCCR0A , r16
	ldi	r16, 0x13 ; pour 10us
	out	OCR0A , r16
	ldi	r16, 0x0 ; pas d interruption
	sts	TIMSK0 , r16
	ret
.DB	  " delay",0x5,1<<EXEC
.DW	link
Delay:
.SET link=Delay
	ld	YH,-X
	ld	YL,-X
Delay1:
	ldi	r16, 0x02 ;mode CTC, compare avec A
	out	TCCR0A , r16
	ldi	r16, 0x18 ; pour 10us
	out	OCR0A , r16
	clr	r16 ;clear flags
	out	TIFR0 , r16
	out	TCNT0 , r16
	ldi	r16, (1<<CS00)|(1<<CS01); start timer
	out	TCCR0B,r16 
Delay2:
	ldi	r16,0x83
	out	TCCR0B,r16 
	sbi	TIFR0,OCF0A 
Delay3:
	sbis	TIFR0,OCF0A ; test flag
	rjmp	Delay3
	sbiw	YH:YL,1
	brne	Delay2
Delay4:
	ldi	r28, 0x0 ;stop timer0
	out	TCCR0A , r28
	ret
.DB     " led",0x3,1<<EXEC
.DW	link
led:
.SET link=led
Testled:
	sbis	PORTB,3
	rjmp	Testled1
	cbi	PORTB,3
	PAUSE 0xFF00
	rjmp	Testled2
Testled1:
	sbi	PORTB,3
	PAUSE 0xFFF0
Testled2:
	sbis	PORTB,3
	rjmp	Testled3
	cbi	PORTB,3
	PAUSE 0xFF00
	rjmp	Testled4
Testled3:
	sbi	PORTB,3
	PAUSE 0xFFF0
Testled4:
	sbis	PORTB,3
	rjmp	Testled5
	cbi	PORTB,3
	PAUSE 0xFF00
	ret	
Testled5:
	sbi	PORTB,3
	PAUSE 0xFFF0
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; I2C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.DB     " twi_s",0x5,1<<EXEC
.DW	link
FTwi_s:
.SET link=FTwi_s
	ldi	r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	sts	TWCR, r16
FTwi_s1:				;Boucle d'attente de transmition START
	lds	r16,TWCR
	sbrs	r16,TWINT
	rjmp	FTwi_s1
	lds	r16,TWSR	;test bonne reception START
	andi	r16, 0xF8
	cpi	r16, START
	brne	ERROR_Twi_s1
	ld	r16,-X	;Envoi sla+w
	sts	TWDR, r16
	ldi	r16, (1<<TWINT) | (1<<TWEN)
	sts	TWCR, r16
FTwi_s2:			;Boucle d'attente de transmition SLA+W
	lds	r16,TWCR
	sbrs	r16,TWINT
	rjmp	FTwi_s2
	lds	r16,TWSR	;test bonne reception sla+w
	andi	r16, 0xF8
	cpi	r16, S_SLA_ACK
	brne	ERROR_Twi_s1
	ld	r17,-X
FTwi_s3:
	ld	r16,-X
	sts	TWDR, r16	;envoi de donnes
	ldi	r16, (1<<TWINT) | (1<<TWEN)
	sts	TWCR, r16
FTwi_s4:
	lds	r16,TWCR
	sbrs	r16,TWINT
	rjmp	FTwi_s4
	lds	r16,TWSR	;test bonne transmition data
	andi	r16, 0xF8
	cpi	r16, S_DATA_ACK
	brne	ERROR_Twi_s1
	dec	r17
	brne	FTwi_s3
	;sts	TWDR, r17	;envoi de donnes
	ldi	r16, (1<<TWINT) | (1<<TWEN)|(1<<TWSTO) ;stop
	sts	TWCR, r16
	ret
ERROR_Twi_s1:
	;lds	XL,(DP_save) ; forth tab
	;lds	XH,(DP_save+1)
	ret;data
ERROR_Twi_s11:
ERROR_Twi_s2:
	ld	r17,-X		;data
ERROR_Twi_s3:
	ret

.DB     " twi_r",0x5,1<<EXEC
.DW	link
FTwi_r:
.SET link=FTwi_r
	ldi	r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	sts	TWCR, r16
FTwi_r1:				;Boucle d'attente de transmition START
	lds	r16,TWCR
	sbrs	r16,TWINT
	rjmp	FTwi_r1
	lds	r16,TWSR	;test bonne reception START
	andi	r16, 0xF8
	cpi	r16, START
	brne	ERROR_Twi_r1
	ld 	r16,-X	;Envoi sla+w ou sla+r
	sts	TWDR, r16
	ldi	r16, (1<<TWINT) | (1<<TWEN)
	sts	TWCR, r16
FTwi_r2:			;Boucle d'attente de transmition SLA+W
	lds	r16,TWCR
	sbrs	r16,TWINT
	rjmp	FTwi_r2
	lds	r16,TWSR	;test bonne reception sla+wr
	andi	r16, 0xF8
	cpi	r16, R_SLA_ACK
	brne	ERROR_Twi_r2
	ld	r17,-X
FTwi_r3:	;envoi de donnes
	ldi	r16, (1<<TWINT) | (1<<TWEN)
	sts	TWCR, r16
FTwi_r4:
	lds	r16,TWCR
	sbrs	r16,TWINT
	rjmp	FTwi_r4
	lds	r16,TWCR	; reception data
	st	X+,r16
	dec	r17
	brne	FTwi_r3
	pop	r16
	st	X+,r16
	ldi	r16, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO) ;stop
	sts	TWCR, r16
	ret
ERROR_Twi_r1:
ERROR_Twi_r2:
ERROR_Twi_r3:
	lds	XL,(DP_save) 
	lds	XH,(DP_save+1)
	clr	r16
	st	X+,r16
	ret;data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Forth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.DB     " receive",0x7,1<<EXEC
.DW	link
Receive0:
.SET link=Receive0
	;ENV0_R16	XON ; pret a recevoir
Receive01:
	ENV0_R16	ACK
	REC0
	
Receive02:	;Affiche
	cpi	r22,DISPLAY
	brne	Receive03
	call	Dispcom0
	rjmp	Ok
	;REC0_DP		;nbre d'octets
	;call	Recv0
	;call	Display0
	;rjmp	Ok
	
Receive03:	
	cpi	r22,ESC	;
	brne	Receive04
	REC0
	cpi	r22,NACK
	brne   Receive0
	jmp	Reset
	rjmp	Receive0
	rjmp	Ok
Receive04:
	cpi	r22,WRAM	;reception et ecrire RAM 
	brne	Receive05
	;REC0_DP				;adresse RAM
	;REC0_DP			
	REC0_DP		;nbre d'octets
	REC0_DP
	call	Writeram
	rjmp	Ok
Receive05:
	cpi	r22,STX	;reception et ecrire wordbuf,trouve et execute
	brne	In_error
	call	query2
	call	execute1
	rjmp	Ok
In_error:
Ko:
	call	Restitue
	ENV0_R16	LF
	ENV0_R16	0x4B
	ENV0_R16	0x4F
	ENV0_R16	LF
	cli
	Lds     r16,ucsr0b
	cbr     r16,rxcie0
	sts     ucsr0b,r16
        sei
	ret
	
Ok:
	ENV0_R16	LF
	ENV0_R16	0x4F
	ENV0_R16	0x4B
	ENV0_R16	LF
	rjmp	Receive0
	
.DB     "word",0x4,1<<EXEC
.DW	link
Word:
.SET link=Word
	ENV0_R16	ACK
Word0:
	REC0
	cpi	r22,STX	;reception et ecrire wordbuf
	brne	Word0
Word1:
	ldi	YL,LOW(wordbuf)	;tampon wordbuf
	ldi	YH,HIGH(wordbuf)
	REC0
	mov	r16,r22
	st	y+,r16
	or	r16,r22
	brne	Word2
	ret
Word2:
	REC0
	st	Y+,r22
	dec	r16
	brne	Word2
	inc	r16
	ret			

.DB     " vlist",0x5,1<<EXEC
.DW	link
Vlist:
.SET link=Vlist
	PUSHZ
	lds	ZL,lastword
	lds	ZH,lastword+1
Vlist1:	
	lsl	ZL
	rol	ZH
Vlist2:	
	sbiw	ZH:ZL,4
	lpm	r3,Z+	;length of word
	lpm	r5,Z+	;word type
	lpm	r0,Z+	; next word
	lpm	r1,Z+
	ldi	r17,0x20
	st	X+,r17	;put in data stack
	mov	r4,r3
	inc	r4
	sbiw	ZH:ZL,4
Vlist3:
	sbiw	ZH:ZL,1
	lpm	r6,Z	;read word
	st	X+,r6	;put in data stack
	dec	r3
	brne	Vlist3
	movw	ZL,r0	;next word
	mov	r24,r4
	clr	r25
	call	Send0_1
	or	r0,ZH
	brne	Vlist1
	POPZ	
	ret
		; zero si pas trouve
		
.DB     "find",0x4,1<<EXEC
.DW	link
find:
.SET link=find
	PUSHZ
	lds	ZL,lastword
	lds	ZH,lastword+1
	ldi	YL,LOW(wordbuf)
	ldi	YH,HIGH(wordbuf)
find1:	
	push	ZL
	push	ZH
	lsl	ZL
	rol	ZH
find2:	
	sbiw	ZH:ZL,4
	lpm	r3,Z+	;length of word
	lpm	r5,Z+	;word type
	lpm	r0,Z+	; next word
	lpm	r1,Z+
	ld	r6,Y
	cp	r3,r6
	brne	find5
	ld	r6,Y+
	sbiw	ZH:ZL,4
	add	YL,r3
	clr	r6
	adc	YH,r6
find3:
	sbiw	ZH:ZL,1
	lpm	r6,Z	;read word
	ld	r4,-Y
	cp	r6,r4
	brne	find5
	dec	r3
	brne	find3
	pop	ZH
	pop	ZL
	sts	type_find,r5
	st	X+,ZL	; mot trouvé
	st	X+,ZH
	POPZ
	ldi	r16,1
	ret
find5:
	pop	r16
	pop	r16
	ldi	YL,LOW(wordbuf)
	ldi	YH,HIGH(wordbuf)
	movw	r30,r0	;next word
	or	r0,ZH
	brne	find1
find6:
	POPZ
	ldi	r16,low(ko)
	st	X+,r16
	ldi	r16,high(ko)
	st	X+,r16
	ldi	r16,0
	ret

.DB     "number",0x6,1<<NUM
.DW	link
Number1:
.SET link=Number1
	ldi	YL,LOW(wordbuf)
	ldi	YH,HIGH(wordbuf)
	clr	r18
	clr	r19
	clr	r22
	clr	r23
	ld	r10,Y+
Number2:
	ld	r16,Y+
	subi	r16,0x30
	brcs	error1
	cpi	r16,0x0A
	brcs	Number3
	cpi	r16,0x11
	brcs	error1
	subi	r16,0x07
Number3:
	lds	r17,base
	cp	r16,r17		;compare a la base
	brge	error1
	add	r18,r16
	brcc	Number4
	inc	r19
	brne	Number4
	inc	r22
	brne	Number4
	inc	r23
Number4:
	dec	r10
	breq	Number5
	mul	r18,r17
	mov	r2,r0
	mov	r3,r1
	mul	r19,r17
	mov	r4,r0
	mov	r5,r1
	mul	r22,r17
	mov	r6,r0
	mov	r7,r1
	mul	r23,r17
	mov	r8,r0
	mov	r9,r1
	add	r3,r4
	brcc	Number41
	inc	r5
Number41:
	add	r5,r6
	brcc	Number42
	inc	r7
Number42:
	add	r7,r8
	brcc	Number43
	inc	r8
Number43:
	add	r8,r9
	brcc	Number44
	;inc	r8
Number44:
	mov	r18,r2
	mov	r19,r3
	mov	r22,r5
	mov	r23,r7
	
	
	rjmp	Number2
error1:
	ldi	r16,LOW(ko)
	st	X+,r16
	ldi	r16,HIGH(ko)
	st	X+,r16
	ldi	r16,1<<IMMED
	sts	type_find,r16
	ldi	r16,0
	ret
Number5:
	ldi	r16,1<<NUM
	sts	type_find,r16
	lds	r16,etat
	cpi	r16,compile
	breq	Number55
	mov	r2,r22
	or	r2,r23
	breq	Number51
	st	X+,r18
	st	X+,r19
	st	X+,r22
	st	X+,r23
	rjmp	Number52
Number51:
	st	X+,r18
	st	X+,r19
Number52:
	ldi	r16,LOW(Number555)
	st	X+,r16
	ldi	r16,HIGH(Number555)
	st	X+,r16
	ldi	r16,1
	ret
Number55:
Number551:
	mov	r2,r22
	or	r2,r23
	breq	Number552
	ldi	r20,LOW(Number6)
	ldi	r21,HIGH(Number6)
	COMPILE20
	ldi	r16,0x04
	st	X+,r16
	clr	r16
	st	X+,r16
	st	X+,r18
	st	X+,r19
	st	X+,r22
	st	X+,r23
	adiw	ZH:ZL,6
	ldi	r16,1
	ret
Number552:
	ldi	r20,LOW(num2)
	ldi	r21,HIGH(num2)
	COMPILE20
	st	X+,r18
	st	X+,r19
	adiw	ZH:ZL,2
Number555:
	ldi	r16,1
	ret
	
.DB     "num6",0x4,1<<EXEC
.DW	link
Number6:
.SET link=Number6
	pop	ZH
	pop	ZL
	lsl	ZL
	rol	ZH
	lpm	r16,Z+
	lpm	r17,Z+
Number61:
	lpm	r17,Z+
	st	X+,r17
	dec	r16
	brne	Number61
	lsr	ZH
	ror	ZL
	push	ZL
	push	ZH
	ret
	
.DB     "num2",0x4,1<<EXEC
.DW	link
num2:
.SET link=num2
	pop	ZH
	pop	ZL
	lsl	ZL
	rol	ZH
	lpm	r16,Z+
	st	X+,r16
	lpm	r16,Z+
	st	X+,r16
	lsr	ZH
	ror	ZL
	push	ZL
	push	ZH
	ret
.DB     " query",0x5,1<<EXEC
.DW	link
query:
.SET link=query
	ENV0_R16	ACK
query1:
	REC0
	cpi	r22,STX	;reception et ecrire wordbuf
	brne	query1
query2:
	call	Word1
	call	Find
	ori	r16,0
	brne	query3
	ld	r16,-X
	ld	r16,-X
	call	Number1
query3:
	ret
	
.DB     "adrw",0x4,1<<EXEC
.DW	link
adrw:
.SET link=adrw
	call	query
	ldi	r16,0x4E
	st	X+,r16
	ldi	r16,ESC
	st	X+,r16
	ldi	r24,4
	clr	r25
	call	Send0_1
	ret
	
	
.DB     "base",0x4,1<<EXEC
.DW	link
Base1:
.SET link=Base1
	ldi	r16,LOW(base)
	st	X+,r16
	ldi	r16,HIGH(base)
	st	X+,r16
	ret
	
.DB     " execute",0x7,1<<EXEC
.DW	link
Execute1:
.SET link=Execute1
	ld	r17,-X
	ld	r16,-X
	push	r16
	push	r17
	ret

.DB     " break",0x5,1<<EXEC
.DW	link
Break:
.SET link=Break
	pop	r16
	pop	r17
	ret

.DB     " readram",0x7,1<<EXEC
.DW	link
Readram:
.SET link=Readram
	push       YH
	push       YL
	ld	YH,-X
	ld	YL,-X
	ld	r25,-X
	ld	r24,-X
	push	r25
	push	r24
Readram1:
	ld	r17,y+
	st	x+,r17
	sbiw	r25:r24,1
	brne	readram1
	pop	r24
	pop	r25
	st	x+,r24
	st	x+,r25
	pop       YL
	pop       YH
	ret

.DB     "writeram",0x8,1<<EXEC
.DW	link
Writeram:
.SET link=Writeram
	push       YH
	push       YL
	ld	YH,-X
	ld	YL,-X
	ld	r25,-X
	ld	r24,-X
Writeram1:
	ld	r17,-X
	st	Y+,r17
	sbiw	r25:r24,1
	brne	Writeram1
	pop       YL
	pop       YH
	ret
.DB     " writeep",0x7,1<<EXEC
.DW	link
writeep:
.SET link=writeep
	in	r18,SREG
	push	r18
	cli
        push    YH
        push    YL
	ld	YH,-X
	ld	YL,-X
	ld	r25,-X
	ld	r24,-X
	;cbi EECR,EEPM0	; Write logical one to EEMPE
	;cbi EECR,EEPM1	; Start eeprom write by setti 	ng EEP
writeep1:
	sbic EECR,EEPE
	rjmp writeep1
writeep2:
	in	r18,SPMCSR ; controle flash pas en ecriture
	sbrc	r18, SPMEN
	rjmp	writeep2
	ld	r18,-X
	out EEDR,r18
	out	EEARH,YH
	out	EEARL,YL
	sbi EECR,EEMPE	; Write logical one to EEMPE
	sbi EECR,EEPE	; Start eeprom write by setting EEP
	adiw	YH:YL,1
	sbiw	r25:r24,1
	brne	writeep1
	pop    YL
	pop    YH
	pop	r18
	out	SREG,r18
	ret

.DB     " readeep",0x7,1<<EXEC
.DW	link
readeep:
.SET link=readeep
        push    YH
        push    YL
	ld	YH,-X
	ld	YL,-X
	ld	r25,-X
	ld	r24,-X
readeep0:
	push	r24
	push	r25
readeep1:
	sbic EECR,EEPE
	rjmp readeep1
	out	EEARH,YH
	out	EEARL,YL
	sbi	EECR,EERE
	in	r18,EEDR
	st	X+,r18
	adiw	YH:YL,1
	sbiw	r25:r24,1
	brne	readeep1
	pop	r25
	pop	r24
	pop    YL
	pop    YH
	st	x+,r24
	st	x+,r25
	ret
.DB     " hex",0x3,1<<EXEC
.DW	link
Hex:
.SET link=Hex
	ldi	r16,0x10
	ldi	r29,HIGH(base)
	ldi	r28,LOW(base)
	st	Y+,r16
	ret
.DB     "deci",0x4,1<<EXEC
.DW	link
Deci:
.SET link=Deci
	ldi	r16,0x0A
	ldi	r29,HIGH(base)
	ldi	r28,LOW(base)
	st	Y+,r16
	ret
.DB     " readflash",0x9,1<<EXEC
.DW	link
readflash:
.SET link=readflash
	ld	ZH,-X
	ld	ZL,-X
	lsl	ZL
	rol	ZH
	ld	r25,-X
        ld	r24,-X
	push	r25
	push	r24
readflash1:
	lpm	r17,Z+
	st	X+,r17
	sbiw	r25:r24,1
	brne	readflash1
	pop	r16
	st	X+,r16
	pop	r16
	st	X+,r16
	ret
	

.DB     ":I",0x2,1<<EXEC
.DW	link
DpointI:
.SET link=DpointI
	in	r16,SREG	; sauve pour si INT valide
	push	r16
	cli
	call	Dpoint0
	call	header
	ld	r16,-X
	push	r16
	ld	r16,-X
	push	r16
	ld	r16,-X
	ldi	r16,1<<IMMED
	st	X+,r16
	pop	r16
	st	X+,r16
	pop	r16
	st	X+,r16
	jmp	Dpoint01

.DB     ":isr",0x4,1<<EXEC
.DW	link
Isr:
.SET link=Isr
	in	r16,SREG	; sauve pour si INT valide
	push	r16
	cli
	call	Dpoint0
	call	header
	ld	r16,-X
	push	r16
	ld	r16,-X
	push	r16
	ld	r16,-X
	ldi	r16,1<<ISR
	st	X+,r16
	pop	r16
	st	X+,r16
	pop	r16
	st	X+,r16
	jmp	Dpoint01

.DB     " :",0x1,1<<EXEC
.DW	link
Dpoint:
.SET link=Dpoint
	in	r16,SREG	; sauve pour si INT valide
	push	r16
	cli
	call	Dpoint0
	call	header
Dpoint01:
        call	body
	call	Dpoint_end
	pop	r16	; restaure pour si INT valide
	out	SREG,r16
	ret

Dpoint0:
	pop	r3
	pop	r2
	sts	(DP_save),XL	;debut DP
	sts	(DP_save+1),XH
	lds	ZL,(dict) ;calcul de l'adresse pour readflash
	lds	ZH,(dict+1)
Dpoint1:
	andi	ZL,(PAGESIZE-1)
	breq	Dpoint2
	lsl	ZL
	st	X+,ZL	; count  octets
	clr     r16 
	st	X+,r16 
	lds	ZL,(dict)
	andi	ZL,(0x100-PAGESIZE)
	st	X+,ZL
	st	X+,ZH
	call	readflash
	ld	r16,-X 
	ld	r16,-X ;enleve quantite lu
	rjmp	Dpoint3
Dpoint2:
	lds	ZL,(dict)
	lsl	ZL
	rol	ZH
Dpoint3:
	ldi	r16,COMPILE
	sts	etat,r16
	ldi	r16,low(Dpoint_end)
	push	r16
	ldi	r16,high(Dpoint_end)
	push	r16
	push	r2
	push	r3
	ret
Dpoint_end:
	call	ecrireflash
	cpi	r16,0x12
	breq	Dpoint_end1
	ret
Dpoint_end1:
	lds	XL,(DP_save)	;debut DP
	lds	XH,(DP_save+1)
	lds	r24,(free_ram)
	lds	r25,(free_ram+1)
	adiw	r25:r24,0x20
	st	X+,r25
	st	X+,r24
	lds	r16,(free_ram)
	lds	r17,(free_ram+1)
	st	X+,r17
	st	X+,r16
	lsr	ZH
	ror	ZL
	sts	(dict),ZL
	sts	(dict+1),ZH
	lds	r16,(dict)
	lds	r17,(dict+1)
	st	X+,r17
	st	X+,r16
	lds	r16,(newword+1)	;nouvelle adresse du dernier mot
	sts	(lastword+1),r16
	st	X+,r16
	lds	r16,(newword)
	sts	(lastword),r16
	st	X+,r16
	ldi	r16,8	;ecrire nouvelles donnees dans eeprom
	st	X+,r16
	clr	r16,0	
	st	X+,r16
	st	X+,r16		;adresse des donnees
	st	X+,r16
	call	writeep
	ldi	r16,NORMAL
	sts	etat,r16
	;ENV0_R16	CONT
	ret
	
header:
	ENV0_R16	ACK
header0:
	REC0
	cpi	r22,STX
	brne	header0
	REC0
	mov	r16,r22
	push	r22
	sbrs	r22,0
	rjmp	header1
	st	X+,r22
	ld	r22,Z+
header1:
	REC0
	st	X+,r22
	adiw	ZH:ZL,1
	cpi	r22,0x21	; test caracteres indesirables
	brcs	header3
	cpi	r22,0x7F	; test caracteres indesirables
	brcc	header3
	dec	r16
	brne	header1
	pop	r22
	st	X+,r22
	ld	r22,Z+
	ldi	r16,1<<EXEC	;type de mot par default
	st	X+,r16
	ld	r22,Z+
	lds	r16,(lastword)
	st	X+,r16
	ld	r22,Z+
	lds	r16,(lastword+1)
	st	X+,r16
	ld	r22,Z+
	push	ZL
	push	ZH
	lsr	ZH
	ror	ZL
header2:
	sts	(newword),ZL
	sts	(newword+1),ZH
	pop	ZH
	pop	ZL
	ret
header3:
	pop	r17
header4:
	sbiw	ZH:ZL,1
	ld	r22,-X
	cp	r16,r17
	brcc	header5
	inc	r16
	rjmp	header4
header5:
	ldi	r16,NACK	;signale une erreur 
	st	X+,r16
	ldi	r16,ESC
	st	X+,r16
	ldi	r24,2
	clr	r25
	call	Send0_1
header6:
	REC0
	cpi	r22,SOH
	brne	header6
	rjmp	header
body:	
	call	Word
	ori	r16,0
	breq	body1
	call	Find
	ori	r16,0
	brne	body0
	ld	r16,-X
	ld	r16,-X
	call	Number1
body0:	
	lds	r16,type_find
	sbrs	r16,IMMED	; mot immediat
	rjmp	body2
	;ENV0_R16	0x49
	call	Execute1
	rjmp	body
body1:	
	call	Restitue
body11:	
	REC0
	cpi	r22,SOH
	brne	body11
	rjmp	body
body2:	
	sbrs	r16,EXEC	; mot a compiler
	rjmp	body3
	;ENV0_R16	0x43
	ld	r21,-X
	ld	r20,-X
	COMPILE20
	rjmp	body
body3:	
	sbrs	r16,NUM	; nombre
	rjmp	body6
	;ENV0_R16	0x4E
	rjmp	body
body6:	
	sbrs	r16,COMPILE	;mot executable a la compilation uniquement
	rjmp	Restitue
	;ENV0_R16	0x45
	ld	YH,-X
	ld	YL,-X
	adiw	YH:YL,1
	st	X+,YL
	st	X+,YH
	call	Execute1
	rjmp	body
	
Restitue:
	ENV0_R16	0x52
	ENV0_R16	0x45
	ENV0_R16	0x53
	ENV0_R16	0x20
	ldi	YL,LOW(wordbuf)
	ldi	YH,HIGH(wordbuf)
	ENV0_R16	ESC
	ENV0_R16	REST
	ld	r16,Y+
	mov	r21,r16
	ENV0
Restitue1:
	ld	r21,Y+
	ENV0
	dec	r16
	brne	Restitue1
	ret
.DB     " ;",0x1,1<<COMPILE
.DW	link
Pvirg:
.SET link=Pvirg
	ret
	pop	r21	;return	Body
	pop	r20	
	pop	r1	;return	Dpoint_end
	pop	r0
	pop	r19	;flag Dpoint_end
	pop	r18
	cpi	r18,LOW(Dpoint_end)
	brne	Pvirg11
	cpi	r19,High(Dpoint_end) 
	brne	Pvirg111
	push	r0	;return	Ddivmod_end
	push	r1
	ldi	r16,0x08 ;return word
	st	X+, r16
	ld	r16,Z+
	ldi	r16,0x95
	st	X+, r16
	ld	r16,Z+
	push	ZL
	push	ZH
	lsr	ZH
	ror	ZL
	sts	(newdict),ZL
	sts	(newdict+1),ZH
	pop	ZH
	pop	ZL
	;ENV0_R16	0x31
	;ENV0_R16	0x31
	ret
Pvirg1:
	;ENV0_R16	0x30
Pvirg11:
	;ENV0_R16	0x31
Pvirg111:
	;ENV0_R16	0x32
	;ENV0_R16	0x33
	push	r18	;flags Dpoint_end
	push	r19
	push	r0
	push	r1
	push	r20
	push	r21
	jmp	restitue
	
.DB     " definer",0x7,1<<EXEC
.DW	link
definer:
.SET link=definer
	in	r16,SREG	; sauve pour si INT valide
	push	r16
	cli
	call	Dpoint0
	pop	r16
	pop	r16
	ldi	r16,low(definer)
	push	r16
	ldi	r16,high(definer)
	push	r16
	call	header
	ldi	r20,LOW(_definer)
	ldi	r21,HIGH(_definer)
	COMPILE20
	call	body
	call	Dpoint_end
	pop	r16	; restaure pour si INT valide
	out	SREG,r16
	ret
	
.DB     "_definer",0x8,1<<EXEC
.DW	link
_definer:
	call	here
	ret

.DB     "does",0x4,1<<compile
.DW	link
does:
.SET link=does
	ret
	pop	r3	;return	Body
	pop	r2	
	pop	r1	;return	definer
	pop	r0
	pop	r19	;flag definer
	pop	r18
	cpi	r19,high(definer)
	brne	does1
	cpi	r18,LOW(definer)
	brne	does1
	ldi	r20,low(_does)
	ldi	r21,high(_does)
	COMPILE20
	ldi	r18,low(Dpoint_end)
	ldi	r19,high(Dpoint_end)
	rjmp	does2
does1:
	call	restitue
does2:
	push	r18	;flags Dpoint_end
	push	r19
	push	r0	;return	definer
	push	r1
	push	r2	;return	Body
	push	r3
	ret
.DB     " _does",0x5,1<<EXEC
.DW	link
_does:
	in	r16,SREG	; sauve pour si INT valide
	push	r16
	cli
	call	in_r
	call	Dpoint0
	pop	r16	;flags Dpoint pas besoin
	pop	r16
	call	header
	ldi	r20,LOW(num2)
	ldi	r21,HIGH(num2)
	COMPILE20
	call	out_r
	adiw	ZH:ZL,2
	ldi	r16,0x0C	; JMP apres does
	st	X+,r16
	ldi	r16,0X94
	st	X+,r16
	pop	r18	;sreg
	pop	r17	;adresse apres does pour jump
	pop	r16
	push	r18
	st	X+,r16
	st	X+,r17
	adiw	ZH:ZL,0x04
	call	Dpoint_end
	pop	r16	; restaure pour si INT valide
	out	SREG,r16
	clr	r16
	ret
.DB      " var",3,1<<EXEC
.DW	link
var:
.SET link=var
	call	_definer
	call	num2
.DW	0x02
	call	allot
	call	_does
	ret
.DB     " allot",0x5,1<<EXEC
.DW	link
allot:
.SET link=allot
	ld	r9,-X
	ld	r8,-X
	mov	r10,r9
	or	r10,r8
	breq	allot2
	lds	r24,free_ram
	lds	r25,free_ram+1
	st	X+,r24	; adresse premiere cells
	st	X+,r25
	mov	YH,XH
	mov	YL,XL
	add	YL,r8
	adc	YH,r9
	push	YL
	push	YH
	adiw	r25:r24,0x20
allot1:
	ld	r0,-X
	st	-Y,r0
	cp	r24,XL
	brne	allot1
	cp	r25,XH
	brne	allot1
	pop	XH	;nouveau fin de pile
	pop	XL
	st	X+,YL	;nouveau debut de pile
	st	X+,YH
	sbiw	YH:YL,0x20	;nouveau debut ram libre
	st	X+,YL
	st	X+,YH
	sts	(free_ram),YL
	sts	(free_ram+1),YH
	ldi	r16,4	;ecrire nouvelles donnees dans eeprom
	st	X+,r16
	clr	r16	
	st	X+,r16
	ldi	r16,4	;adresse des donnees
	st	X+,r16
	clr	r16	
	st	X+,r16
	call	writeep
	lds	YL,DP_save
	lds	YH,DP_save+1
	add	YL,r8
	adc	YH,r9
	sts	DP_save,YL
	sts	DP_save+1,YH
	rjmp	allot3
allot2:
	lds	r24,(free_ram)	;adresse si erreur
	st	X+,r24
	lds	r25,(free_ram+1)
	st	X+,r25
allot3:
	ret

.DB     "z1",0x2,1<<EXEC
.DW	link
z1:
.SET link=z1
	clr	r22
	st	X+,r22
	ret

.DB     "dup1",0x4,1<<EXEC
.DW	link
dup1:
.SET link=dup1
	ld	r16,-X
	st	X+,r16
	st	X+,r16
	ret

.DB     " dup",0x3,1<<EXEC
.DW	link
dup:
.SET link=dup
	ld	r16,-X
	ld	r17,-X
	st	X+,r17
	st	X+,r16
	st	X+,r17
	st	X+,r16
	ret

.DB     " swap1",0x5,1<<EXEC
.DW	link
swap1:
.SET link=swap1
	ld	r16,-X
	ld	r17,-X
	st	X+,r16
	st	X+,r17
	ret

.DB     "swap",0x4,1<<EXEC
.DW	link
swap:
.SET link=swap
	ld	r16,-X
	ld	r17,-X
	ld	r18,-X
	ld	r19,-X
	st	X+,r17
	st	X+,r16
	st	X+,r19
	st	X+,r18
	ret

.DB     " drop1",0x5,1<<EXEC
.DW	link
drop1:
.SET link=drop1
	ld	r16,-X
	ret

.DB     "drop",0x4,1<<EXEC
.DW	link
drop:
.SET link=drop
	ld	r16,-X
	ld	r16,-X
	ret

.DB     " over1",0x5,1<<EXEC
.DW	link
over1:
.SET link=over1
	ld	r2,-X
	ld	r3,-X
	st	X+,r3
	st	X+,r2
	st	X+,r3
	ret
	
.DB     "over",0x4,1<<EXEC
.DW	link
over:
.SET link=over
	ld	r2,-X
	ld	r3,-X
	ld	r4,-X
	ld	r5,-X
	st	X+,r5
	st	X+,r4
	st	X+,r3
	st	X+,r2
	st	X+,r5
	st	X+,r4
	ret

.DB     "rot1",0x4,1<<EXEC
.DW	link
rot1:
.SET link=rot1
	ld	r2,-X
	ld	r3,-X
	ld	r4,-X
	st	X+,r3
	st	X+,r2
	st	X+,r4
	ret
.DB     " rot",0x3,1<<EXEC
.DW	link
rot:
.SET link=rot
	ld	r2,-X
	ld	r3,-X
	ld	r4,-X
	ld	r5,-X
	ld	r6,-X
	ld	r7,-X
	st	X+,r5
	st	X+,r4
	st	X+,r3
	st	X+,r2
	st	X+,r7
	st	X+,r6
	ret
.DB     "pick",0x4,1<<EXEC
.DW	link
pick:
.SET link=pick
	ld	YH,-X
	ld	YL,-X
	lsl	YL
	rol	YH
	push	XL
	push	XH
	sub	XL,YL
	sbc	XH,YH
	ld	YL,X+
	ld	YH,X+
	pop	XH
	pop	XL
	st	X+,YL
	st	X+,YH
	ret
.DB     " pick1",0x5,1<<EXEC
.DW	link
pick1:
.SET link=pick1
	ld	YH,-X
	ld	YL,-X
	push	XL
	push	XH
	sub	XL,YL
	sbc	XH,YH
	ld	YL,X+
	pop	XH
	pop	XL
	st	X+,YL
	ret
.DB     "roll",0x4,1<<EXEC
.DW	link
roll2:
.SET link=roll2
	ld	YH,-X
	ld	YL,-X
	lsl	YL
	rol	YH
	push	XL
	push	XH
	sub	XL,YL
	sbc	XH,YH
	sbiw	YH:YL,2
	breq	roll22
	movw	ZH:ZL,XH:XL
	ld	r0,Z+
	ld	r1,Z+
roll21:
	ld	r2,Z+
	st	X+,r2
	sbiw	YH:YL,1
	brne	roll21
	st	X+,r0
	st	X+,r1
roll22:
	pop	XH
	pop	XL
	ret
.DB     " roll1",0x5,1<<EXEC
.DW	link
roll1:
.SET link=roll1
	ld	YH,-X
	ld	YL,-X
	push	XL
	push	XH
	sub	XL,YL
	sbc	XH,YH
	sbiw	YH:YL,1
	breq	roll12
	movw	ZH:ZL,XH:XL
	ld	r0,Z+
roll11:
	ld	r2,Z+
	st	X+,r2
	sbiw	YH:YL,1
	brne	roll11
	st	X+,r0
roll12:
	pop	XH
	pop	XL
	ret
.DB     "c!",0x2,1<<EXEC
.DW	link
Cwrite:
.SET link=Cwrite
	ld	r29,-X
	ld	r28,-X
	ld	r4,-X
	ld	r4,-X
	st	Y+,r4
	ret
.DB     " !",0x1,1<<EXEC
.DW	link
write:
.SET link=write
	ld	r29,-X
	ld	r28,-X
	ld	r5,-X
	ld	r4,-X
	st	Y+,r4
	st	Y+,r5
	ret
.DB     "c@",0x2,1<<EXEC
.DW	link
Cread:
.SET link=Cread
	ld	r29,-X
	ld	r28,-X
	ld	r4,y+
	st	X+,r4
	clr	r5
	st	X+,r5
	ret
.DB     " @",0x1,1<<EXEC
.DW	link
read:
.SET link=read
	ld	r29,-X
	ld	r28,-X
	ld	r4,Y+
	ld	r5,y+
	st	X+,r4
	st	X+,r5
	ret
.DB     "c,",0x2,1<<EXEC
.DW	link
Cvirg:
.SET link=Cvirg
	in	r16,SREG	; sauve pour si INT valide
	cli
	push	r16
	ld	r16,-X
	sbrs	r16,0
	rjmp	Cvirg1
	inc	r16
Cvirg1:
	mov 	r18,r16	; nombre de donnees sauvegarde
Cvirg2:
	ld	r17,-X
	push 	r17
	dec	r16
	brne	Cvirg2
	push	r18
	call	Dpoint0	
	pop	r16	;flags Dpoint pas besoin
	pop	r16
	pop	r16	; nombre de donnees
Cvirg3:
	pop	r17
	st	X+,r17
	ld	r17,Z+
	dec	r16
	brne	Cvirg3
	call	Dpoint_end
	pop	r16	; restaure pour si INT valide
	out	SREG,r16
	ret
.DB     " ,",0x1,1<<EXEC
.DW	link
Virg:
.SET link=Virg
	in	r16,SREG	; sauve pour si INT valide
	push	r16
	cli
	call	in_r
	call	Dpoint0	
	pop	r16	;flags Dpoint pas besoin
	pop	r16
	call	out_r
	ld	r16,Z+
	ld	r16,Z+
	call	Dpoint_end
	pop	r16	; restaure pour si INT valide
	out	SREG,r16
	ret
Virg3: 
.DB     "DP",0x2,1<<EXEC
.DW	link
DP:
.SET link=DP
	mov	r2,XL
	mov	r3,XH
	st	X+,r2
	st	X+,r3
	ret
.DB     "here",0x4,1<<EXEC
.DW	link
here:
.SET link=here
	lds	r2,dict
	lds	r3,dict+1
	st	X+,r2
	st	X+,r3
	ret
.DB     "do",0x2,1<<COMPILE
.DW	link
do:
.SET link=do
	ret
	pop	r1
	pop	r0
	ldi	r20,low(_do)
	ldi	r21,high(_do)
	push	r20
	push	r21
	push	r0
	push	r1
	COMPILE20
	ret
	
.DB     " _do",0x3,1<<COMPILE
.DW	link
_do:
	pop	r17	; adresse apres do
	pop	r16
	push	r16
	push	r17
	ld	r3,-X	;index I
	ld	r2,-X
	ld	r1,-X	;limit de  I
	ld	r0,-X
	push	r0
	push	r1
	push	r2
	push	r3
	push	r16	; adresse apres do
	push	r17
	ret

.DB     "loop",0x4,1<<COMPILE
.DW	link
loop:
.SET link=loop
	ret
	pop	r1	;adresse de retour
	pop	r0
	pop	r17	;verifie do
	pop	r16
	cpi	r16,low(_do)
	brne	loop1
	cpi	r17,high(_do)
	brne	loop1
	ldi	r20,low(_loop)
	ldi	r21,high(_loop)
	push	r0	;adresse de retour
	push	r1
	COMPILE20
	ret
loop1:
	push	r16	;verifie do
	push	r17
	push	r0	;adresse de retour
	push	r1
	jmp	restitue
	
.DB     " _loop",0x5,1<<COMPILE
.DW	link
_loop:
	pop	r1	;adresse de retour apres loop
	pop	r0
	pop	r25	;index I
	pop	r24
	pop	r3	;limit de I
	pop	r2
	cp	r25,r3
	brlo	_loop2
	cp	r24,r2
	brlo	_loop2
_loop1:
	pop	r17	;adresse apres do, fin de boucle
	pop	r16
	push	r0	;fin de boucle
	push	r1
	ret
_loop2:
	adiw	r25:r24,1
	pop	r1	;adresse apres do
	pop	r0
	push	r0
	push	r1
	push	r2	;limit de I
	push	r3
	push	r24	;index I
	push	r25
	push	r0	;adresse apres do
	push	r1
	ret
	
.DB     "if",0x2,1<<COMPILE
.DW	link
if:
.SET link=if
	ret
	pop	r19
	pop	r18
	ldi	r16,0x11	; BRNE
	st	X+,r16
	ldi	r16,0XF4
	st	X+,r16
	ldi	r16,0x0C	; JMP
	st	X+,r16
	ldi	r16,0X94
	st	X+,r16
	push	XL	; stocke adresse de JMP
	push	XH
	st	X+,r16 ;resserve pour adressse de JMP
	clr	r16
	st	X+,r16
	adiw	ZH:ZL,6
	ldi	r16,0X01 ; controle 0x0001 pour then 0x0002 apres else
	push	r16
	clr	r16
	push	r16
	push	r18
	push	r19
	ret
	
.DB     "then",0x4,1<<COMPILE
.DW	link
Then:
.SET link=then
	ret
	pop	r19	;adresse de retour
	pop	r18
	pop	r17	;verifie if
	pop	r16
	cpi	r17,0
	brne	Then1
	cpi	r16,0x01	; sans else
	breq	Then2
	cpi	r16,0x02	; avec else
	breq	Then2
Then1:
	push	r16
	push	r17
	push	r18
	push	r19
	jmp	restitue
	
Then2:
	pop	YH	;Then
	pop	YL
	clr	r16	; nop pour then
	st	X+,r16
	st	X+,r16
	adiw	ZH:ZL,2
	push	ZL
	push	ZH
	lsr	ZH
	ror	ZL
	st	Y+,ZL	;adresse de saut apres if
	st	Y+,ZH
	pop	ZH
	pop	ZL
	push	r18
	push	r19
	ret
	
.DB     "else",0x4,1<<COMPILE
.DW	link
Else:
.SET link=Else
	ret
	pop	r19	;adresse de retour
	pop	r18
	pop	r17	;verifie if
	pop	r16
	cpi	r17,0
	brne	Else1
	cpi	r16,0x01	; sans else
	breq	Else2
Else1:
	push	r16
	push	r17
	push	r18
	push	r19
	jmp	restitue
	
Else2:
	pop	YH	;adresse adresse de JMP de IF
	pop	YL
	ldi	r16,0x0C	; JMP de Else
	st	X+,r16
	ldi	r16,0X94
	st	X+,r16	
	push	XL	; adresse JMP de else
	push	XH
	st	X+,r16
	st	X+,r16
	adiw	ZH:ZL,4
	push	ZL
	push	ZH
	lsr	ZH
	ror	ZL
	sbiw	YH:YL,4		; modif BRNE en BREQ  de if
	ldi	r16,0x11
	st	y+,r16
	ldi	r16,0XF0
	st	y+,r16
	adiw	YH:YL,2
	st	Y+,ZL	;adresse de saut apres if
	st	Y+,ZH
	pop	ZH
	pop	ZL
	ldi	r16,0x2	; signal Else
	push	r16
	clr	r16
	push	r16
	push	r18
	push	r19
	ret	
.DB     " begin",0x5,1<<COMPILE
.DW	link
begin:
.SET link=begin
	ret
	pop	r19
	pop	r18
	ldi	r16,0x0	; and r0,r0 pour begin
	st	X+,r16
	ldi	r16,0X20
	st	X+,r16
	adiw	ZH:ZL,2
	mov	r20,ZL
	mov	r21,ZH
	lsr	r21
	ror	r20
	push	r20	; stocke adresse pour JMP
	push	r21
	ldi	r16,0X03 ; controle 0x0003 pour again et until
	push	r16
	clr	r16
	push	r16
	push	r18
	push	r19
	ret
	
.DB     " again",0x5,1<<COMPILE
.DW	link
again:
.SET link=again
	ret
	pop	r19	;adresse de retour
	pop	r18
	pop	r17	;verifie begin
	pop	r16
	cpi	r17,0
	brne	again1
	cpi	r16,0x03	; begin
	breq	again2
again1:
	push	r16
	push	r17
	push	r18
	push	r19
	jmp	restitue
	
again2:
	ldi	r16,0x0C	; JMP pour again
	st	X+,r16
	ldi	r16,0X94
	st	X+,r16
	pop	r17
	pop	r16
	st	X+,r16
	st	X+,r17
	adiw	ZH:ZL,4
	push	r18
	push	r19
	ret
		
.DB     " until",0x5,1<<COMPILE
.DW	link
until:
.SET link=until
	ret
	pop	r19	;adresse de retour
	pop	r18
	pop	r17	;verifie begin
	pop	r16
	cpi	r17,0
	brne	until1
	cpi	r16,0x03	; begin
	breq	until2
until1:
	push	r16
	push	r17
	push	r18
	push	r19
	jmp	restitue
	
until2:
	ldi	r16,0x11	; brne +2 pour until
	st	X+,r16
	ldi	r16,0XF4
	st	X+,r16
	ldi	r16,0x0C	; JMP pour until
	st	X+,r16
	ldi	r16,0X94
	st	X+,r16
	pop	r17
	pop	r16
	st	X+,r16
	st	X+,r17
	adiw	ZH:ZL,6
	push	r18
	push	r19
	ret
	
.DB     " while",0x5,1<<COMPILE
.DW	link
while:
.SET link=while
	ret
	pop	r19	;adresse de retour
	pop	r18
	pop	r17	;verifie begin
	pop	r16
	cpi	r17,0
	brne	while1
	cpi	r16,0x03	; begin
	breq	while2
while1:
	push	r16
	push	r17
	push	r18
	push	r19
	jmp	restitue
	
while2:
	ldi	r16,0x11	; brne +2 de while
	st	X+,r16
	ldi	r16,0XF4
	st	X+,r16
	ldi	r16,0x0C	; JMP pour repeat
	st	X+,r16
	ldi	r16,0X94
	st	X+,r16
	mov	r20,XL
	mov	r21,XH
	st	X+,r16
	st	X+,r16
	push	r20	; stocke adresse pour JMP
	push	r21
	adiw	ZH:ZL,6
	ldi	r16,0X04 ; controle 0x0004 pour while
	push	r16
	clr	r16
	push	r16
	push	r18
	push	r19
	ret
.DB     "repeat",0x6,1<<COMPILE
.DW	link
Repeat:
.SET link=Repeat
	ret
	pop	r19	;adresse de retour
	pop	r18
	pop	r17	;verifie while
	pop	r16
	cpi	r17,0
	brne	Repeat1
	cpi	r16,0x04	; while
	breq	Repeat2
Repeat1:
	push	r16
	push	r17
	push	r18
	push	r19
	jmp	restitue
	
Repeat2:
	pop	YH
	pop	YL
	ldi	r16,0x0C	; JMP pour repeat
	st	X+,r16
	ldi	r16,0X94
	st	X+,r16
	pop	r17
	pop	r16
	st	X+,r16
	st	X+,r17
	adiw	ZH:ZL,4
	mov	r20,ZL
	mov	r21,ZH
	lsr	r21
	ror	r20
	st	Y+,r20
	st	Y+,r21
	push	r18
	push	r19
	ret
	
.DB     " leave",0x5,1<<EXEC
.DW	link
leave:
.SET link=leave
	pop	r5	;adresse de retour
	pop	r4
	pop	r3	;index I
	pop	r2
	pop	r1	;limit de I
	pop	r0
	push	r0	;limit de I
	push	r1
	push	r0	;index I
	push	r1
	push	r4
	push	r5
	ret
.DB     " I",0x1,1<<EXEC
.DW	link
_I:
.SET link=_I	
	pop	r5	;adresse de retour
	pop	r4
	pop	r3	;index I
	pop	r2
	push	r2	
	push	r3
	push	r4
	push	r5
	st	X+,r2
	st	X+,r3
	ret

.DB     " J",0x1,1<<EXEC
.DW	link
_J:
.SET link=_J
	pop	r9	;adresse de retour
	pop	r8
	pop	r7	;index I
	pop	r6
	pop	r5	;limit de I
	pop	r4
	pop	r3	;adresse de retour boucle DO
	pop	r2
	pop	r1	;index J
	pop	r0
	push	r0	;index J
	push	r1
	push	r2	;adresse de retour boucle DO
	push	r3
	push	r4	;limit de I
	push	r5
	push	r6	;index I
	push	r7
	push	r8	;adresse de retour
	push	r9
	st	X+,r0
	st	X+,r1
	ret

.DB     ">r",0x2,1<<EXEC
.DW	link
in_r:
.SET link=in_r
	pop	r1
	pop	r0
	ld	r17,-X
	ld	r16,-X
	push	r16
	push	r17
	push	r0
	push	r1
	ret
.DB     "<r",0x2,1<<EXEC
.DW	link
out_r:
.SET link=out_r
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	st	X+,r0
	st	X+,r1
	push	r2
	push	r3
	ret
.DB     "r!",0x2,1<<EXEC
.DW	link
read_r:
.SET link=read_r
	pop	r1
	pop	r0
	pop	r3
	pop	r2
	ld	r17,-X
	ld	r16,-X
	st	X+,r16
	st	X+,r17
	push	r16
	push	r17
	push	r0
	push	r1
	ret
.DB     "r@",0x2,1<<EXEC
.DW	link
write_r:
.SET link=write_r
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	st	X+,r0
	st	X+,r1
	push	r0
	push	r1
	push	r2
	push	r3
	ret
.DB     "c?",0x2,1<<EXEC
.DW	link
Cq:
.SET link=Cq
	ld	r16,-X
	st	X+,r16
	or	r16,r16
	ret
	
.DB     " ?",0x1,1<<EXEC
.DW	link
Q:
.SET link=Q
	ld	r17,-X
	ld	r16,-X
	st	X+,r16
	st	X+,r17
	or	r16,r17
	ret

	
.DB     "/?",0x2,1<<EXEC
.DW	link
No:
.SET link=No
	ld	r17,-X
	ld	r16,-X
	st	X+,r16
	st	X+,r17
	or	r16,r17
	brne    No1   
	clz
	ret
No1:
	sez
	ret

.DB     " =",0x1,1<<EXEC
.DW	link
_eq:
.SET link=_eq
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	eor	r2,r4
	eor	r3,r5
	or	r2,r3
	breq	_eq1
	sez
	ret
_eq1:	
	clz
	ret
	
.DB     "0=",0x2,1<<EXEC
.DW	link
Zeq:
.SET link=Zeq
	ld	r17,-X
	ld	r16,-X
	or	r16,r17
	breq	zeq1
	sez
	ret
Zeq1:	
	clz
	ret

.DB     "<>",0x2,1<<EXEC
.DW	link
diff:
.SET link=diff
	ld	r3,-X
	ld	r2,-X
	ld	r5,-X
	ld	r4,-X
	cp	r2,r4
	brne	diff1
	cp	r3,r5
	brne	diff1
	sez
	ret
diff1:	
	clz
	ret
.DB     " 0<>",0x3,1<<EXEC
.DW	link
zdiff:
.SET link=zdiff
	ld	r3,-X
	ld	r2,-X
	or	r2,r3
	ret
.DB     " <",0x1,1<<EXEC
.DW	link
inf:
.SET link=inf
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	cp	r3,r5
	brcs	inf2
	brne	inf1
	cp	r2,r4
	brcs	inf2	
inf1:		
	sez
	ret
inf2:	
	clz
	ret
.DB     " >",0x1,1<<EXEC
.DW	link
sup:
.SET link=sup
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	cp	r5,r3
	brcs	sup2
	brne	sup1
	cp	r4,r2
	brcs	sup2	
sup1:		
	sez
	ret
sup2:		
	clz
	ret
.DB     "<=",0x2,1<<EXEC
.DW	link
eqinf:
.SET link=eqinf
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	cp	r5,r3
	brcs	eqinf2
	brne	eqinf1
	cp	r4,r2
	brcs	eqinf2	
eqinf1:		
	clz
	ret
eqinf2:	
	sez
	ret
.DB     ">=",0x2,1<<EXEC
.DW	link
eqsup:
.SET link=eqsup
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	cp	r3,r5
	brcs	eqsup2
	brne	eqsup1
	cp	r2,r4
	brcs	eqsup2	
eqsup1:		
	clz
	ret
eqsup2:		
	sez
	ret
.DB     " +",0x1,1<<EXEC
.DW	link
plus:
.SET link=plus
	ld	r3,-X
	ld	r2,-X
	ld	r5,-X
	ld	r4,-X
	add	r2,r4
	adc	r3,r5
	st	X+,r2
	st	X+,r3
	ret
	
.DB     " -",0x1,1<<EXEC
.DW	link
moins:
.SET link=moins
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	sub	r2,r4
	sbc	r3,r5
	st	X+,r2
	st	X+,r3
	ret
.DB     "*D",0x2,1<<EXEC
.DW	link
multD:
.SET link=multD
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	clr	r7
	clr	r8
	mul	r2,r4
	st	x+,r0
	mov	r6,r1
	mul	r3,r4
	add	r6,r0
	adc	r7,r1
	mul	r2,r5
	add	r6,r0
	adc	r7,r1
	brcc	multD1
	inc	r8
multD1:
	mul	r3,r5
	add	r7,r0
	adc	r8,r1
	st	x+,r6
	st	x+,r7
	st	x+,r8
	ret
	
.DB     " *",0x1,1<<EXEC
.DW	link
mult:
.SET link=mult
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	mul	r2,r4
	st	x+,r0
	mov	r6,r1
	mul	r3,r4
	add	r6,r0
	mul	r2,r5
	add	r6,r0
	st	x+,r6
	ret
	
.DB     "/mod",0x4,1<<EXEC
.DW	link
divmod:
.SET link=divmod
	ldi	r16,0x10
	ld	r3,-X
	ld	r2,-X
	ld	r1,-X
	ld	r0,-X
divmod0:
	clr	r5
	clr	r6
	clr	r7
	clr	r8
divmod1:
	lsl	r0
	rol	r1
	rol	r5
	rol	r6
	cp	r6,r3
	brcs	divmod3 ; inferieur
	brne	divmod2	;superieur
	cp	r5,r2
	brcs	divmod3 ; inferieur
divmod2:
	sub	r5,r2
	sbc	r6,r3
	inc	r7
divmod3:
	dec	r16
	breq	divmod4
	lsl	r7
	rol	r8
	rjmp	divmod1
divmod4:
	st	X+,r7
	st	X+,r8
	st	X+,r5
	st	X+,r6
	ret
.DB     " /",0x1,1<<EXEC
.DW	link
div:
.SET link=div
	call	divmod
	sbiw	XH:XL,2
	ret
	
.DB     " mod",0x3,1<<EXEC
.DW	link
mod:
.SET link=mod
	call	divmod
	ld	r3,-X
	ld	r2,-X
	ld	r1,-X
	ld	r0,-X
	st	X+,r2
	st	X+,r3
	ret

.DB     "or",0x2,1<<EXEC
.DW	link
_or:
.SET link=_or
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	or	r2,r4
	or	r3,r5
	st	X+,r2
	st	X+,r3
	ret
.DB     " and",0x3,1<<EXEC
.DW	link
_and:
.SET link=_and
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	and	r2,r4
	and	r3,r5
	st	X+,r2
	st	X+,r3
	ret
	
.DB     " xor",0x3,1<<EXEC
.DW	link
_xor:
.SET link=_xor
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
	eor	r2,r4
	eor	r3,r5
	st	X+,r2
	st	X+,r3
	ret
	
.DB     " not",0x3,1<<EXEC
.DW	link
_not:
.SET link=_not
	ld	r3,-X
	ld	r2,-X
	com	r2
	com	r3
	st	X+,r2
	st	X+,r3
	ret
.DB     "<<",0x2,1<<EXEC
.DW	link
Lshift:
.SET link=Lshift
	clc
	ld	r4,-X
	ld	r4,-X
	or     r4,r4
	brne    Lshift01
	ret
Lshift01:
	ld	r3,-X
	ld	r2,-X
Lshift1:
	lsl	r2
	rol	r3
	dec	r4
	brne	Lshift1
	st	X+,r2
	st	X+,r3
	ret
.DB     ">>",0x2,1<<EXEC
.DW	link
Rshift:
.SET link=Rshift
	clc
	ld	r4,-X
	ld	r4,-X
	or     r4,r4
	brne   Rshift01
	ret
Rshift01:
	ld	r3,-X
	ld	r2,-X
Rshift1:
	lsr	r3
	ror	r2
	dec	r4
	brne	Rshift1
	st	X+,r2
	st	X+,r3
	ret
.DB     " <<c",0x3,1<<EXEC
.DW	link
Clshift:
.SET link=Clshift
	ld	r4,-X
	ld	r4,-X
	or     r4,r4
	brne   Clshift01
	ret
Clshift01:
	ld	r3,-X
	ld	r2,-X
Clshift1:
	rol	r2
	rol	r3
	dec	r4
	brne	Clshift1
	st	X+,r2
	st	X+,r3
	ret
.DB     " c>>",0x3,1<<EXEC
.DW	link
Crshift:
.SET link=Crshift
	ld	r4,-X
	ld	r4,-X
	or     r4,r4
	brne   Crshift01
	ret
Crshift01:
	ld	r3,-X
	ld	r2,-X
Crshift1:
	ror	r3
	ror	r2
	dec	r4
	brne	Crshift1
	st	X+,r2
	st	X+,r3
	ret
.DB     " carry",0x5,1<<EXEC
.DW	link
_carry:
.SET link=_carry
	clz
	brcs	_carry1
	sez
_carry1:	
	ret
.DB     "setc",0x4,1<<EXEC
.DW	link
setc:
.SET link=setc
	sec
	ret
.DB     "clrc",0x4,1<<EXEC
.DW	link
clrc:
.SET link=clrc
	clc
	ret
.DB     "setz",0x4,1<<EXEC
.DW	link
setz:
.SET link=setz
	sez
	ret
.DB     "clrz",0x4,1<<EXEC
.DW	link
clrz:
.SET link=clrz
	clz
	ret
.DB     "togz",0x4,1<<EXEC
.DW	link
togz:
.SET link=togz
	brne	togz1
	clz
	ret
togz1:
	sez
	ret
.DB     "togc",0x4,1<<EXEC
.DW	link
togc:
.SET link=togc
	brcc	togc1
	clc
	ret
togc1:
	sec
	ret
.DB     " tbits",0x5,1<<EXEC
.DW	link
tbits:
.SET link=tbits
	ld	r16,-X
	ld	r16,-X
	ld	r19,-X
	ld	r18,-X
	st	X+,r18
	st	X+,r19
	ldi	r17,0x01
	andi	r16,0x0F
	cpi	r16,0x08
	brcs	tbits1
	mov	r18,r19
	andi	r16,0x07
tbits1:
	or	r16,r16
	breq	tbits3
tbits2:
	lsl	r17
	dec	r16
	brne	tbits2
tbits3:
	and	r18,r17
	ret
.DB     " sbits",0x5,1<<EXEC
.DW	link
sbits:
.SET link=sbits
	ld	r16,-X
	ld	r16,-X
	ldi	r17,0x01
	andi	r16,0x0F
	cpi	r16,0x08
	brcc	sbits1
	ld	r19,-X
	ld	r18,-X
	call	sbits2
	or	r18,r17
	st	X+,r18
	st	X+,r19
	ret
sbits1:
	ld	r18,-X
	andi	r16,0x07
	call	sbits2
	or	r18,r17
	st	X+,r18
	ret
sbits2:
	or	r16,r16
	breq	sbits4
sbits3:
	lsl	r17
	dec	r16
	brne	sbits3
sbits4:
	ret
.DB     " cbits",0x5,1<<EXEC
.DW	link
cbits:
.SET link=cbits
	ld	r16,-X
	ld	r16,-X
	ldi	r17,0x01
	andi	r16,0x0F
	cpi	r16,0x08
	brcc	cbits1
	ld	r19,-X
	ld	r18,-X
	call	cbits2
	and	r18,r17
	st	X+,r18
	st	X+,r19
	ret
cbits1:
	ld	r18,-X
	andi	r16,0x07
	call	cbits2
	and	r18,r17
	st	X+,r18
	ret
cbits2:
	or	r16,r16
	breq	cbits4
cbits3:
	lsl	r17
	dec	r16
	brne	cbits3
cbits4:
	com	r17
	ret
.DB     "in_d",0x4,1<<EXEC
.DW	link
in_d1:
.SET link=in_d1
	in	r16,pind
	st	X+,r16
	clr	r16
	st	X+,r16
	ret
.DB     " clrd6",0x5,1<<EXEC
.DW	link
clrd6:
.SET link=clrd6
	cbi	portd,6
	ret
.DB     " clrd7",0x5,1<<EXEC
.DW	link
clrd7:
.SET link=clrd7
	cbi	portd,7
	ret
.DB     " setd6",0x5,1<<EXEC
.DW	link
setd6:
.SET link=setd6
	sbi	portd,6
	ret
.DB     " setd7",0x5,1<<EXEC
.DW	link
setd7:
.SET link=setd7
	sbi	portd,7
	ret
.DB     "1+",0x2,1<<EXEC
.DW	link
plus1:
.SET link=plus1
	ld	r25,-X
	ld	r24,-X
	adiw	r25:r24,1
	st	X+,r24
	st	X+,r25
	ret
.DB     "1-",0x2,1<<EXEC
.DW	link
moins1:
.SET link=moins1
	ld	r25,-X
	ld	r24,-X
	sbiw	r25:r24,1
	st	X+,r24
	st	X+,r25
	ret
.DB     "2+",0x2,1<<EXEC
.DW	link
plus2:
.SET link=plus2
	ld	r25,-X
	ld	r24,-X
	adiw	r25:r24,2
	st	X+,r24
	st	X+,r25
	ret
.DB     "2-",0x2,1<<EXEC
.DW	link
moins2:
.SET link=moins2
	ld	r25,-X
	ld	r24,-X
	sbiw	r25:r24,2
	st	X+,r24
	st	X+,r25
	ret
.DB     " flash",0x5,1<<EXEC
.DW	link
flash:
.SET link=flash
	ENV0_R16	0x46
	ENV0_R16	0x4C
	ENV0_R16	0x41
	ENV0_R16	0x53
	ENV0_R16	0x48
	ENV0_R16	0x20
	PUSHZ
	lds	ZL,(dict) ;calcul de l'adresse pour readflash
	lds	ZH,(dict+1)
	andi	ZL,0xF8
	sbiw	ZH:ZL,0x38
	sbiw	ZH:ZL,0x38
	sbiw	ZH:ZL,0x08
	lsl	ZL
	rol	ZH	
	st	X+,ZL
	st	X+,ZH
	clr    r16
	st	X+,r16
	ENV0_R16	ESC
	ENV0_R16	TAB
	ldi	r24,3
	clr	r25
	call	Send0_1
	ldi	r25,0x1
	mov	r21,r25
	ENV0
	clr	r24
	mov	r21,r24
	ENV0
flash1:
	elpm	r21,Z+
	ENV0
	sbiw	r25:r24,1
	brne	flash1
	POPZ
	ret
	
.DB     "dp",0x2,1<<EXEC
.DW	link
_dp:
.SET link=_dp
	ENV0_R16	0x44
	ENV0_R16	0x50
	ENV0_R16	0x20
	mov	YL,XL
	mov	YH,XH
	sbiw	YH:YL,0x3E
	sbiw	YH:YL,0x02
	ENV0_R16	ESC
	ENV0_R16	TAB
	st	X+,YL
	st	X+,YH
	clr	r16
	st	X+,r16
	ldi	r24,3
	clr	r25
	call	Send0_1
	clr	r21
	ENV0
	ldi	r21,0x40
	ENV0
	ldi	r16,0x40
_dp1:
	ld	r21,Y+
	ENV0
	dec	r16
	brne	_dp1
	ret
	
.DB     "sp",0x2,1<<EXEC
.DW	link
_sp:
.SET link=_sp
	ENV0_R16	0x53
	ENV0_R16	0x50
	ENV0_R16	0x20
	in	r16,SPL
	mov	YL,r16
	in	r16,SPH
	mov	YH,r16
	adiw	YH:YL,1
	st	X+,YL
	st	X+,YH
	clr	r16
	st	X+,r16
	ENV0_R16	ESC
	ENV0_R16	TAB
	ldi	r24,3
	clr	r25
	call	Send0_1
	clr	r21
	ENV0
	ldi	r21,0x40
	ENV0
	ldi	r16,0x40
_sp1:
	ld	r21,Y+
	ENV0
	dec	r16
	brne	_sp1
	ret
	
.DB     " ram",0x3,1<<EXEC
.DW	link
_ram:
.SET link=_ram
	ENV0_R16	0x52
	ENV0_R16	0x41
	ENV0_R16	0x4D
	ENV0_R16	0x20
	ld	YH,-X
	ld	YL,-X
	st	X+,YL
	st	X+,YH
	clr	r16
	st	X+,r16
	ENV0_R16	ESC
	ENV0_R16	TAB
	ldi	r24,3
	clr	r25
	call	Send0_1
	clr	r21
	ENV0
	ldi	r21,0x40
	ENV0
	ldi	r16,0x40
_ram1:
	ld	r21,Y+
	ENV0
	dec	r16
	brne	_ram1
	ret
.DB     " eep",0x3,1<<EXEC
.DW	link
_eep:
.SET link=_eep
	ENV0_R16	0x45
	ENV0_R16	0x65
	ENV0_R16	0x70
	ENV0_R16	0x20
	ld	YH,-X
	ld	YL,-X
	st	X+,YL
	st	X+,YH
	ENV0_R16	ESC
	ENV0_R16	TAB
	clr	r16
	st	X+,r16
	ldi	r24,3
	clr	r25
	call	Send0_1
	clr	r21
	ENV0
	ldi	r21,0x40
	ENV0
	ldi	r16,0x40
	st	X+,r16
	clr	r16
	st	X+,r16
	st	X+,YL
	st	X+,YH
	push   r25
	push   r24
	call	readeep
	pop    r24
	pop    r25
	ld	r16,-X
	ld	r16,-X
	mov	r17,r16
_eep1:
	ld	r21,-X
	push	r21
	dec	r16
	brne	_eep1
_eep2:
	pop	r21
	ENV0
	dec	r17
	brne	_eep2
	ret
.DB     "c.",0x2,1<<EXEC
.DW	link
Cpoint:
.SET link=Cpoint
	clr	r0
	lds	r1,base
	ld	r2,-X
Cpoint0:
	ldi	r16,0x08
	clr	r6
	clr	r17
	clr	r5
Cpoint1:
	lsl	r2
	rol	r17
	cp	r17,r1
	brcs	Cpoint2
	sub	r17,r1
	inc	r6
Cpoint2:
	dec	r16
	breq	Cpoint3
	lsl	r6
	rjmp	Cpoint1
Cpoint3:
	inc	r0
	ldi	r18,0x30
	add	r17,r18
	cpi	r17,0x3A
	brcs	Cpoint33
	ldi	r18,0x07
	add	r17,r18
Cpoint33:
	st	x+,r17
	mov	r2,r6
	cp	r6,r1
	brcs	Cpoint5
Cpoint4:
	rjmp	Cpoint0
Cpoint5:
	mov	r17,r6
	or	r17,r6
	breq	Cpoint6
	ldi	r18,0x30
	add	r17,r18
	cpi	r17,0x3A
	brcs	Cpoint55
	ldi	r18,0x07
	add	r17,r18
Cpoint55:
	st	x+,r17
	inc	r0
Cpoint6:
	mov	r16,r0
	call	Display1
	ret
	
.DB     " .",0x1,1<<EXEC
.DW	link
point:
.SET link=point
	clr	r0
	lds	r1,base
	ld	r3,-X
	ld	r2,-X
point0:
	ldi	r16,0x10
	clr	r6
	clr	r7
	clr	r17
	clr	r5
point1:
	lsl	r2
	rol	r3
	rol	r17
	cp	r17,r1
	brcs	point2
	sub	r17,r1
	inc	r6
point2:
	dec	r16
	breq	point3
	lsl	r6
	rol	r7
	rjmp	point1
point3:
	inc	r0
	ldi	r18,0x30
	add	r17,r18
	cpi	r17,0x3A
	brcs	point33
	ldi	r18,0x07
	add	r17,r18
point33:
	st	x+,r17
	movw	r3:r2,r7:r6
	or	r7,r7
	brne	point4
	cp	r6,r1
	brcs	point5
point4:
	rjmp	point0
point5:
	mov	r17,r6
	or	r17,r6
	breq	point6
	ldi	r18,0x30
	add	r17,r18
	cpi	r17,0x3A
	brcs	point55
	ldi	r18,0x07
	add	r17,r18
point55:
	st	x+,r17
	inc	r0
point6:
	mov	r16,r0
	call	Display1
	ret
	
.DB     "D.",0x2,1<<EXEC
.DW	link
Double:
.SET link=Double
	clr	r0
	lds	r1,base
	ld	r5,-X
	ld	r4,-X
	ld	r3,-X
	ld	r2,-X
Double0:
	ldi	r16,0x20
	clr	r6
	clr	r7
	clr	r8
	clr	r9
	clr	r17
Double1:
	lsl	r2
	rol	r3
	rol	r4
	rol	r5
	rol	r17
	cp	r17,r1
	brcs	Double2
	sub	r17,r1
	inc	r6
Double2:
	dec	r16
	breq	Double3
	lsl	r6
	rol	r7
	rol	r8
	rol	r9
	rjmp	Double1
Double3:
	inc	r0
	ldi	r18,0x30
	add	r17,r18
	cpi	r17,0x3A
	brcs	Double33
	ldi	r18,0x07
	add	r17,r18
Double33:
	st	x+,r17
	movw	r3:r2,r7:r6
	movw	r5:r4,r9:r8
	or	r8,r9
	or	r8,r7
	brne	Double4
	cp	r6,r1
	brcs	Double5
Double4:
	rjmp	Double0
Double5:
	mov	r17,r6
	or	r17,r6
	breq	Double6
	ldi	r18,0x30
	add	r17,r18
	cpi	r17,0x3A
	brcs	Double55
	ldi	r18,0x07
	add	r17,r18
Double55:
	st	x+,r17
	inc	r0
Double6:
	mov	r16,r0
	call	Display1
	ret

.DB     " debug",0x5,1<<EXEC
.DW	link
debug:
.SET link=debug
	call	flash
	call	_dp
	call	_sp
	clr	r16
	st	X+,r16
	st	X+,r16
	call	_eep
	clr	r16
	st	X+,r16
	inc	r16
	st	X+,r16	
	call	_ram
	ret

.DB     " icode",0x5,1<<COMPILE
.DW	link
Icode:
.SET link=Icode
	ret
	adiw	ZH:ZL,2
	ret
	
.DB     "code",0x4,1<<COMPILE
.DW	link
code:
.SET link=code
	ret
	call	Word
	call	Number1
	or	r16,r16
	breq	code2
code1:
	jmp	Number551
	ret
code2:
	call	Execute1
	ret
	ENV0_R16	0x52
	ENV0_R16	0x45
	ENV0_R16	0x53
	ENV0_R16	0x43
	ENV0_R16	0x20
	ENV0_R16	ESC
	ENV0_R16	REST
	clr	r16
	ldi	ZH,high(Send_code)
	ldi	ZL,low(Send_code)
	lsl	ZL
	rol	ZH
	lpm	r16,z+
	mov	r21,r16
	ENV0
code3:
	push r16
	lpm	r21,z+
	ENV0
	dec	r16
	brne	code3
	ret
	

.DB     " [",0x1,1<<COMPILE
.DW	link
Hook:
.SET link=Hook	
	ret
	push	ZL
	push	ZH
	lds	r16,etat
	push	r16
	ldi	r16,NORMAL
	sts	etat,r16
	call	Receive0
Hook1:
	pop	r16
	sts	etat,r16
	pop	ZH
	pop	ZL
	ret
	

.DB     " ]",0x1,1<<IMMED
.DW	link
NHook:
.SET link=NHook	
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	push	r16
	push	r17
	cpi	r16,low(hook1)
	brne	NHook1
	cpi	r17,high(hook1)
	breq	NHook2
NHook1:
	ENV0_R16	0x4F
	ENV0_R16	0x4F
	ENV0_R16	0x4F
	push	r18
	push	r19
NHook2:
	ENV0_R16	0x4B
	ENV0_R16	0x4B
	ENV0_R16	0x4B
	ret
	

.DB     " compile",0x7,1<<COMPILE
.DW	link
compile0:
.SET link=compile0
	ret
	call	Word
	call	find
	or	r16,r16
	breq	compile2
	lds	r16,type_find
	cpi	r16,1<<NUM
	brne	compile1
	jmp	Number55
compile1:
	ld	r21,-X
	ld	r20,-X
	COMPILE20
	ret
compile2:
	call	Execute1
	ret
	ENV0_R16	0x52
	ENV0_R16	0x45
	ENV0_R16	0x53
	ENV0_R16	0x43
	ENV0_R16	0x20
	ENV0_R16	ESC
	ENV0_R16	REST
	clr	r16
	ldi	ZH,high(Send_compile)
	ldi	ZL,low(Send_compile)
	lsl	ZL
	rol	ZH
	lpm	r16,z+
	mov	r21,r16
	ENV0
compile3:
	push r16
	lpm	r21,z+
	ENV0
	dec	r16
	brne	compile3
	ret
	
.DB     "freq",0x4,1<<EXEC
.DW	link
Freq:
.SET link=Freq
	clr	r16
	sts	TCCR1B,r16
	sts	TCCR1A,r16
	sts	TCCR1C,r16	; counter raisig clock
	sts	TCNT1H,r16	; reset counter 
	sts	TCNT1L,r16
	clr	r24		;reset extention counter
	clr	r25
	ldi	r16,0x01	; interruption overflow
	sts	TIMSK1,r16
	in	r16,SREG	; sauvegarde sreg
	push	r16
	sei
	ldi	r29,0xC3
	ldi	r28,0x50		
	ldi	r16, 0x02 ;mode CTC, compare avec A
	out	TCCR0A , r16
	ldi	r16, 0x30	; pour 10us
	out	OCR0A , r16
	clr	r16 ;clear flags
	out	TIFR0 , r16
	out	TCNT0 , r16
	ldi	r16, 0x02	; start timer
	sts	TCCR0B,r16 	; autorise les interruptions
	ldi	r16,0x07	; counter raisig clock
	sts	TCCR1B,r16
	call	delay2		;pause 1 demi seconde
	cli
	lds	r16,TCNT1L
	lds	r17,TCNT1H
	st	X+,r16
	st	X+,r17
	st	X+,r24
	st	X+,r25
	pop	r16
	out	SREG,r16
	ret
	
.DB     " cli",0x3,1<<EXEC
.DW	link
Cli0:
.SET link=Cli0
	cli
	ret
.DB     " sei",0x3,1<<EXEC
.DW	link
Sei0:
.SET link=Sei0
	sei
	ret
.DB     " recurse",0x7,1<<compile
.DW	link
recurse:
.SET link=recurse
	ret
	lds	r21,(newword+1)	;nouvelle adresse du mot encours
	lds	r20,(newword)
	COMPILE20
	ret
.DB     "freq_out",0x8,1<<EXEC
.DW	link
freq_out:
.SET link=freq_out
	clr	r16	; pulse reset
	ldi	r17,8
	st	X+,r16
	st	X+,r17
	ldi	r16,0x2
	st	X+,r16
	ldi	r16,SLA_W1
	st	X+,r16
	call	FTwi_s
	ldi	r20,0x20
	ld	r3,-X
	ld	r2,-X
	ld	r1,-X
	ld	r0,-X
freq_out1:
	clr	r16	; envoi frequence
	lsr	r3
	ror	r2
	ror	r1
	ror	r0
	brcc	freq_out2
	inc	r16
freq_out2:
	st	X+,r16
	sbr	r16,2
	st	X+,r16
	cbr	r16,2
	st	X+,r16
	ldi	r16,0x3
	st	X+,r16
	ldi	r16,SLA_W1
	st	X+,r16
	call	FTwi_s
	dec	r20
	brne	freq_out2
	ldi	r20,0x08
freq_out3:
	clr	r16	; envoi _8 x 0
	ldi	r17,2
	st	X+,r16
	st	X+,r17
	ldi	r16,0x2
	st	X+,r16
	ldi	r16,SLA_W1
	st	X+,r16
	call	FTwi_s
	dec	r20
	brne	freq_out3
	clr	r16
	ldi	r17,4
	st	X+,r16
	st	X+,r17
	ldi	r16,0x2
	st	X+,r16
	ldi	r16,SLA_W1
	st	X+,r16
	call	FTwi_s
	ret
	
.DB     "i2_out",0x6,1<<EXEC
.DW	link
tout:
.SET link=tout
	ld	r17,-X
	ld	r17,-X
	ld	r18,-X
	ld	r18,-X
	lsl	r17
	st	X+,r18
	ldi	r16,0x1
	st	X+,r16
	;ldi	r16,SLA_W1
	st	X+,r17
	call	FTwi_s
	ret

.DB	"pin2",0x4,1<<EXEC
.DW	link
Pin2:
.SET link=Pin2	
	clz
	sbic	pind,2
	sez
	ret
		
.DB	"pin3",0x4,1<<EXEC
.DW	link
Pin3:
.SET link=Pin3	
	clz
	sbic	pind,3
	sez
	ret
	
.DB     " start",0x5,1<<EXEC
.DW	link
Start0:
.SET link=Start0
	call	word
	call	find
	ori	r16,0
	brne	Start1	
	st	X+,r16
	st	X+,r16
Start1:
	ldi	r17,0
	ldi	r16,0x02
	st	X+,r16
	st	X+,r17
	ldi	r17,HIGH(atstart)
	ldi	r16,LOW(atstart)
	st	X+,r16
	st	X+,r17
	call	writeep
	ret	
Start2:
	sbis	pind,2
	ret
	ldi	YH,HIGH(atstart)
	ldi	YL,LOW(atstart )
	ldi	r25,0
	ldi	r24,0x02
	st      X+,r24
	st      X+,r25
	st      X+,YL
	st      X+,YH
	call	readeep
	ld	r17,-X
	ld	r17,-X
	ld	r16,-X
	ld	r17,-X
	ori	r17,0
	breq	Start3
	push	r16
	push	r17
Start3:	
	ret
	
.DB     " restore",0x7,1<<EXEC
.DW	link
Restore:
.SET link=Restore
        cli
	ldi	r16,0x14
	ldi	YH,HIGH(copie)
	ldi	YL,LOW(copie)
	ldi	XH,HIGH(sparam)
	ldi	XL,LOW(sparam)
	
restore1:
	sbic   EECR,EEPE
	rjmp   restore1
	out	EEARH,YH
	out	EEARL,YL
	sbi	EECR,EERE
	adiw	YH:YL,1
	ldi    r19,0x80
restore11:
	dec	r19
	brne	restore11
	in	r17,EEDR
restore2:
	sbic EECR,EEPE
	rjmp restore2
restore3:
	in	r18,SPMCSR ; controle flash pas en ecriture
	sbrc	r18, SPMEN
	rjmp	restore3
	out EEDR,r17
	out	EEARH,XH
	out	EEARL,XL
	sbi EECR,EEMPE	; Write logical one to EEMPE
	sbi EECR,EEPE	; Start eeprom write by setting EEP
	adiw	XH:XL,1
	dec	r16
	brne	restore1
	jmp    Reset
.DB     "LF",0x2,1<<EXEC
.DW	link
_LF:
.SET link=_LF
        ENV0_R16    LF
        ret
.DB     "forget",0x6,1<<EXEC
.DW	link
Forget:
.SET link=Forget
	call	word
	call	find
	ori	r16,0
	brne	Forget0	
	ret	
Forget0:	
	PUSHZ
	ld	ZH,-X
	ld	ZL,-X
	cpi	ZH,high(Unforget)
	breq	Forget1
	brsh	Forget3
	rjmp	Forget2
Forget1:		
	cpi	ZL,low(Unforget)
	brsh	Forget3
Forget2:	
	POPZ	
	ret
Forget3:	
	in	r16,SREG	; sauve pour si INT valide
	push	r16
	cli
	lds	r24,(free_ram)
	lds	r25,(free_ram+1)
	adiw	r25:r24,0x20
	st	X+,r25
	st	X+,r24
	lds	r16,(free_ram)
	lds	r17,(free_ram+1)
	st	X+,r17
	st	X+,r16
	lsl	ZL
	rol	ZH
	sbiw	ZH:ZL,4
	lpm	r3,Z+	;length of word
	lpm	r5,Z+	;word type
	lpm	r0,Z+	; next word
	lpm	r1,Z+
	sbiw	ZH:ZL,4
	sub	ZL,r3
	sbci	ZH,0
	lsr	ZH
	ror	ZL
	sts	Dict,ZL
	sts	Dict+1,ZH
	sts	lastword,r0
	sts	lastword+1,r1
	st	X+,ZH
	st	X+,ZL
	st	X+,r1
	st	X+,r0
	ldi	r16,8	;ecrire nouvelles donnees dans eeprom
	st	X+,r16
	clr	r16
	st	X+,r16
	st	X+,r16		;adresse des donnees
	st	X+,r16
	call	writeep
	pop	r16	; restaure pour si INT valide
	out	SREG,r16
	POPZ	
	ret	
	rjmp	Forget2
Unforget:
end_of_dict:
.ORG	0X3E00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp	Reset
	jmp	Reset	
ecrireflash:	
	lds	r16,(etat)
	cpi	r16,compile
	breq	ecrireflash0
	ldi	r16,0x34
	ret
ecrireflash0:
	lds	ZL,(dict)
	lds	ZH,(dict+1)
	test_z
	andi	ZL,(0x100-PAGESIZE)
	lsl	ZL
	rol	ZH
	lds	YL,(DP_save)
	lds	YH,(DP_save+1)
ecrireflash1:
; Page Erase
	ldi	r16,(1<<PGERS) | (1<<SPMEN)
	call	Do_spm
; re-enable the RWW section
	ldi	r16,(1<<RWWSRE) | (1<<SPMEN)
	call	Do_spm
; transfer data from RAM to Flash page buffer
	ldi	r17,PAGESIZE	;PAGESIZE
Wrloop:
	ld	r0,Y+
	ld	r1,Y+
	ldi	r16,(1<<SPMEN)
	call	Do_spm
	adiw	ZH:ZL,2
	cp	YL,XL
	brcs	Wrloop1
	cp	YH,XH
	brcc	Wrloop2
Wrloop1:
	dec	r17
	brne	Wrloop
	push	ZL
	push	ZH
	subi	ZL,PAGESIZEB
	sbci	ZH,0
	ldi	r16,(1<<PGWRT) | (1<<SPMEN)
	call	Do_spm
	ldi	r16,(1<<RWWSRE) | (1<<SPMEN)
	call	Do_spm
	pop	ZH
	pop	ZL
	jmp	ecrireflash1
Wrloop2:
	push	ZL
	push	ZH
	mov	r16,ZL
	andi	r16,(PAGESIZEB-1)
	brne	Wrloop3
	subi	ZL,PAGESIZEB
	sbci	ZH,0
	rjmp	Wrloop4
Wrloop3:
	andi	ZL,(0x100-PAGESIZEB)
Wrloop4:
	ldi	r16,(1<<PGWRT) | (1<<SPMEN)
	call	Do_spm
	ldi	r16,(1<<RWWSRE) | (1<<SPMEN)
	call	Do_spm
	pop	ZH
	pop	ZL
	ldi	r16,0x12
	ret
Do_spm:
; check for previous SPM complete
Wait_spm:
	in	r18,SPMCSR
	sbrc	r18, SPMEN
	rjmp	Wait_spm
; check that no EEPROM write access is present
Wait_ee:
	sbic	EECR,EEPE
	rjmp	Wait_ee
; SPM timed sequence
	out	SPMCSR,r16
	spm
	ret
.NOLIST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ESEG   0
sparam:
.DW	link;last word
.DW	end_of_dict
.DW	tabram_end
.DW	tabram_end+0x20;data stack
.DW	RAMEND-0x20
.DW	link
.DW	end_of_dict
.DB	0x10	; base
.DB	0	; etat
atstart:
.DW	0	; adresse l'instruction au démarrage
.DW	0	;consigne de temperature
;;;;;;;;;;;;;;;copie
copie:
.DW	link;last word
.DW	end_of_dict
.DW	tabram_end
.DW	tabram_end+0x20;data stack
.DW	RAMEND-0x20
.DW	link
.DW	end_of_dict
.DB	0x10	; base
.DB	0	; etat
atstart_c:
.DW	0	; adresse l'instruction au démarrage
.DW	0	;consigne de temperature
eeprom_end:
.DW	eeprom_end+2
