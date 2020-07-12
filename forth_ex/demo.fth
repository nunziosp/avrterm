hex
forget LF
: LF A drop1 1 send0 ;
: SD. 1B44 6 send0 ; # envoie de 4 octets afficher en decimal
: Sd. 1B64 4 send0 ; # envoie de 2 octets afficher en decimal
: SB. 1B42 6 send0 ; # envoie de 4 octets afficher en binaire
: Sb. 1B62 4 send0 ; # envoie de 2 octets afficher en binaire
: Sh. 1B68 4 send0 ; # envoie de 2 octets afficher en hexa
: SH. 1B48 6 send0 ; # envoie de 4 octets afficher en hexa
: ST 1B54 2 send0 ; # init temp, mesure de duree par avrterm
: St 1B74 2 send0 ; # temp passe qui s'affiche sur le terminal ayant lance avrterm
: St. ( data,nbre,adr.....) over 7 + >r  z1 1B09 <r send0 ; : St. ( data,nbre,adr.....) over 7 + >r  z1 1B09 <r send0 ; # envoie de donnees a avrterm qui seront affiche
# sous forme de tableau en hexa, nbre est le nombre d'octets, il doit etre inférieur a 249 octests 
: vect_int 30 0 readflash 0 St. ;
