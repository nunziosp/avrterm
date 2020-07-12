/*keyboard.c
Auteur : Nunzio Spitaleri
*/

#include <stdio.h>


#include "serie.h"
#include "avrterm.h"
#include "decodage.h"
#include "reception.h"
#include "emission.h"
#include "draw.h"
#include "keyboard.h"

char
keyboard (int val)
{
  char high, low;
  low = 0xFF & val;
  high = ((0xFF00 & val) >> 8);
  if (high == 0xFF)
    {
    }
  return 0;
}
