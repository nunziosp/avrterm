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

: Stab 1B09 2 send0 ;
: STab 1B70 2 send0 ;
: nflash ( nbre, adr ...) dup >r readflash STab <r over >r z1 <r 5 + send0  ; #envoie de donnees a avrterm qui seront 
#affiche sous forme de tableau en hexa, nbre est le nombre d'octets  mais affichage des premiers octets en dernier.
# l'adresse est sur trois octets d'ou z1
# D0 0 nflash

: nram  ( nbre, adr ...) Stab over over z1 5 send0 swap over + swap ( adr+nbre,adr...)
do I c@ drop1 1 send0 loop ; #envoie de donnees a avrterm qui seront affiche
# sous forme de tableau en hexa, nbre est le nombre d'octets
# l'adresse est sur trois octets d'ou z1
# 40 100 nram

: return 9508 ;

definer sbi  rot rot 7 and swap 1F and 3 << + 9A00 + , return , does execute ;
definer cbi  rot rot 7 and swap 1F and 3 << + 9800 + , return , does execute ;
 4 5 sbi ddrb 
 
# les mot definis par "definer" mettent "here" dans la pile de donnees. lorsque sbi est execute ( 4,5,here....)
# rot rot (here,4,5 ...) 7 and swap (here,5,4...) 1F and 3 << (here,5,20...)
# + 9A00 + (here,9A25...) , 9500 , ( here,... ) "9A25 est sbi ddrB,5"
#0028C0-001460 0E 94 2B 09 0E 94 D5 06  08 95 25 9A 08 95 64 64  
#                                                sbi   ret d  d
#0028D0-001468 72 62 04 08 3B 14 0E 94  8F 06 65 14 0C 94 34 14
#              r  b  entetete    call   num2  1465  jmp 1434   call num2 met 1465 dans la pile et ensuite un
# jmp apres "does" (execute) qui execute donc l'adresse se trouvant dans la pile et qui a ete renvoye par "here"
#

5 5 sbi led_on
5 5 cbi led_off

# Maniere plus simple en ne modifiant pas un bit mais tout le portB. Note l'adresse 5 pour sbi est l'adresse
# 5 + 0x20 de la ram 0x25
#: ddrB 24 dup c@ 20 or swap c! ;  # ne modifie que la direction du portB5
# : led_on 20 25 c! ; # ecrit sur tout le portB
# : led_off 0 25 c! ;
#: tled   ddrB  10 1 do led_on 1380 delay led_off 1370 delay loop  ; tled

