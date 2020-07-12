/* draw.c
Auteur : Nunzio Spitaleri
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gtk/gtk.h>
#include <termios.h>
#include <fcntl.h>
#include <vte-0.0/vte/vte.h>

#include "serie.h"
#include "avrterm.h"
#include "interface.h"
#include "decodage.h"
#include "callback.h"
#include "draw.h"
#include "macro.h"


void
moveLF ()
{
  char t[] = { LF, CR };
  usleep (1000);
  vte_terminal_feed (VTE_TERMINAL (screen), t, 2);
  usleep (1000);
  col = 0;
}

void
xdraw (char tab[], int nbre)
{
  int i;
  for (i = 0; i < nbre; i++)
    draw (tab[i]);
  return;
}

void
draw (char dc)
{
  //char t[] = { LF, CR };
  vte_terminal_feed (VTE_TERMINAL (screen), &dc, 1);
  col++;
  if (col == 0x50)
    {
      moveLF ();
    }
}
