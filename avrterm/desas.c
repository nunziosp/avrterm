/*
  desas.c
  Auteur: Nunzio Spitaleri
  */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "macro.h"
#include "hex.h"
#include "mnemo.h"
#include "desas.h"

int readdata(tligne tab,int *nbre,int *pos)
{
 int data;
	  data = tab->tdata[*nbre].data[*pos];
      *pos++;
      if(*pos>=tab->tdata[*nbre].nbre)
    {
      *pos=0;
      *nbre++;
}

  return data;
}
int
passone (mnemo fiche,tligne tab)
{
  int nbre = 0,pos=0;
 
  int data, data1;
	char ctmp[0x20];
	int k,rr,rd,adresse,nb;
	int maxpos=0;
  mnemo encours;
  union _adr adr;
  adr.full = tab->adr.full;
  while (nbre < tab->nbre)
    {
      maxpos = tab->tdata[nbre].nbre;
      encours=(mnemo)malloc(sizeof(struct _mdata));
  encours->ordre=pos;
  encours->prev=fiche;
  encours->next=NULL;
  fiche->next=encours;
  encours->adr.full=tab->adr.full;
	  data = readdata( tab, &nbre, &pos);
	rd=((data & 0xF000)>>12)+((data & 0x0001)<<4);
	rr=((data & 0x0F00)>>8)+((data & 0x0002)<<3);
	  switch (data)
	    {
	    case 0x0000:	//nop
	sprintf(ctmp,"\tnop");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x9895:	//break
	sprintf(ctmp,"\tbreak");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x8894:	//clc
	sprintf(ctmp,"\tclc");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xD894:	//clh
	sprintf(ctmp,"\tclh");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xF894:	//cli
	sprintf(ctmp,"\tcli");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xA894:	//cln
	sprintf(ctmp,"\tcln");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xC894:	//cls
	sprintf(ctmp,"\tcls");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xE894:	//clt
	sprintf(ctmp,"\tclt");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xB894:	//clv
	sprintf(ctmp,"\tclv");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x9894:	//clz
	sprintf(ctmp,"\tclz");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x1995:	//eicall
	sprintf(ctmp,"\teicall");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x1994:	//eijmp
	sprintf(ctmp,"\teijmp");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x0895:	//ret
	sprintf(ctmp,"\tret");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x8895:	//sleep
	sprintf(ctmp,"\tsleep");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x0894:	//sec
	sprintf(ctmp,"\tsec");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x1894:	//sez
	sprintf(ctmp,"\tsez");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x2894:	//sen
	sprintf(ctmp,"\tsen");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x3894:	//sev
	sprintf(ctmp,"\tsev");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x4894:	//ses
	sprintf(ctmp,"\tses");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x5894:	//seh
	sprintf(ctmp,"\tseh");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x6894:	//set
	sprintf(ctmp,"\tset");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x7894:	//sei
	sprintf(ctmp,"\tsei");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x1895:	//reti
	sprintf(ctmp,"\treti");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x0995:	//icall
	sprintf(ctmp,"\ticall");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xA995:	//wdr
	sprintf(ctmp,"\twdr");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0x0994:	//ijmp
	sprintf(ctmp,"\tijmp");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xE895:	//spm
	sprintf(ctmp,"\tspm");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xF895:	//spm
	sprintf(ctmp,"\tspm");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;
	    case 0xC895:	//lpm
	sprintf(ctmp,"\tlpm");
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
	      break;

	    default:
	      data1 = data & 0x00F0;
	      switch (data1)
		{
		case 0x0000:	//add,cpc,fmul,fmuls,fmulsu,lsl,movw,muls,mulsu,sbc
			mnemo0(data,encours);
		  break;
		case 0x0010:	//cp,cpse,rol,sub,adc
			mnemo10(data,encours);
		  break;
		case 0x0020:	//and,clr,eor,mov,or,tst
			mnemo20(data,encours);
		  break;
		case 0x0030:	//cpi
rd=rd&0x0F+16;
k=((0x000F&data)<<4)+((0x0F00&data)>>8);
	sprintf(ctmp,"\tcpi\tr%d,0x%X",rd,k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x0040:	//sbci2
rd=rd&0x0F+16;
k=((0x000F&data)<<4)+((0x0F00&data)>>8);
	sprintf(ctmp,"\tsbci\tr%d,0x%X",rd,k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x0050:	//subi
rd=rd&0x0F+16;
k=((0x000F&data)<<4)+((0x0F00&data)>>8);
	sprintf(ctmp,"\tsubi\tr%d,0x%X",rd,k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
			mnemo40(data,encours);
		  break;
		case 0x0060:	//ori,sbr
rd=rd&0x0F+16;
k=((0x000F&data)<<4)+((0x0F00&data)>>8);
	sprintf(ctmp,"\tori\tr%d,0x%X",rd,k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x0070:	//andi,cbr
rd=rd&0x0F+16;
k=((0x000F&data)<<4)+((0x0F00&data)>>8);
	sprintf(ctmp,"\tandi\tr%d,0x%X",rd,k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x0080:	//ldy,ldyq,ldz,ldzq,sty,styq,stz,stzq
			mnemo40(data,encours);
		  break;
		case 0x0090:
		  data1 = data & 0x000E;
		  switch (data1)
		    {
		    case 0x0000:	//ldx,ldy+-,ldz+-,lds,lpm,pop,elpm,
		      break;
		    case 0x0002:	//lac,las,lat,push,stx,sty+-,stz+-,sts,xch
		      break;
		    case 0x0004:	//asr,bclr,bset,call,com,dec,des,inc,jmp,
//lsr,neg,ror,swap,elpm,lpm
		      break;
		    case 0x0006:	//sbiw,adiw,
	rd=((data & 0x3000)>>12)+24;
	k=((data & 0x0F00)>>8)+((data & 0xC000)>>10);
		  if(data1==1)
	sprintf(ctmp,"\tsbiw\tr%d:r%d,0x%X",rd+1,rd,k);
			  else
	sprintf(ctmp,"\tadiw\tr%d:r%d,0x%X",rd+1,rd,k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		      break;
		    case 0x0008:	//sbic,cbi,
	adresse=((data & 0xF800)>>11);
	nb=((data & 0x0700)>>8);
		  if(data1==1)
	sprintf(ctmp,"\tsbic\t0x%X,%d",adresse,nb);
			  else
	sprintf(ctmp,"\tcbi\t0x%X,%d",adresse,nb);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		      break;
		    case 0x000A:	//sbis,sbi,
		  data1 = data & 0x0008;
	adresse=((data & 0xF800)>>11);
	nb=((data & 0x0700)>>8);
		  if(data1==1)
	sprintf(ctmp,"\tsbis\t0x%X,%d",adresse,nb);
			  else
	sprintf(ctmp,"\tsbi\t0x%X,%d",adresse,nb);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		      break;
		    case 0x000C:	//mul,
		      break;
		    case 0x000E:	//mul,
		      break;
		    }
		  break;
		case 0x00A0:	//ldyq,lds,styq,stzq,sts
			mnemo40(data,encours);
		  break;
		case 0x00B0:	//in,out
		  data1 = data & 0x0008;
	adresse=((data & 0x0F00)>>8)+((data & 0x0006)<<3);
		  if(data1==1)
	sprintf(ctmp,"\tout\tr%d,0x%X",rd,adresse);
			  else
	sprintf(ctmp,"\tin\t0x%X,r%d",adresse,rd);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x00C0:	//rjmp
k=((0x000F&data)<<8)+((0xFF00&data)>>8);
if(k>0x7FF)
	encours->jmp_adr= encours->adr.full-(k&0x7FF)+1;
else
		encours->jmp_adr= encours->adr.full+(k&0x7FF)+1;
	sprintf(ctmp,"\rjmp\t0x%X",k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x00D0:	//rcall
k=((0x000F&data)<<8)+((0xFF00&data)>>8);
if(k>0x7FF)
	encours->jmp_adr= encours->adr.full-(k&0x7FF)+1;
else
		encours->jmp_adr= encours->adr.full+(k&0x7FF)+1;
	sprintf(ctmp,"\rcall\t0x%X",k);
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x00E0:	//ldi,ser
k=((0x000F&data)<<4)+((0x0F00&data)>>8);
rd= (rd&0x0F)+16;
if(k>0xFF)
{
	sprintf(ctmp,"\tser\tr%d",rd);
}
else
{
	sprintf(ctmp,"\tldi\tr%d,0x%X",rd,k);
}
	encours->data=(char *) malloc(strlen(ctmp)+1);
	strcpy( encours->data,ctmp);
		  break;
		case 0x00F0:	//bld,branch,bst,sbrc,sbrs
			mnemo40(data,encours);
		  break;
		}
	    }
    }
}
