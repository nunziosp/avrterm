/* callback.c
Auteur : Nunzio Spitaleri
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <libgen.h>

#include <gtk/gtk.h>
#include <vte-0.0/vte/vte.h>
#include "serie.h"
#include "avrterm.h"
#include "decodage.h"
#include "interface.h"
#include "callback.h"
#include "draw.h"
#include "serie.h"
#include "macro.h"
#include "keyboard.h"



void
ecrittube (char *cc, int nbre, int echo)
{
  char t[] = { LF, CR };
  char space[] = { 0x20 };
  int i = 1, tmp;
  //tmp=write (tube2[1], &nbre,4);
  //cc[nbre] = 0;
  //  tmp=write (tube2[1], cc, nbre);
  tmp = write (port, cc, nbre);
#ifdef SHOWTUBE
  printf ("ecrittube tube2[1] %d ", nbre);
#endif
  if (echo == 1)
    {
      for (i = 0; i < nbre; i++)
	printf ("%c %X ", cc[i], cc[i]);
      printf ("\n");
      xdraw (cc, nbre);
      vte_terminal_feed (VTE_TERMINAL (screen), t, 2);
    }
  else if (echo == 2)
    {
      for (i = 0; i < nbre; i++)
	printf ("%c %X ", cc[i], cc[i]);
      printf ("\n");
      xdraw (cc, nbre);
      //vte_terminal_feed (VTE_TERMINAL (screen), space, 1);
    }
  else if (echo == 3)
    {
      for (i = 0; i < nbre; i++)
	{
	  printf ("%c %X ", cc[i], cc[i]);
	  draw (cc[i]);
	}
      draw (0x20);
      printf ("\n");
      //vte_terminal_feed (VTE_TERMINAL (screen), space, 1);
    }
}

char
littube (int essai)
{
  char cc = 0;
  int i, j = 0;

  if (flag < 0)
    flag = 0;
  if (flag == 0)
    {

      //usleep(1000);
      Lis_port (NULL, 0, 0);
      return 0;
    }
  else
    {
      cc = buf_read[0];
      for (i = 1; i < flag; i++)
	buf_read[i - 1] = buf_read[i];
      flag--;
#ifdef SHOWTUBE
      if (cc >= 0x20)
	printf ("littube tube[0] 0x%2.X %c 0x%X\n", 0xFF & cc, cc, flag);
      else
	printf ("littube tube[0] 0x%X %c 0x%X\n", 0xFF & cc, 0x7E, flag);
#endif
      return cc;
    }
}

char
lecture (int essai)
{
  char cc = 0;
  int i, j = 0;

  while (flag == 0)
    {

      //usleep(1000);
      Lis_port (NULL, 0, 0);
    }
  cc = buf_read[0];
  for (i = 1; i < flag; i++)
    buf_read[i - 1] = buf_read[i];
  flag--;
#ifdef SHOWTUBE
  printf ("littube tube[0] 0x%X %c 0x%X\n", cc, cc, flag);
#endif
  return cc;
}

void
enter_callback (GtkWidget * widget, GtkWidget * entry)
{
  char *commande;
  static char buf[MAX_ENTRY + 1];
  guint taille, tmp_pos = 0,i;
  char cc;
  char delim1 = 0x22;
  char delim2 = 0x29;
  const gchar *entree;
  entree = gtk_entry_get_text (GTK_ENTRY (entry));
  printf (" enter_callback:%s fwait=%d\n", tabword, fwait);
  if (fwait == 3)
    {
      return;
    }
  if (fwait == 2)
    {
      tmp_pos = 0;
      sprintf (buf, "%s%s", tabword, entree);
      gtk_editable_insert_text (GTK_EDITABLE (entry), tabword, -1, &tmp_pos);
      entree = gtk_entry_get_text (GTK_ENTRY (entry));
// gtk_entry_set_text (GTK_EDITABLE (entry),buf);
      //usleep (500);
      fwait = 0;
      return;
    }
  if (fwait == 1)
    {
      //  usleep (500);
      return;
    }
  // if(strlen(entree)==0)return ;
  strcpy (buf, entree);
  commande = buf;
  if ((commande == NULL) || (strlen (commande) == 0))
    return;
  if (fwait == 4)
    {
      sendword = strsep (&commande, "\"");
      taille = strlen (sendword);
      if (taille > 40)
	{
	  sprintf (buf, "%s%s", tabword, entree);
	  gtk_editable_insert_text (GTK_EDITABLE (entry), sendword, -1,
				    &tmp_pos);
	  entree = gtk_entry_get_text (GTK_ENTRY (entry));
	  return;
	}
      fwait = 0;
    }
  else
    sendword = strsep (&commande, " ");
  taille = strlen (sendword);
  if ((taille == 0) || (sendword == NULL))
    {
      if ((commande == NULL) || (strlen (commande) == 0))
	gtk_entry_set_text (GTK_ENTRY (entry), "");
      else
	gtk_entry_set_text (GTK_ENTRY(entry), commande);
      return;
    }
  /* if(sendword[0]==0x28)
     {
     sendword = strsep (&commande, &delim2);
     return;
     } */
  for(i=0;i<strlen (sendword);i++)
	  if(sendword[i]==0xA) sendword[i]=0x20;
  fwait = 1;
  tabkey[0] = STX;
  tabkey[1] = strlen (sendword);
  ecrittube (tabkey, 2, 0);
  ecrittube (sendword, strlen (sendword), echo);
  printf ("Entry contents: %s\n %s flag %d\n", entree, commande, flag);
  if ((commande == NULL) || (strlen (commande) == 0))
    gtk_entry_set_text (GTK_ENTRY (entry), "");
  else
    gtk_entry_set_text (GTK_ENTRY (entry), commande);
  // gtk_editable_set_editable(GTK_ENTRY (entry), TRUE);
  //gtk_entry_set_visibility(GTK_ENTRY (entry), TRUE);
