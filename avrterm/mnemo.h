/*
  * mnemo.h
  *
  *Auteur Nunzio Spitaleri
  *  
  */

#ifndef MNEMO_H
#define MNEMO_H
struct _mnemo
{
  union _adr adr;
  int	ordre;
  unsigned char pass;
  unsigned int jmp_adr;
unsigned   char *data;
struct _mnemo *next,*prev;
};
typedef struct _mnemo *mnemo;
int mnemo0(int ,mnemo );
int mnemo10(int ,mnemo );
int mnemo20(int ,mnemo );
int mnemo40(int ,mnemo );
#endif
