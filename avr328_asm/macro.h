.EQU NUL=0	;NULL
.EQU SOH=0x1	;Start of Heading (CC)
.EQU STX=0x2	;Start of Text
.EQU ETX=0x3	; End of Text
.EQU EOT=0x4	;End of Transmission
.EQU ENQ=0x5	;ENQ
.EQU ACK=0x6	;Acknowledge (CC)
.EQU BELL=0x7	; Bell
.EQU BS=0x8	; Backspace
.EQU HT=0x9	; horizontal tab
.EQU LF=0xA	; line feed
.EQU FF=0xC	; form feed
.EQU CR=0xD	; carriage return
.EQU XON=0x11	; transmit on
.EQU XOFF=0x13	; transmit off
.EQU NACK=0x15	; Negative Acknowledge (CC)
.EQU ADR=0x16	;envoie adresse
.EQU EOF=0x1A	; end of file
.EQU ESC=0x1B	; escape
.EQU SP=0x20	; space

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; ESCAPE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.EQU CONT=0x7	; Continue
.EQU REST=0x8	; Restitue
.EQU TAB=0x9	; Data array

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.EQU	DISPLAY= 0x41
.EQU	SEND= 0x40
.EQU	EXECUTES= 0x20
.EQU	RRAM= 0x52
.EQU	WRAM= 0x57

.EQU F_CPU=16000000

; set desired baud rate
.EQU BAUDRATE0=38400

; calculate UBRR0 value
.EQU UBRRVAL0=((F_CPU/(BAUDRATE0*16))-1)

.EQU BAUDRATE1= 200000