//  gtk_widget_show (entry);
  gtk_button_set_label (GTK_BUTTON (b_again),sendword );
  return;
}

/*void
key_press_envoi (GtkWidget * widget, GdkEventKey * event, gpointer data)
{

  printf ("%X\n", event->keyval);
  if (tabkey[0] != 0)
    ecrittube (tabkey, 1, 0);
}*/

void
s_bouton1 (GtkWidget * widget, gpointer data)
{
  gtk_main_quit ();
}

void
s_bouton2 (GtkWidget * widget, gpointer data)
{
  port = openserie (rs232);
}

void
sb_flash (GtkWidget * widget, gpointer data)
{
	char *vlist="flash";
	if(fwait==0)
{

  fwait = 1;
  tabkey[0] = STX;
  tabkey[1] = strlen (vlist);
  ecrittube (tabkey, 2, 0);
  ecrittube (vlist, strlen (vlist), echo);
  printf ("Entry contents: %s\n", vlist);
}
}

void
sb_list (GtkWidget * widget, gpointer data)
{
  FILE *fp;
  int index = 0, num = 0;
  char tab[20000];
  char *tolken, *tmp;
  char *vlist = "vlist", cc;
  char *adrw = "adrw";
  tmp = tab;
  if (fwait == 1)
    {
      //  usleep (500);
      return;
    }
  if ((fp = fopen ("list.txt", "w")) == NULL)
    {
      printf ("impossible d'ouvrir list.txt\n");
      return;
    }
  tabkey[0] = STX;
  tabkey[1] = strlen (vlist);
  ecrittube (tabkey, 2, 0);
  ecrittube (vlist, strlen (vlist), 3 * echo);
  cc = lecture (100);
  while (cc != ACK)
    {
      tab[index] = cc;
      index++;
      cc = lecture (100);
    }
  tab[index++] = 0;
  tolken = strsep (&tmp, " ");
  while (tolken != NULL)
    {
      tabkey[0] = STX;
      tabkey[1] = strlen (adrw);
      ecrittube (tabkey, 2, 0);
      ecrittube (adrw, strlen (adrw), 3 * echo);
      cc = lecture (100);
      while (cc != ACK)
	{
	  cc = lecture (100);
	}
      tabkey[0] = STX;
      tabkey[1] = strlen (tolken);
      ecrittube (tabkey, 2, 0);
      ecrittube (tolken, strlen (tolken), 3 * echo);

      lecture (100);		//ignore ESC N envoyer par adrw
      lecture (100);
      adr.c[3] = 0;
      adr.c[2] = 0;
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      num++;
      // printf("%d\t%s\t%X\n",num,tolken,adr.i);
      fprintf (fp, "%d\t%s\t%X\n", num, tolken, adr.i);
      cc = lecture (100);
      while (cc != ACK)
	{
	  cc = lecture (100);
	}
      tolken = strsep (&tmp, " ");
    }
  fclose (fp);
  return;
}

