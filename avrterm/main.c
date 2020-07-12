#include <stdlib.h>
#include <gtk/gtk.h>


int
main (int argc, char **argv)
{
  GtkBuilder *p_builder = NULL;
  GError *p_err = NULL;
  GtkWidget *p_win;


  /* Initialisation de GTK+ */
  gtk_init (&argc, &argv);


  /* Creation d'un nouveau GtkBuilder */
  p_builder = gtk_builder_new ();

  if (p_builder != NULL)
    {
      /* Chargement du XML dans p_builder */
      gtk_builder_add_from_file (p_builder, "minitel.xml", &p_err);

      if (p_err == NULL)
	{
	  /* 1.- Recuparation d'un pointeur sur la fenetre. */
	  GtkWidget *p_win =
	    (GtkWidget *) gtk_builder_get_object (p_builder, "window1");


	  /* 2.- */
	  /* Signal du bouton Ok */

	  gtk_widget_show_all (p_win);
	  gtk_main ();
	}
      else
	{
	  /* Affichage du message d'erreur de GTK+ */
	  g_error ("%s", p_err->message);
	  g_error_free (p_err);
	}
    }


  return EXIT_SUCCESS;
}
