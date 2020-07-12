/* reception.c
Auteur : Nunzio Spitaleri
*/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <gtk/gtk.h>

#include "serie.h"
#include "avrterm.h"
#include "interface.h"
#include "decodage.h"
#include "reception.h"
#include "emission.h"
#include "draw.h"

void
reception ()
{
  int tmp = 0;
  while (tmp >= 0)
    tmp = read (port, buf_read, 1);
  if (tmp >= 0)
    {
#ifdef SHOWTUBE
      printf ("reception lit usb %s\n", buf_read);
#endif
      xdraw (buf_read, tmp);
      //RNDRAW(cc,nbre);
      // tmp =  write (tube[1], &cc, 1);
#ifdef SHOWTUBE
      if (tmp >= 0)
	printf ("reception ecrit tube[1] %s\n", buf_read);
#endif
      //  write (fdd, &cc, 1);
    }
}
