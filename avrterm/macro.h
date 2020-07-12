#define NUL	0		//NULL
#define SOH	0x1		//Start of Heading (CC)
#define STX	0x2		//Start of Text
#define ETX	0x3		// End of Text
#define EOT	0x4		//End of Transmission
#define ENQ	0x5		//ENQ
#define ACK	0x6		//Acknowledge (CC)
#define BELL	0x7		// bell
#define BS	0x8		//Backspace
#define HT	0x9		// horizontal tab
#define LF	0xA		// line feed
#define FF	0xC		// form feed
#define CR	0xD		// carriage return
#define SO	0xE		// Shift out
#define SI	0xF		// Shift in
#define XON	0x11		// transmit on
#define XOFF	0x13		// transmit off
#define NACK	0x15		// Negative Acknowledge (CC)
#define SYN	0x16		//Synchronous Idle (CC)
//#define EOF   0x1A    // end of file
#define ESC	0x1B		// escape
#define SP	0x20		// space
/////////////////////////////////////////////////////////////////////
// Escape sequence
////////////////////////////////////////////////////////////////////
#define CONT	0x7		// Continue// bell
#define REST	0x8		//Restitue
#define TAB	0x9		//Array

///////////////////////////////////////////////////////////////////
#define buf_recev	0xB0	//0x50
#define wordbuf		0x100	//0x20
#define buffer		0x120	//0x50
#define buf_screen	0x170	//0x50
#define DP_START	0x1C2
#define SP_START	0x3FE

#define GENEHF	0x47
#define R_BADGE	0x42
#define FREQ	0x46
#define AFFICHE	0x41