; calculate UBRR1 value
.EQU UBRRVAL1=((F_CPU/(2*BAUDRATE1))-1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SPI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.EQU SS=2	
.EQU MOSI=3	
.EQU MISO=4	
.EQU SCK=5	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; lcd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 5x7 
					; * dots
.EQU LCD_FUNCTION_8BIT_1LINE=0x30	; 8-bit interface, single line,
					 ; 5x7 dots
.EQU LCD_FUNCTION_8BIT_2LINES=0x38	; 8-bit interface, dual line, 5x7 
					; * dots

.EQU LCD_CLR=0			; DB0: clear display
.EQU LCD_HOME =1		; DB1: return to home position
.EQU LCD_ENTRY_MODE=2		; DB2: set entry mode
.EQU LCD_ENTRY_INC=1		; DB1: 1=increment, 0=decrement
.EQU LCD_ENTRY_SHIFT=0		; DB2: 1=display shift on
.EQU LCD_ON=3			; DB3: turn lcd/cursor on
.EQU LCD_ON_DISPLAY=2		; DB2: turn display on
.EQU LCD_ON_CURSOR=1		; DB1: turn cursor on
.EQU LCD_ON_BLINK= 0		; DB0: blinking cursor ?
.EQU LCD_MOVE=4			; DB4: move cursor/display
.EQU LCD_MOVE_DISP=3		; DB3: move display (0-> cursor) ?
.EQU LCD_MOVE_RIGHT=2		; DB2: move right (0-> left) ?
.EQU LCD_FUNCTION=5		; DB5: function set
.EQU LCD_FUNCTION_8BIT=4	; DB4: set 8BIT mode (0->4BIT mode)
.EQU LCD_FUNCTION_2LINES=3	; DB3: two lines (0->one line)
.EQU LCD_FUNCTION_10DOTS=2	; DB2: 5x10 font (0->5x7 font)
.EQU LCD_CGRAM=6		; DB6: set CG RAM address
.EQU LCD_DDRAM=7		; DB7: set DD RAM address
.EQU LCD_BUSY=7			; DB7: LCD is busy
.EQU LCD_LINES=4		;number of visible lines of the display */
.EQU LCD_DISP_LENGTH=0x14	;visibles characters per line of the display */
.EQU LCD_LINE_LENGTH=0x20	;internal line length of the display    */
.EQU LCD_START_LINE1=0x0	;DDRAM address of first char of line 1 */
.EQU LCD_START_LINE2=0x40	;DDRAM address of first char of line 2 */
.EQU LCD_START_LINE3=0x14	;DDRAM address of first char of line 3 */
.EQU LCD_START_LINE4=0x54	;DDRAM address of first char of line 4 */
.EQU LCD_WRAP_LINES=0		; no wrap, 1: wrap at end of visibile line */

.EQU	PAGESIZEB=2*PAGESIZE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TWI_lcd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.EQU	TWBRVAL=10 ; pour scl=200k avec prescaler=1
.EQU	START=0x08
.EQU	SLA_W=0x27<<1
.EQU	SLA_W1=0x26<<1
.EQU	SLA_R=(0x27<<1) + 1
.EQU	S_SLA_ACK=0x18
.EQU	R_SLA_ACK=0x40
.EQU	S_DATA_ACK=0x28
.EQU	R_DATA_ACK=0x50

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; type de mot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.EQU	NORMAL=0
.EQU	ISR=2
.EQU	EXEC= 3
.EQU	IMMED= 4
.EQU	COMPILE= 5
.EQU	NUM= 6
.EQU	DEFINE= 7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; etats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.MACRO PAUSE
	ldi	r16, 0x02 ;mode CTC, compare avec A
	out	TCCR0A , r16
	ldi	r16, 0x14 ; pour 10us
	out	OCR0A , r16
	clr	r16 ;clear flags
	out	TIFR0 , r16
	out	TCNT0 , r16
	ldi	r16, 0x02 ; start timer
	out	TCCR0B , r16
	ldi	r29,high(@0)
	ldi	r28,low(@0)
	call	Delay2
.ENDMACRO
.EQU	COMPIL= 0x20

.MACRO  REC0
REC01:
	lds	r22,UCSR0A
	sbrs	r22,RXC0
	rjmp	REC01
	lds	r22,UDR0
.ENDMACRO

.MACRO  REC0_DP
REC0_DP1:
	lds	r22,UCSR0A
	sbrs	r22,RXC0
	rjmp	REC0_DP1
	lds	r22,UDR0
	st	X+,r22
.ENDMACRO

.MACRO  ENV0
ENV01:
	lds	r23,UCSR0A
	sbrs	r23,UDRE0
	rjmp	ENV01 
	sts	UDR0,r21
.ENDMACRO

.MACRO  ENV0_R16
	ldi	r16,low(@0) 
	call	Com0_1
.ENDMACRO

.MACRO  REC1
REC11:
	lds	r22,UCSR1A
	sbrs	r22,RXC1
	rjmp	REC11
	lds	r22,UDR1
.ENDMACRO

.MACRO  REC1_DP
REC1_DP1:
	lds	r22,UCSR1A
	sbrs	r22,RXC1
	rjmp	REC1_DP1
	lds	r22,UDR1
	st	X+,r22
.ENDMACRO

.MACRO  ENV1_R16
	ldi	r16,low(@0) 
	call	Com1_1
.ENDMACRO

.MACRO LED
	call Testled
.ENDMACRO

.MACRO 	PILE
	ldi	r16,low(@0)
	st	X+,r16
	ldi	r16,high(@0)
	st	X+,r16
	call	_ram 
.ENDMACRO

.MACRO 	COMPILE20
	ldi	r16,0x0E
	st	X+,r16
	ldi	r16,0x94
	st	X+,r16
	st	X+,r20
	st	X+,r21
	adiw	ZH:ZL,0x04
.ENDMACRO

.MACRO 	test_z
	cpi	ZH,high(unforget)
	breq	t_comp3
	brcc	t_comp4
t_comp1:
	ldi	r16,0x34
	ret
t_comp3:
	cpi	ZL,low(unforget)
	breq	t_comp4
	brcs	t_comp1
t_comp4:
.ENDMACRO

.MACRO 	PUSHZ
	sts	save_z,ZL
	sts	save_z+1,ZH
.ENDMACRO
.MACRO 	POPZ
	lds	ZL,save_z
	lds	ZH,save_z+1
.ENDMACRO

.MACRO 	24NOP
	push	r16
	ldi	r16,24
Nop1:
	dec	r16
	brne	Nop1
	pop	r16
.ENDMACRO
.MACRO 	CLOCK0
	nop
	nop
	cbi	PORTD,4
	24NOP
.ENDMACRO
.MACRO 	CLOCK1
	nop
	nop
	sbi	PORTD,4
	24NOP
.ENDMACRO