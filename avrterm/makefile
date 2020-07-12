CXX=gcc

CFLAGS = 	-DG_DISABLE_DEPRECATED 	 	\
	-DGDK_DISABLE_DEPRECATED 	\
	-DGDK_PIXBUF_DISABLE_DEPRECATED \
	-DGTK_DISABLE_DEPRECATED
GTK_FLAGS=-Werror -Wall -W -O2 -ansi -pedantic `pkg-config --cflags --libs gtk+-2.0` 

GTK_FLAGS1=-O2 -lvte `pkg-config --cflags --libs gtk+-2.0` 

bin_PROGRAMS =  avrterm 
avrterm_FILES=interface.c avrterm.c serie.c decodage.c \
 draw.c callback.c 

all: clean $(bin_PROGRAMS)


avrterm:
	$(CXX) $(avrterm_FILES) $(GTK_FLAGS1) -o avrterm

clean:
	-test -z "$(bin_PROGRAMS)" || rm -f $(bin_PROGRAMS)
	-rm -f *.o core *.core
	-rm -f *~

install:
	-test -z "$(bin_PROGRAMS)" || cp $(bin_PROGRAMS) ~/bin
	
