#Pour charger Forth sur atmega328 via usbasp
cd ./avr328_asm 
make prog

# Pour avrtem
cd ./avrterm
make
./avrterm /dev/ttyUSB0
# verifier include vte/vte.h dans callback.c et interface.c