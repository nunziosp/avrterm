/*
  * desas.h
  *
  *Auteur Nunzio Spitaleri
  *  
  */

#ifndef DESAS_H
#define DESAS_H
struct _mdata
{
  union _adr adr;
  unsigned char pass;
  unsigned int jmp_adr;
  unsigned char *data;
};
typedef struct _mdata *mdata;
int passone(mnemo,tligne);
#endif
