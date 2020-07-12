/*decodage.c
Auteur : Nunzio Spitaleri
*/

#include <stdio.h>
#include <string.h>
#include <gtk/gtk.h>
#include <time.h>

#include "serie.h"
#include "avrterm.h"
#include "decodage.h"
#include "interface.h"
#include "callback.h"
#include "draw.h"
#include "macro.h"
unsigned char cc;
void
hex (char c)
{
  int tmp;
  tmp = (c >> 4) & 0x0F;
  if (tmp > 0x09)
    tmp += 0x37;
  else
    tmp += 0x30;
  draw (tmp);
  tmp = (c & 0x0F);
  if (tmp > 0x09)
    tmp += 0x37;
  else
    tmp += 0x30;
  draw (tmp);
}

int
decode ()
{
  int j = 0, i, count, tmp;
  unsigned char tmptab[0x10];
  adr.i = 0;
  cc = littube (100);
  if (cc > 0)
    {
//printf ("decode char 0x%X\n", cc);
// printf ("decode nbre 0x%X\n", cc);
      switch (cc)
	{
	case 0:
	  return 0;
	  break;
	case 1:
	  //caseSOH
	  break;
	case 2:
	  //caseSTX
	  break;
	case 3:
	  //caseSTX
	  break;
	case 4:
	  //caseEOT
	  break;
	case 5:
	  //caseENQ
	  break;
	case ACK:		// 0x07
	  //caseCONTINUE
	  draw (0x20);
	  if (fwait != 2)
	    fwait = 0;		//permet l'envoie
	  break;
	case LF:
	  //caseLF
	  moveLF ();
	  break;
	case 0xB:
	  //caseVT
	  if (row > 0)
	    row--;
	  break;
	case 0xC:
	  //caseFF
	  break;
	case 0xD:
	  //caseCR
	  break;
	case 0xE:
	  //caseShift_Out
	  break;
	case 0xF:
	  //caseShift_In
	  break;
	case 0x10:
	  //case10
	  break;
	case 0x11:;
	  break;
	case 0x12:
	  //caseREP
	  break;
	case 0x13:
	  //caseSEP
	  break;
	case 0x14:
	  break;
	case NACK:
	  //caseNACK
	  break;
	case 0x16:
	  adr.i = 0;
	  break;
	case 0x17:
	  //case17
	  break;
	case 0x18:
	  //Efface ligne CAN
	  break;
	case 0x19:
	  //caseSS2
	  break;
	case 0x1A:
	  //caseSUB
	  break;
	case ESC:		//0x1B

	  escape ();
	  break;
	case 0x1C:
	  //case1C
	  break;
	case 0x1D:
	  //caseSS3
	  break;
	case 0x1E:
	  row = col = 0;
	  //caseRS debut d'ecran
	  break;
	case 0x1F:
	  break;
	default:
	  draw (cc);
	  j = 1;
	  break;
	}
    }
  return 1;
}

