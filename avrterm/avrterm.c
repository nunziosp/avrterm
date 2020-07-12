/* avrterm.c
Auteur : Nunzio Spitaleri
*/

#include <unistd.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>

#include "avrterm.h"
#include "callback.h"
#include "interface.h"
#include "draw.h"
#include "serie.h"
#include "decodage.h"


int
main (int argv, char **argc)
{
	char vlist[]=" vlist";
	sendword=vlist;
  flag = 0;
  eflag = 0;
  row = 0;
  col = 0;;
  port = -1;
  rs232 = (scom) malloc (sizeof (struct _scom));
  buf_read = (char *) malloc (BUFFER_RECEPTION);
  name = NULL;
  gtk_init (&argv, &argc);
  ncols = COLONNE;
  nrows = RANGEE;
  row = col = 0;
  fwait = 0;
  echo = 1;
  rs232->name = argc[1];
  rs232->vitesse = 38400;
  rs232->nbre_bits = 8;
  rs232->parite = 0;
  rs232->bit_stop = 1;

  /* Initialisation de GTK+ */
  port = openserie (rs232);
  window = fenetre ();
  g_signal_connect (GTK_OBJECT (window), "destroy",
		    G_CALLBACK (gtk_main_quit), NULL);
  gtk_widget_show (window);
  g_timeout_add (1, (GSourceFunc) decode, NULL);
  gtk_main ();
  close (port);
  free (buf_read);
  free (rs232);
  //openserie (argv[1]);
  return 0;
}
