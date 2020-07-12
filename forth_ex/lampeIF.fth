# tout ce qui suit un # sont de commentaire. Certaines definitions commencant par # m'ont servies juste à la mise
# au point et dont inutiles
# Ce programme a ete consu pour gerer la temperature que fournie par une lampe infrarouge
# 
# 
hex #pour etre en mode hexadecimal par defaut apres un reset deci pour etre en mode decimal. En hexadicimal les
# chiffres au dela  de 9 sont ABCDEF en majuscule seulement
# pour etre en une autre base n, taper " n base c! "
# 
# restore #restaure le systeme comme apres programmation par USBASP à n'utiliser que en ligne de commande
# 
# forget nom # supprime toute les déclarations jusqu'a "nom" compris
forget ADCSRA
# : tt ; #inutile
# : LF A drop1 1 send0 ; #inutile
# 
: ADCSRA 7A ; #activation du convertisseur analogique
: DMUX 7C ; #selection du port analogique
var temp #decaration de la variable contenant la température
# 
116 temp ! 116 2 12 writeep #écriture de la temperature initiale dans tmp et l'eeprom. "writreep" permet d'écrire
#des donnees dans l'eeprom, le format est " data n adr writeep", data sont les donnnees, n nombre d'octets des donnees,
# adr ou ecrire les donnees
#"readeep" pour la lecture de l'eeprom, format " n adr readeep" qui retourne "data n"
# 
: temp+ temp dup @ dup 3F0 < if 2 + dup 2 14 writeep then swap ! ; #augmentation la consigne de temperature
: temp- temp dup @ dup A > if 2 - dup 2 14 writeep then swap ! ; #diminution la consigne de temperature
: reglage pin2 if temp+ then pin3 if temp- then  ; #test pour augmentation ou diminutionla consigne de temperature
# : reg pin2 if S" plus" then pin3 if  S" moins"  then  ; #inutile
: seconde 2708 delay  reglage  ; #delai 1 seconde et reglage pour lampe 2
: minute 3C 1 do seconde loop ; 
# : 5mnt 5 1 do minute loop ; #inutile
# : heure 258 1 do EA60 delay  loop ; #inutile
# : demi 12C 1 do EA60 delay loop ; #inutile
# : quart 96 1 do EA60 delay loop ; #inutile
# : Sd. 1B64 4 send0 ; #inutile
: init 2 14 readeep drop swap1 temp ! C7 DMUX c! C7 ADCSRA c!  ; #initialisation
# : test  116 temp ! init 20 0 do 7 adcn seconde r_adcn  Sd. loop ; #inutile
# : test2 init 20 0 do 8 adcn seconde r_adcn  Sd. loop ; #inutile
# : test3 0 init  7 adcn drop begin 7 adcn r_adcn dup  Sd. temp @  dup Sd. 2 14 readeep drop swap1  Sd.
# < if setd6 else clrd6 then seconde again ; #inutile
: lampe1  begin 7 adcn r_adcn temp @ < if setd6 else clrd6 then minute again ;
: lampe2  begin 7 adcn r_adcn temp @ < if setd6 else clrd6 then seconde again ;
: lampe 0 init 7 adcn drop pin3 if lampe1 else lampe2 then ;
start lampe #Start permet le démarrage automatique de lampe après un reset