void
sb_retour (GtkWidget * widget, gpointer data)
{
  tabkey[0] = 0x13;
  tabkey[1] = 0x42;
  ecrittube (tabkey, 2, 0);
  /* tabkey[0] = 0x1B;
     tabkey[1] = 0x4F;
     tabkey[2] = 0x52;
     ecrittube (tabkey, 3,0); */
}

void
sb_file (GtkWidget * widget, gpointer data)
{
  char tab[MAX_ENTRY + 1];
  FILE *fp;
  char *commande;
  static char buf[MAX_ENTRY + 1];
  guint taille, tmp_pos = 0;
  char *tolken, cc;
  char delim0 = 0x20;
  char delim1 = 0x22;
  char delim2 = 0x29;
  char *pdelim;
  int i;

  if (name == NULL)
    {
      printf ("Impossible d'ouvrir None %s\n", name);
      return;
    }
  if ((fp = fopen (name, "r")) == NULL)
    {
      printf ("Impossible d'ouvrir %s\n", name);
      return;
    }
  while ((fgets (tab, MAX_ENTRY, fp) != NULL)&&(fwait!=-1))
    {
      for (i = 0; i < strlen (tab); i++)
	{
	  if (tab[i] == 0x0A)
	    tab[strlen (tab) - 1] = 0;
	  if (tab[i] == 0x09)
	    tab[strlen (tab) - 1] = 0x20;
	}
      strcpy (buf, tab);
      commande = buf;
      tolken = commande;
      pdelim = &delim0;
      while (commande != NULL)
	{
            if (fwait==-1)
            {
	      fclose (fp);
	      return;
            }
	  if (fwait == 5)
	    {
	      tolken = strsep (&commande, ")");
	      fwait = 0;
	      continue;
	    }
	  while ((fwait == 1))
	    {
	      decode ();
            if (fwait==-1)
            {
	      fclose (fp);
                return ;
            }
	      //usleep (100);
	      if (fwait == 4)
		pdelim = &delim1;
	      else
		pdelim = &delim0;
	    }
	  if (fwait == 2)
	    {
	      fclose (fp);
	      return;
	    }

	  printf ("commande : %s fwait %d\n", commande, fwait);
	  if (fwait == 4)
	    {

	      tolken = strsep (&commande, "\"");
	      printf ("tolken2 : %s  taille : %d\n", tolken, strlen (tolken));
	      if (strlen (tolken) == 0)
		continue;

	    }
	  else
	    tolken = strsep (&commande, " ");
	  taille = strlen (tolken);
	   if (tolken[0] == 0x23)
	    {
	  commande == NULL;
	      break;
	}
	  if ((tolken == NULL) || (taille == 0))
	    continue;
	  if ((tolken[0] == 0x28) /*&& (taille == 1)*/)
	    {
                if (tolken[strlen(tolken)-1]!= 0x29)
	      fwait = 5;
	      continue;
	    }
	  printf ("tolken : %s  taille : %d\n", tolken, taille);
	  taille = strlen (tolken);
	  fwait = 1;
	  tabkey[0] = STX;
	  tabkey[1] = strlen (tolken);
	  ecrittube (tabkey, 2, 0);
	  ecrittube (tolken, strlen (tolken), 2);
	}
    }
  fclose (fp);
	  fwait = 0;
}

void
open_file (char *filename)
{
  if (name != NULL)
    free (name);
  name = (char *) malloc (strlen (filename) + 1);
  strcpy (name, filename);
  printf ("name : %s\n", name);
  return;
}

