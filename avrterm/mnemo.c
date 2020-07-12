/*
  * mnemo.c
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

int mnemo0(int data,mnemo encours)
{
	int data1,rr,rd;
	char ctmp[0x20];
	rd=((data & 0xF000)>>12)+((data & 0x0001)<<4);
	rr=((data & 0x0F00)>>8)+((data & 0x0002)<<3);
	data1=data & 0x00FC;
	      switch (data1)
		{
		case 0x0000:
	data1=data & 0x0003;
	      switch (data1)
		{
		      case 0x0001:
			      rr=(rr&0x0F)<<1;
			      rd=(rd&0x0F)<<1;
	sprintf(ctmp,"\tmovw\tr%d:r%d,r%d:r%d",rd+1,rd,rr+1,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;	
		      case 0x0002:
			      rr=(rr&0x0F)+16;
			      rd=(rd&0x0F)+16;
	sprintf(ctmp,"\tmuls\tr%d,r%d",rd,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;	
		      case 0x0003:
			      rr=(rr&0x07)+16;
			      rd=(rd&0x07)+16;
			      data1=0x8800;
	      switch (data1)
		{
		
		      case 0x0000:
	sprintf(ctmp,"\tmulsu\tr%d,r%d",rd,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;	
		      case 0x0800:
	sprintf(ctmp,"\tfmul\tr%d,r%d",rd,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;	
		      case 0x8000:
	sprintf(ctmp,"\tfmuls\tr%d,r%d",rd,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;	
		      case 0x8800:
	sprintf(ctmp,"\tfmulsu\tr%d,r%d",rd,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;	
		}
		  break;	
		}
		  break;	
		case 0x0004:	//cpc
	sprintf(ctmp,"\tcpc\tr%d,r%d",rd,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;	
		case 0x000C:	//lsl adc
if(rr==rd)
{
	sprintf(ctmp,"\tlsl\tr%d",rd);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		}
	else
{
	sprintf(ctmp,"\tadd\tr%d,r%d",rd,rr);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		}
		  break;
		}
	
	
}
int mnemo10(int data,mnemo fiche)
{
	
	
}
int mnemo20(int data,mnemo fiche)
{
	
	
}
int mnemo40(int data,mnemo fiche)
{

}
