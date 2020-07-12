/* avrterm.h
Auteur : Nunzio Spitaleri
*/

#define RANGEE 24
#define COLONNE 0x40
#define STAILLE 960
#define SHOWTUBE
#undef SHOWTUBE

volatile long row, col;
volatile long nrows, ncols;
char tabkey[257];
char tmptabkey[257];
volatile int eflag;
