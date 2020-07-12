 /*
  * hex.h
  *
  *Auteur Nunzio Spitaleri
  *  
  */

#ifndef HEX_H
#define HEX_H

union _adr
{
  unsigned int full;
  unsigned char part[5];
} adr, code;
struct _tdata
{
  unsigned int nbre;
  union _adr adr;
  unsigned char type;
  unsigned char *data;
};
typedef struct _tdata *tdata;
struct _tligne
{
  unsigned int nbre;
  union _adr adr;
  unsigned char type;
  struct _tdata *tdata;
};
typedef struct _tligne *tligne;
tligne readhex (char *);
#endif
