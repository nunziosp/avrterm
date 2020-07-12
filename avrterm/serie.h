/* serie.h
Auteur : Nunzio Spitaleri
*/
#ifndef SERIE_H
#define SERIE_H
#include <termios.h>
#include <unistd.h>
#define BUFFER_RECEPTION 20
#define POLL_DELAY 100
int port;
struct _scom
{
  char *name;
  unsigned int vitesse;
  unsigned int nbre_bits;
  unsigned int parite;
  unsigned int bit_stop;
};
typedef struct _scom *scom;
scom rs232;

void Lis_port (int *, int, int);
int openserie (scom);
void b_speed (struct termios *, int);
void b_size (struct termios *, int);
void closeserie ();
char car;
char *buf_read;
volatile int flag;
#endif
