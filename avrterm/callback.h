/* callback.h
Auteur : Nunzio Spitaleri
*/

#include <gtk/gtk.h>

void ecrittube (char *, int, int);
gboolean ecran (char);
char littube (int);
char lecture (int);
int echo;
char *name, *sendword;
//void key_press_envoi (GtkWidget * widget, GdkEventKey * event, gpointer data);
void s_combo1 (GtkWidget * widget, gpointer data);
void s_combo2 (GtkWidget * widget, gpointer data);
void s_combo3 (GtkWidget * widget, gpointer data);
void s_combo4 (GtkWidget * widget, gpointer data);
void s_combo5 (GtkWidget * widget, gpointer data);
void s_bouton1 (GtkWidget * widget, gpointer data);
void s_bouton2 (GtkWidget * widget, gpointer data);
void sb_flash (GtkWidget * widget, gpointer data);
void sb_vlist (GtkWidget * widget, gpointer data);
void sb_list (GtkWidget * widget, gpointer data);
void sb_retour (GtkWidget * widget, gpointer data);
void sb_file (GtkWidget * widget, gpointer data);
void sb_chooser (GtkWidget * widget, gpointer data);
void sb_again (GtkWidget * widget, gpointer data);
void sb_echo (GtkWidget * widget, gpointer data);
void sb_debug (GtkWidget * widget, gpointer data);
void sb_dp (GtkWidget * widget, gpointer data);
void sb_reset (GtkWidget * widget, gpointer data);
void enter_callback (GtkWidget * widget, GtkWidget * entry);