void
sb_chooser (GtkWidget * widget, gpointer data)
{
  b_chooser = gtk_file_chooser_dialog_new ("Chooser Avrterm", window,GTK_FILE_CHOOSER_ACTION_OPEN,
                                           GTK_STOCK_CANCEL,GTK_RESPONSE_CANCEL,GTK_STOCK_OPEN
                                           , GTK_RESPONSE_ACCEPT, NULL);
  if (gtk_dialog_run (GTK_DIALOG (b_chooser)) == GTK_RESPONSE_ACCEPT)
    {
      char *filename;
      filename = gtk_file_chooser_get_filename (GTK_FILE_CHOOSER (b_chooser));
      open_file (filename);
gtk_button_set_label (GTK_BUTTON (b_file), basename (filename));
      g_free (filename);
    }
  gtk_widget_destroy (b_chooser);
}

void
s_combo1 (GtkWidget * widget, gpointer data)
{
  // rs232->name=(char *)gtk_entry_get_text (GTK_ENTRY (GTK_COMBO (combo1)->entry));
}

void
s_combo2 (GtkWidget * widget, gpointer data)
{
  int speed;
  rs232->vitesse=atoi(gtk_entry_get_text (GTK_ENTRY (GTK_COMBO (combo2)->entry)));
}

void
s_combo3 (GtkWidget * widget, gpointer data)
{
  rs232->nbre_bits=atoi(gtk_entry_get_text (GTK_ENTRY (GTK_COMBO (combo3)->entry)));  
}

void
s_combo4 (GtkWidget * widget, gpointer data)
{
  char *tmp;
/*	tmp=(char *)gtk_entry_get_text (GTK_ENTRY (GTK_COMBO (combo4)->entry)); 
	if(strcmp(tmp,"None")==0)
  rs232->parite=0;
	if(strcmp(tmp,"Even")==0)
  rs232->parite=2;
	if(strcmp(tmp,"Odd")==0)
  rs232->parite=1;
  printf("parité=%d\n",rs232->parite);*/
}

void
s_combo5 (GtkWidget * widget, gpointer data)
{
  //rs232->bit_stop=atoi(gtk_entry_get_text (GTK_ENTRY (GTK_COMBO (combo5)->entry))); 

}

void
sb_again (GtkWidget * widget, gpointer data)
{
	if(fwait==0)
{

  fwait = 1;
  tabkey[0] = STX;
  tabkey[1] = strlen (sendword);
  ecrittube (tabkey, 2, 0);
  ecrittube (sendword, strlen (sendword), echo);
  printf ("Entry contents: %s\n", sendword);
}
}

void
sb_echo (GtkWidget * widget, gpointer data)
{
  if (echo == 1)
    echo = 0;
  else
    echo = 1;
}

void
sb_debug (GtkWidget * widget, gpointer data)
{
	char *vlist="debug";
	if(fwait==0)
{

  fwait = 1;
  tabkey[0] = STX;
  tabkey[1] = strlen (vlist);
  ecrittube (tabkey, 2, 0);
  ecrittube (vlist, strlen (vlist), echo);
  printf ("Entry contents: %s\n", vlist);
}
  
}

void
sb_dp (GtkWidget * widget, gpointer data)
{
	char *vlist="dp";
	if(fwait==0)
{

  fwait = 1;
  tabkey[0] = STX;
  tabkey[1] = strlen (vlist);
  ecrittube (tabkey, 2, 0);
  ecrittube (vlist, strlen (vlist), echo);
  printf ("Entry contents: %s\n", vlist);
}
}

void
sb_vlist (GtkWidget * widget, gpointer data)
{
	char *vlist="vlist";
	if(fwait==0)
{

  fwait = 1;
  tabkey[0] = STX;
  tabkey[1] = strlen (vlist);
  ecrittube (tabkey, 2, 0);
  ecrittube (vlist, strlen (vlist), echo);
  printf ("Entry contents: %s\n", vlist);
}
}
void
sb_reset (GtkWidget * widget, gpointer data)
{
	char *vlist1="00";
	char *vlist2="execute";

  tcflush(port, TCOFLUSH);  
  tcflush(port, TCIFLUSH);
usleep(5000) ;
  tabkey[0] = ESC;
  tabkey[1] = NACK;
  ecrittube (tabkey, 2, 0);
  printf ("Envoie de SOH fwait %d\n",fwait);
 
  fwait=0 ;
 
}
