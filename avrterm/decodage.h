/*decodage.h
Auteur : Nunzio Spitaleri
*/
#ifndef	DECODE_H
#define	DECODE_H
int decode ();
volatile int fwait;
volatile int fwait_save;
 char tabword[22];
union var
{
  unsigned int i;
  unsigned char c[4];
};
union var vtab, adr;
#endif

void escape ();
struct timespec t_start, t_stop ;
long lsec,lusec ;