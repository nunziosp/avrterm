/*serie.c
Auteur : Nunzio Spitaleri
*/
#include <gtk/gtk.h>
#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include "serie.h"
#include "avrterm.h"

#include <sys/ioctl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <pwd.h>
#include <termios.h>
#include <fcntl.h>
#include <linux/serial.h>

struct termios old;
void ferme_port(void)
{
  if(port != -1)
    {
   /*   if(callback_activated == TRUE)
	{
	  gtk_input_remove(callback_handler);
	  callback_activated = FALSE;
	}*/
      tcsetattr(port, TCSANOW, &old);
      tcflush(port, TCOFLUSH);  
      tcflush(port, TCIFLUSH);
      close(port);
      port = -1;
    }
}

int set_custom_speed(int speed, int port_fd)
{

    struct serial_struct ser;
    int arby;

    ioctl(port_fd, TIOCGSERIAL, &ser);
    ser.custom_divisor = ser.baud_base / speed;
    if(!(ser.custom_divisor))
	ser.custom_divisor = 1;

    arby = ser.baud_base / ser.custom_divisor;
    ser.flags &= ~ASYNC_SPD_MASK;
    ser.flags |= ASYNC_SPD_CUST;

    ioctl(port_fd, TIOCSSERIAL, &ser);

    return 0;
}

void
Lis_port (int *data, int source, int condition)
{
  gint bytes_read = 0;
  guint tmp;
  if (flag == 0)
    while (bytes_read == 0)
      {
	bytes_read = read (port, buf_read, BUFFER_RECEPTION);
	if (bytes_read > 0)
	  {
	    flag = bytes_read;
	  }
	else if (bytes_read == -1)
	  {
	    if (errno != EAGAIN)
	      perror ("rs232->port");
	  }
      }
//  if (flag>0)printf (" Lis_port %d\n",flag);
  return;
}


int
openserie (scom rs232)
{
	struct termios tty;
//int callback_handler;
  if (port >= 0)
    {
	    ferme_port ();
      closeserie (port);
    }
  /* Ouverture du device */
  port = open (rs232->name, O_RDWR | O_NOCTTY | O_NONBLOCK);
  if (port < 0)
    {
      perror (rs232->name);
      exit (1);
    }

  fcntl (port, F_SETFL, fcntl (port, F_GETFL) | O_NONBLOCK | O_NDELAY);
  tcgetattr (port, &tty);
  memcpy(&old, &tty, sizeof(struct termios));

  b_speed (&tty, rs232->vitesse);
  b_size (&tty, rs232->nbre_bits);
  switch(rs232->parite)
    {
    case 1:
      tty.c_cflag |= PARODD | PARENB;
      break;
    case 2:
      tty.c_cflag |= PARENB;
      break;
    default:
      break;
    }
  if(rs232->bit_stop == 2)
    tty.c_cflag |= CSTOPB;
  tty.c_cflag |= CREAD;
  tty.c_iflag = IGNPAR | IGNBRK;
  /*switch(rs232->flux)
    {
    case 1:
      tty.c_iflag |= IXON | IXOFF;
      break;
    case 2:
      tty.c_cflag |= CRTSCTS;;
      break;
    default:
      tty.c_cflag |= CLOCAL;
      break;
    }*/
  tty.c_oflag = 0;
  tty.c_lflag = 0;
  tty.c_cc[VTIME] = 0;
  tty.c_cc[VMIN] = 1;
  set_custom_speed ( rs232->vitesse, port);
  tcsetattr(port, TCSANOW, &tty);
  tcflush(port, TCOFLUSH);  
  tcflush(port, TCIFLUSH);
  return port;
}

void
closeserie ()
{
  //tcsetattr (port, TCSANOW, &old);

  //close (port);
}

void
b_speed (struct termios *tty, int speed)
{
  switch (speed)
    {
    case 50:
      tty->c_cflag = B50;
      printf ("b_speed : %d\n", speed);
      break;
    case 75:
      tty->c_cflag = B75;
      printf ("b_speed : %d\n", speed);
      break;
    case 110:;
      tty->c_cflag = B110;
      printf ("b_speed : %d\n", speed);
      break;
    case 200:
      tty->c_cflag = B200;
      printf ("b_speed : %d\n", speed);
      break;
      tty->c_cflag = B300;
      printf ("b_speed : %d\n", speed);
      break;
    case 600:
      tty->c_cflag = B600;
      printf ("b_speed : %d\n", speed);
      break;
    case 1200:
      tty->c_cflag = B1200;
      printf ("b_speed : %d\n", speed);
      break;
    case 1800:;
      tty->c_cflag = B1800;
      printf ("b_speed : %d\n", speed);
      break;
    case 2400:
      tty->c_cflag = B2400;
      printf ("b_speed : %d\n", speed);
      break;
    case 4800:
      tty->c_cflag = B4800;
      printf ("b_speed : %d\n", speed);
      break;
    case 9600:
      tty->c_cflag = B9600;
      printf ("b_speed : %d\n", speed);
      break;
    case 19200:
      tty->c_cflag = B19200;
      printf ("b_speed : %d\n", speed);
      break;
    case 38400:
      tty->c_cflag = B38400;
      printf ("b_speed : %d\n", speed);
      break;
    case 57600:
      tty->c_cflag = B57600;
      printf ("b_speed : %d\n", speed);
      break;
    case 115200:
      tty->c_cflag = B115200;
      printf ("b_speed : %d\n", speed);
      break;
    case 230400:
      tty->c_cflag = B230400;
      printf ("b_speed : %d\n", speed);
      break;
    default:
      printf ("b_speed inchangee\n");
    }
  printf ("b_speed : %d out %d in %d %d\n", speed, cfgetospeed (tty),
	  cfgetispeed (tty), B9600);

}

void
b_size (struct termios * tty, int taille)
{
  tty->c_cflag &= ~CSIZE;
  switch (taille)
    {
    case 5:
      tty->c_cflag |= CS5;
      printf ("b_size : %d\n", taille);
      break;
    case 6:
      tty->c_cflag |= CS6;
      printf ("b_size : %d\n", taille);
      break;
    case 7:
      tty->c_cflag |= CS7;
      printf ("b_size : %d\n", taille);
      break;
    case 8:
      tty->c_cflag |= CS8;
      printf ("b_size : %d\n", taille);
      break;
    default:
      printf ("csize inchangee\n");
    }

}
