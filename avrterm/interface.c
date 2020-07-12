/* interface.c
Auteur : Nunzio Spitaleri
*/


#include <string.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <vte-0.0/vte/vte.h>
//#include <vte/vte.h>

#include "avrterm.h"
#include "interface.h"
#include "callback.h"
#include "serie.h"

static gchar blank_data[128];
static guint total_bytes;
static gint bytes_per_line = 16;

void
initialize_hexadecimal_display (void)
{
  total_bytes = 0;
  memset (blank_data, ' ', 128);
  blank_data[bytes_per_line * 3 + 5] = 0;
}


void
clear_display (void)
{
  initialize_hexadecimal_display ();
  if (screen)
    vte_terminal_reset (VTE_TERMINAL (screen), FALSE, TRUE);
  vte_terminal_set_size (VTE_TERMINAL (screen), COLONNE, RANGEE);
  col = row = 0;
}

GtkWidget *
fenetre ()
{
  /* Creation de la fenetre */
  window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_widget_set_size_request (window, 950, 500);

  gtk_window_set_title (GTK_WINDOW (window), "Avrterm - Nunzio");


  /* Sets the border width of the window. */
  gtk_container_set_border_width (GTK_CONTAINER (window), 1);

  /* creation d'un conteneur */
  vbox1 = gtk_vbox_new (FALSE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (vbox1), 1);
  gtk_container_add (GTK_CONTAINER (window), vbox1);
  gtk_widget_show (vbox1);

  /* creation d'un conteneur */
  hbox1 = gtk_hbox_new (FALSE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (hbox1), 1);
  gtk_box_pack_start (GTK_BOX (vbox1), hbox1, TRUE, TRUE, 1);
  gtk_widget_show (hbox1);

//  buffer = gtk_text_buffer_new (NULL);
  // gtk_widget_show (buffer);

  screen = vte_terminal_new ();

  vte_terminal_set_backspace_binding (screen,
				      VTE_ERASE_ASCII_BACKSPACE);


//  vte_terminal_set_backspace_binding(VTE_TERMINAL(screen),
//              VTE_ERASE_ASCII_BACKSPACE);
//gtk_widget_set_size_request(screen,320,542);
  vte_terminal_set_emulation (VTE_TERMINAL (screen), "xterm");
//  clear_display();
  vte_terminal_set_scroll_on_output (VTE_TERMINAL (screen),TRUE);
  gtk_box_pack_start (GTK_BOX (hbox1), screen, TRUE, TRUE, 0);

  // gtk_text_buffer_get_iter_at_offset(buffer, &iter, 0);
  // gtk_text_iter_set_offset(&iter,STAILLE);
//  gtk_text_iter_set_line(&iter,RANGEE);
  // gtk_text_buffer_get_iter_at_offset(buffer, &iter, 0);
  vte_terminal_set_size (VTE_TERMINAL (screen), 40, 24);
  gtk_widget_show (screen);
  gtk_container_set_border_width (GTK_CONTAINER (window), 1);
  /* creation d'un conteneur */
  vbox2 = gtk_vbox_new (FALSE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (vbox2), 1);
  gtk_container_add (GTK_CONTAINER (hbox1), vbox2);
  gtk_widget_show (vbox2);

  label1 = gtk_label_new ("Port");
  gtk_box_pack_start (GTK_BOX (vbox2), label1, TRUE, TRUE, 5);
  gtk_widget_show (label1);

  combo1 = gtk_combo_new ();
  gtk_box_pack_start (GTK_BOX (vbox2), combo1, TRUE, TRUE, 5);
  gtk_widget_show (combo1);
  glist1 = g_list_append (glist1,rs232->name);
  glist1 = g_list_append (glist1, "/dev/ttyS0");
  glist1 = g_list_append (glist1, "/dev/ttyS1");
  glist1 = g_list_append (glist1, "/dev/ttyS2");
  glist1 = g_list_append (glist1, "/dev/ttyS3");
  gtk_combo_set_popdown_strings (GTK_COMBO (combo1), glist1);
  
  //gtk_combo_set_popdown_strings( combo1,rs232->name );

  label2 = gtk_label_new ("Vitesse");
  gtk_box_pack_start (GTK_BOX (vbox2), label2, TRUE, TRUE, 5);
  gtk_widget_show (label2);

  combo2 = gtk_combo_new ();
  gtk_box_pack_start (GTK_BOX (vbox2), combo2, TRUE, TRUE, 5);
  glist2 = g_list_append (glist2, "38400");
  glist2 = g_list_append (glist2, "50");
  glist2 = g_list_append (glist2, "75");
  glist2 = g_list_append (glist2, "110");
  glist2 = g_list_append (glist2, "200");
  glist2 = g_list_append (glist2, "300");
  glist2 = g_list_append (glist2, "600");
  glist2 = g_list_append (glist2, "1200");
  glist2 = g_list_append (glist2, "1800");
  glist2 = g_list_append (glist2, "2400");
  glist2 = g_list_append (glist2, "4800");
  glist2 = g_list_append (glist2, "9600");
  glist2 = g_list_append (glist2, "19200");
  glist2 = g_list_append (glist2, "38400");
  glist2 = g_list_append (glist2, "57600");
  glist2 = g_list_append (glist2, "115200");
  glist2 = g_list_append (glist2, "230400");
  gtk_combo_set_popdown_strings (GTK_COMBO (combo2), glist2);
  gtk_widget_show (combo2);

  label3 = gtk_label_new ("Nbre de bits");
  gtk_box_pack_start (GTK_BOX (vbox2), label3, TRUE, TRUE, 5);
  gtk_widget_show (label3);

  combo3 = gtk_combo_new ();
  gtk_box_pack_start (GTK_BOX (vbox2), combo3, TRUE, TRUE, 5);
  gtk_widget_show (combo3);
  glist3 = g_list_append (glist3, "8");
  glist3 = g_list_append (glist3, "5");
  glist3 = g_list_append (glist3, "6");
  glist3 = g_list_append (glist3, "7");
  glist3 = g_list_append (glist3, "8");
  gtk_combo_set_popdown_strings (GTK_COMBO (combo3), glist3);


  label4 = gtk_label_new ("Parité");
  gtk_box_pack_start (GTK_BOX (vbox2), label4, TRUE, TRUE, 5);
  gtk_widget_show (label4);

  combo4 = gtk_combo_new ();
  gtk_box_pack_start (GTK_BOX (vbox2), combo4, TRUE, TRUE, 5);
  gtk_widget_show (combo4);
  glist4 = g_list_append (glist4, "None");
  glist4 = g_list_append (glist4, "Even");
  glist4 = g_list_append (glist4, "Odd");
  gtk_combo_set_popdown_strings (GTK_COMBO (combo4), glist4);


  label5 = gtk_label_new ("Bit de stop");
  gtk_box_pack_start (GTK_BOX (vbox2), label5, TRUE, TRUE, 5);
  gtk_widget_show (label5);

  combo5 = gtk_combo_new ();
  gtk_box_pack_start (GTK_BOX (vbox2), combo5, TRUE, TRUE, 5);
  gtk_widget_show (combo5);
  glist5 = g_list_append (glist5, "1");
  glist5 = g_list_append (glist5, "2");
  gtk_combo_set_popdown_strings (GTK_COMBO (combo5), glist5);


  hbox2 = gtk_hbox_new (FALSE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (vbox2), 1);
  gtk_box_pack_start (GTK_BOX (vbox2), hbox2, TRUE, TRUE, 1);
  gtk_widget_show (hbox2);

  bouton2 = gtk_button_new_with_label ("Valide");
  gtk_box_pack_start (GTK_BOX (hbox2), bouton2, TRUE, TRUE, 5);
  gtk_widget_show (bouton2);

  bouton1 = gtk_button_new_with_label ("Quitter");
  gtk_box_pack_start (GTK_BOX (hbox2), bouton1, TRUE, TRUE, 5);
  gtk_widget_show (bouton1);
  /* creation d'un conteneur */


  table = gtk_table_new (4, 17, TRUE);
  gtk_table_set_row_spacing (GTK_TABLE (table), 0, 2);
  gtk_table_set_col_spacing (GTK_TABLE (table), 0, 2);
  gtk_box_pack_start (GTK_BOX (vbox1), table, TRUE, TRUE, 0);
  gtk_widget_show (table);

  entry = gtk_entry_new ();
  // gtk_entry_set_max_length (GTK_ENTRY (entry), MAX_ENTRY); 
  gtk_entry_set_width_chars (GTK_ENTRY (entry), MAX_ENTRY);
  //gtk_entry_set_text (GTK_ENTRY (entry), "led del led");
  //gtk_editable_insert_text (GTK_EDITABLE (entry), " world",
  //gtk_entry_get_overwrite_mode(entry); -1, &tmp_pos);
  //gtk_editable_set_editable(GTK_ENTRY (entry), TRUE);
  gtk_editable_select_region (GTK_EDITABLE (entry),
			      0, GTK_ENTRY (entry)->text_length);
  gtk_table_attach_defaults (GTK_TABLE (table), entry, 0, 12, 0, 2);
  gtk_widget_show (entry);

  b_reset = gtk_button_new_with_label ("Reset");
  gtk_table_attach_defaults (GTK_TABLE (table), b_reset, 1, 4, 2, 3);
  gtk_widget_show (b_reset);
  b_echo = gtk_button_new_with_label ("Echo");
  gtk_table_attach_defaults (GTK_TABLE (table), b_echo, 5, 6, 2, 3);
  gtk_widget_show (b_echo);

  b_vlist = gtk_button_new_with_label ("vlist");
  gtk_table_attach_defaults (GTK_TABLE (table), b_vlist, 6, 8, 2, 3);
  gtk_widget_show (b_vlist);

  b_dp = gtk_button_new_with_label ("dp");
  gtk_table_attach_defaults (GTK_TABLE (table), b_dp, 8, 10, 2, 3);
  gtk_widget_show (b_dp);

  b_list = gtk_button_new_with_label ("list");
  gtk_table_attach_defaults (GTK_TABLE (table), b_list, 10, 12, 2, 3);
  gtk_widget_show (b_list);

  b_debug = gtk_button_new_with_label ("debug");
  gtk_table_attach_defaults (GTK_TABLE (table), b_debug, 12, 14, 2, 3);
  gtk_widget_show (b_debug);

  b_file = gtk_button_new_with_label ("None");
  gtk_table_attach_defaults (GTK_TABLE (table), b_file, 6, 8, 3, 4);
  gtk_widget_show (b_file);

  b_chooser = gtk_button_new_with_label ("File Select");
  gtk_table_attach_defaults (GTK_TABLE (table), b_chooser, 8, 10, 3, 4);
  gtk_widget_show (b_chooser);

  b_again = gtk_button_new_with_label ("Again");
  gtk_table_attach_defaults (GTK_TABLE (table), b_again, 10, 12, 3, 4);
  gtk_widget_show (b_again);

  b_flash = gtk_button_new_with_label ("flash");
  gtk_table_attach_defaults (GTK_TABLE (table), b_flash, 12, 14, 3, 4);
  gtk_widget_show (b_flash);

  g_signal_connect (GTK_COMBO (combo1)->entry, "changed",
		    G_CALLBACK (s_combo1), NULL);
  g_signal_connect (GTK_COMBO (combo2)->entry, "changed",
		    G_CALLBACK (s_combo2), NULL);
  g_signal_connect (GTK_COMBO (combo3)->entry, "changed",
		    G_CALLBACK (s_combo3), NULL);
  g_signal_connect (GTK_COMBO (combo4)->entry, "changed",
		    G_CALLBACK (s_combo4), NULL);
  g_signal_connect (GTK_COMBO (combo5)->entry, "changed",
		    G_CALLBACK (s_combo5), NULL);

  g_signal_connect (bouton1, "clicked", G_CALLBACK (s_bouton1), NULL);
  g_signal_connect (bouton2, "clicked", G_CALLBACK (s_bouton2), NULL);

  g_signal_connect (entry, "activate",
		    G_CALLBACK (enter_callback), (gpointer) entry);


  //g_signal_connect (screen, "key_press_event", G_CALLBACK (key_press_envoi), NULL);


  g_signal_connect (b_flash, "clicked", G_CALLBACK (sb_flash), NULL);
  g_signal_connect (b_vlist, "clicked", G_CALLBACK (sb_vlist), NULL);
  g_signal_connect (b_list, "clicked", G_CALLBACK (sb_list), NULL);
  g_signal_connect (b_file, "clicked", G_CALLBACK (sb_file), NULL);
  g_signal_connect (b_chooser, "clicked", G_CALLBACK (sb_chooser), NULL);
  g_signal_connect (b_again, "clicked", G_CALLBACK (sb_again), NULL);
  g_signal_connect (b_echo, "clicked", G_CALLBACK (sb_echo), NULL);
  g_signal_connect (b_debug, "clicked", G_CALLBACK (sb_debug),
		    NULL);
  g_signal_connect (b_dp, "clicked", G_CALLBACK (sb_dp),
		    NULL);
  g_signal_connect (b_reset, "clicked", G_CALLBACK (sb_reset), NULL);
  return window;
}