void
escape ()
{
  const char *erreur_name = "\nErreur le nom contient un caratere\n\
non autoriser.\n retaper le est appuye sur fwait\n";

  int n;
  unsigned tabd[10];
  int j = 0, i, count, tmp;
  unsigned char tmptab[0x10];
  int taille=0x200; 
  unsigned char itmptab[taille];
  cc = lecture (100);
  switch (cc)
    {
    case 0x22:			// "
      fwait = 4;
      printf ("decode  fwait=%d\n", fwait);
      break;
    case 0x4E:			//number N
      adr.c[3] = 0;
      adr.c[2] = 0;
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      hex (adr.c[1]);
      hex (adr.c[0]);
      draw (0x20);
      printf ("nombre %d\n", adr.i);
      //caseSOH
      break;
    case 0x44:			//number D affichage en decimal
      adr.c[3] = lecture (100);
      adr.c[2] = lecture (100);
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      n = adr.i;
      for (i = 9; i >= 0; i--)
	{

	  tabd[i] = n % 10 + 0x30;
	  n = n / 10;
	}
      for (i = 0; i < 10; i++)
	draw (tabd[i]);
      draw (0x20);
      printf ("nombre %d\n", adr.i);
      break;
    case 0x64:			//number d affichage en decimal
      adr.c[3] = 0;
      adr.c[2] = 0;
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      n = adr.i;
      for (i = 4; i >= 0; i--)
	{

	  tabd[i] = n % 10 + 0x30;
	  n = n / 10;
	}
      for (i = 0; i < 5; i++)
	draw (tabd[i]);
      draw (0x20);
      printf ("nombre %d\n", adr.i);
      break;
    case 0x48:			//number H affichage en hexadecimal
      adr.c[3] = lecture (100);
      adr.c[2] = lecture (100);
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      hex (adr.c[3]);
      hex (adr.c[2]);
      hex (adr.c[1]);
      hex (adr.c[0]);
      break;
    case 0x68:			//number h affichage en hexadecimal
      adr.c[3] = 0;
      adr.c[2] = 0;
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      hex (adr.c[1]);
      hex (adr.c[0]);
      break;
    case 0x42:			//number B affichage en binaire
      adr.c[3] = lecture (100);
      adr.c[2] = lecture (100);
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      n = adr.i;
      for (i = 31; i >= 0; i--)
	{
	  printf ("%d", (n >> i) & 1);
	  printf ("\n");
	  draw (((n >> i) & 1) + 0x30);
	}
      //caseSTX
      break;
    case 0x62:			//number b affichage en binaire
      adr.c[3] = 0;
      adr.c[2] = 0;
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      n = adr.i;
      for (i = 15; i >= 0; i--)
	{
	  printf ("%d", (n >> i) & 1);
	  draw (((n >> i) & 1) + 0x30);
	}
      printf ("\n");
      //caseSTX
      break;
    case REST:			// 0x08
      //caseRestitue     
      count = lecture (100);
      for (i = 0; i < count; i++)
	{
	  cc = 0;
	  cc = lecture (100);
	  tabword[i] = cc;
	}
      tabword[i] = 0x20;
      tabword[i + 1] = 0x0;
      fwait = -1;		//flag restitue
      printf ("decode restitue :%s fwait=%d\n", tabword, fwait);
      //restitue(tab, count+1, 0);
      break;
    case TAB:			// 0x09
      moveLF ();
      adr.c[2] = lecture (100);
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      adr.c[3] = 0;
      vtab.i = 0;
      vtab.c[1] = lecture (100);
      vtab.c[0] = lecture (100);
      printf ("adresse : %X  qte : %X\n", adr.i,vtab.i);
      for (i = 0; i < vtab.i; i++)
	{
	  if ((i & 0x0F) == 0)
	    {
	      hex (adr.c[2]);
	      hex (adr.c[1]);
	      hex (adr.c[0]);
	      draw (0x2D);
	      tmp = adr.i;
	      adr.i = adr.i >> 1;
	      hex (adr.c[2]);
	      hex (adr.c[1]);
	      hex (adr.c[0]);
	      adr.i = tmp;
	      draw (0x20);
	      adr.i += 0x10;
	    }
	  cc = lecture (100);
	  hex (cc);
	  draw (0x20);
	  if (cc < 0x20)
	    cc = 0x20;
	  tmptab[i & 0x0F] = cc;
	  if ((i & 0x0F) == 0xF)
	    {
	      for (j = 0; j < 0x10; j++)
		draw (tmptab[j]);

	      moveLF ();
	    }
	  else if ((i & 0x0F) == 0x7)
	    draw (0x20);
	}
      fwait = 0;		//permet l'envoie
      break;
    case 0x54:      // T start chrono
clock_gettime(CLOCK_REALTIME,&t_start );
      break;
    case 0x74: 		// t stop chrono
clock_gettime(CLOCK_REALTIME,&t_stop );
	lusec=(t_stop.tv_nsec - t_start.tv_nsec)/1000000;
	lsec=(t_stop.tv_sec - t_start.tv_sec)*1000 ;
	printf( "time : %ld ms\n",lusec+lsec);
	
      break;
    case 0x6F:
      adr.c[3] = 0;	//number 1 octet affichage en hexadecimal
      adr.c[2] = 0;
      adr.c[1] = 0;
      adr.c[0] = lecture (100);
      hex (adr.c[0]);
      break;
    case 0x70:			// 0x09
      moveLF ();
      adr.c[2] = lecture (100);
      adr.c[1] = lecture (100);
      adr.c[0] = lecture (100);
      adr.c[3] = 0;
      vtab.i = 0;
      vtab.c[1] = lecture (100);
      vtab.c[0] = lecture (100);
      printf ("adresse : %X  qte : %X\n", adr.i,vtab.i);
      for (i = vtab.i ; i >0 ; i--)
	{
            itmptab[i-1]=lecture (100);
	    }
      for (i = 0; i < vtab.i; i++)
	{
	  if ((i & 0x0F) == 0)
	    {
	      hex (adr.c[2]);
	      hex (adr.c[1]);
	      hex (adr.c[0]);
	      draw (0x2D);
	      tmp = adr.i;
	      adr.i = adr.i >> 1;
	      hex (adr.c[2]);
	      hex (adr.c[1]);
	      hex (adr.c[0]);
	      adr.i = tmp;
	      draw (0x20);
	      adr.i += 0x10;
	    }
	  cc = itmptab[i];
	  hex (cc);
	  draw (0x20);
	  if (cc < 0x20)
	    cc = 0x20;
	  tmptab[i & 0x0F] = cc;
	  if ((i & 0x0F) == 0xF)
	    {
	      for (j = 0; j < 0x10; j++)
		draw (tmptab[j]);

	      moveLF ();
	    }
	  else if ((i & 0x0F) == 0x7)
	    draw (0x20);
	}
      fwait = 0;		//permet l'envoie
      break;
    case 3:
      //caseENQ
      break;
    case 4:
      //caseEOT
      break;
    case 5:
      //caseENQ
      break;
    default:
      break;
    }
  return ;
}
