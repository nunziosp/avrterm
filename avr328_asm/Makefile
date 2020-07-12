# Makefile pour la compilation sur avr-gcc
#
#  make		-- compile le programme
#  make prog	-- envoie le programme sur le æc (avec SP12)
#  make clean	-- nettoie le répertoire
#

# référence du modèle du µc
# sous la forme at90sXXXX
MCU = -p m328p
SPEED = -b 38400
DEV = -c usbasp
AUTO = $(SPEED) $(MCU) $(DEV)
# del sous dos/windows
# rm -f sous Unix
RM = rm

all : clean avr328forth

avr328forth: avr328forth.s
	avra -l avr328forth.list avr328forth.s 
	avra -o avr328forth.hex avr328forth.s 
	
prog :  clean avr328forth
	avrdude $(AUTO) -U flash:w:avr328forth.s.hex  -U lock:w:0x3F:m -F
	avrdude $(AUTO) -U eeprom:w:avr328forth.s.eep.hex -F
	avrdude $(AUTO) -U lfuse:w:0xFF:m -U hfuse:w:0xDC:m -U efuse:w:0xFF:m -F
	
clean :

	-test -z *~ || ${RM} *~
	-test -z *.o || ${RM} *.o
	-test -z *.elf || ${RM} *.elf
	-test -z *.rom || ${RM} *.rom
	-test -z *.eeprom || ${RM} *.eeprom