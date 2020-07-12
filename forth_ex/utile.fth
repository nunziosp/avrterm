hex
forget LF
: LF A drop1 1 send0 ; # send0 envoi des données vers avrterm (data,nbre.....), nbre donnees de data sont envoyés
# une donnée dans la pile de données et de 2 octets, le poids fort est accessible en premier. "drop1" supprime
# 1 octets de la pile et donc "1 send0" envoi A (10) en hexadécimal
# les fichiers forth peut etre charger par avrterm avec le bouton "File Select". Une fois selectionné, le nom du fichier
# apparait sur le bouton de gauche de "File Select", cliquer dessus pour charger. Apres une modification du fichier,
# il suffit de recliquer sur le bouton avec le nom du fichier pour le recharger. 
var v_error

: So. 1B6F 3 send0 ; # ^o et 1 octet sont envoyé vers avrterm qui l'affiche en hexa
: SD. 1B44 6 send0 ; # envoie de 4 octets afficher en decimal
: Sd. 1B64 4 send0 ; # envoie de 2 octets afficher en decimal
: SB. 1B42 6 send0 ; # envoie de 4 octets afficher en binaire
: Sb. 1B62 4 send0 ; # envoie de 2 octets afficher en binaire
: Sh. 1B68 4 send0 ; # envoie de 2 octets afficher en hexa
: SH. 1B48 6 send0 ; # envoie de 4 octets afficher en hexa
: ST 1B54 2 send0 ; # init temp, mesure de duree par avrterm
: St 1B74 2 send0 ; # temp passe qui s'affiche sur le terminal ayant lance avrterm
deci
: exemple ST 1000 1 do 10000 0 do loop loop St ; # "time : 28134 ms" est obtenu pour 10 millions de boucles vide
# avec arduino nano à 16 Mhz, soit environ 357000 boucles vides par seconde
hex
: St. ( data,nbre,adr.....) over 7 + >r  z1 1B09 <r send0 ; # envoie de donnees a avrterm qui seront affiche
# sous forme de tableau en hexa, nbre est le nombre d'octets 
: Si. ( data,nbre,adr.....) over 7 + >r  z1 1B70 <r send0 ; # envoie de donnees a avrterm qui seront affiche
# sous forme de tableau en hexa, nbre est le nombre d'octets, il doit etre inférieur a 256 octests 
: vf if S" faux " else S" vrai " then ; # test "if", "then" est obligatoire, "else" est optionel est se trouve 
# avant "then"

definer sbi # "definer" permet de creer un mot qui va creer d'autre mot à la manière de "var"
7 and swap 1F and 3 << + 9A00 +
, does execute ;
definer cbi # (adr,bit....) 
7 and swap 1F and 3 << + 9800 +
, does execute ;

5 7 sbi sportB7 #(adr,bit....) "sportB7" est cree par "sbi"  et qui permet de mettre à 1 le bit 7 à l'adresse 25 en hexa 
# qui correspond au portB
5 7 cbi cportB7 #(adr,bit....)"sportB7" est cree par "cbi"  et qui permet de mettre à 0 le bit 7 à l'adresse 25 en hexa 
# qui correspond au portB
sportB7 #set du bit 7 du port B
cportB7 #reset du bit 7 du port B
#
definer var4  4 allot does ; #permet de creer un variable sur 4 octets
var4 v_test
v_test #(......adr) v_test retourne l'adresse des 4 octets disponible
# Attention forget "nom" permet d'effacer les mots jusqu'à "nom" inclus sans pouvoir effacer les mots ecrits
# par UBSASP mais il n'y pas de recupération de la mémoire ram ainsi que pour var qui utilise "allot" pour réserver
# de la ram.
# Pour tout recuperer, utiliser "restore" qui remet le systeme comme après programmation par UBSASP
deci