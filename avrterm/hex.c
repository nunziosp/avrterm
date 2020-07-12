 /*
  * hex.c
  *
  *Auteur Nunzio Spitaleri
  *  
  */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "macro.h"
#include "hex.h"
#include "mnemo.h"
#include "desas.h"


inline void
conv (char *buf)
{
  if (buf[0] > 0x39)
    buf[0] -= 0x37;
  else
    buf[0] -= 0x30;
  buf[0] = buf[0] << 4;
  if (buf[1] > 0x39)
    buf[1] -= 0x37;
  else
    buf[1] -= 0x30;
  buf[0] += buf[1];
}


tligne
readhex (char *name)
{
  char data[0x10];
  FILE *fp;
  struct _tligne *tableau;
  int i;
  int toggle = 0;
  int ligne = 0;
  char sep = 0x3A, buf[0x81];
  unsigned char nbre, type, check, tcheck;
  adr.full = 0;
  if ((fp = fopen (name, "r")) == NULL)
    {
      printf ("Erreur d'ouverture d(e %s\n", name);
      exit (1);
    }
  while (fgets (buf, 0x80, fp) != NULL)
    {
      ligne++;
    }
  tableau = (tligne) malloc (sizeof (struct _tligne));
  tableau->tdata = (tdata) malloc (sizeof (struct _tdata) * ligne);

  tableau->nbre = ligne;
  tableau->adr.full = 0;
  tableau->type = 10;
  rewind (fp);
  ligne = 0;
  while (fgets (buf, 0x80, fp) != NULL)
    {
      //tableau->tdata[ligne]=(struct _tligne *)malloc(sizeof(struct _tligne));
      adr.full &= 0xFFFF0000;
      // if (toggle==1)adr = 0xFFFF0000 & adr;
      // else adr=0;
      check = 0;
      conv (&buf[1]);
      check -= buf[1];
      tableau->tdata[ligne].nbre = nbre = buf[1] & 0xFF;
      tableau->tdata[ligne].adr.full = adr.full;
      conv (&buf[3]);
      check -= buf[3];
      tableau->tdata[ligne].adr.part[1] = buf[3];
      conv (&buf[5]);
      check -= buf[5];
      tableau->tdata[ligne].adr.part[0] = buf[5];
      conv (&buf[7]);
      check -= buf[7];
      tableau->tdata[ligne].type = type = buf[7] & 0xFF;
#ifdef DEBUG
      printf ("Nbre %02X adr %.8X type %02X ligne %d\n", nbre, adr.full, type,
	      ligne);
#endif
      switch (type)
	{
	case 0:
	  tableau->tdata[ligne].data =
	    (unsigned char *) malloc (sizeof (unsigned char) * nbre);
	  printf ("%06X--", adr.full & 0xFFFFFF);
	  for (i = 0; i < nbre; i++)
	    {
	      conv (&buf[9 + 2 * i]);
	      check -= buf[9 + 2 * i];
	      tableau->tdata[ligne].data[i] = buf[9 + 2 * i];
	      printf (" %02X", buf[9 + 2 * i] & 0xFF);
	    }
	  conv (&buf[9 + 2 * i]);	//lire check
	  tcheck = buf[9 + 2 * i];	//lire check
	  printf ("\n");
	  break;
	case 1:
	  break;
	case 2:
	  conv (&buf[9]);
	  check -= buf[9];
	  tableau->tdata[ligne].adr.part[3] = buf[9];
	  conv (&buf[11]);
	  check -= buf[11];
	  tableau->tdata[ligne].adr.part[2] = buf[11];
	  conv (&buf[13]);
	  tcheck = buf[13];	//lire check
	  printf ("adr %06X\n", adr.full);
	  break;
	case 3:
	  break;
	case 4:
	  conv (&buf[9]);
	  check -= buf[9];
	  tableau->tdata[ligne].adr.part[3] = buf[9];
	  conv (&buf[11]);
	  check -= buf[11];
	  tableau->tdata[ligne].adr.part[2] = buf[11];
	  conv (&buf[13]);
	  tcheck = buf[13];	//lire check
	  printf ("adr %06X\n", adr.full);
	  break;
	default:
	  break;
	}
      if (check != tcheck)
	{
	  printf ("erreur ligne %d check %02X buf[9+i] %02X\n", ligne, check,
		  tcheck);
	  fclose (fp);
	  exit (1);
	}

      ligne++;
    }
  fclose (fp);
  return tableau;
}

int
main (int argv, char **argc)
{
	tligne tfiche;
	mnemo fiche;
	char *org="Org ";
  tfiche=readhex (argc[1]);
  fiche=(mnemo)malloc(sizeof(struct _mdata));
  fiche->data=(char *) malloc(strlen(org)+1);
  strcpy( fiche->data,org);
  fiche->ordre=0;
  fiche->prev=NULL;
  fiche->next=NULL;
  passone(fiche,tfiche);
  
  return 0;
}
