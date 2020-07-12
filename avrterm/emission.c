/* emission.c
Auteur : Nunzio Spitaleri
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include "serie.h"
#include "avrterm.h"
#include "decodage.h"
#include "reception.h"
#include "emission.h"
#include "draw.h"

void
emission ()
{
  int tmp = 0, nbre = 0;
  //SNDRAW(buf_write,nbre);
  tmp = read (tube2[0], &nbre, 4);
  if ((tmp <= 0) || (nbre == 0))
    return;
  tmp = read (tube2[0], buf_write, nbre);
  buf_write[nbre] = 0;
#ifdef SHOWTUBE
  if (tmp >= 0)
    printf ("emission lit tube2[0] %s tmp %d nbre %d\n", buf_write, tmp,
	    nbre);
#endif
  if (tmp >= 0)
    {
      tmp = write (port, buf_write, nbre);
#ifdef SHOWTUBE
      if (tmp >= 0)
	printf ("emission ecrit usb %s\n", buf_write);
#endif
    }
}
