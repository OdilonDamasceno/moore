#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk-layer-shell.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#endif
#define DOCK_SIZE_WIDTH 240
#define DOCK_SIZE_HEIGHT 32
#include "flutter/generated_plugin_registrant.h"

struct _MyApplication
{
  GtkApplication parent_instance;
  char **dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

extern "C" void setup_layer_shell(GtkWidget *window, int height)
{
  gtk_layer_init_for_window(GTK_WINDOW(window));

  gtk_layer_set_layer(GTK_WINDOW(window), GTK_LAYER_SHELL_LAYER_OVERLAY);

  gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
  gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_LEFT, FALSE);
  gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_RIGHT, FALSE);

  gtk_layer_set_exclusive_zone(GTK_WINDOW(window), height);

  gtk_layer_set_margin(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_TOP, 0);
  gtk_layer_set_margin(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_LEFT, 0);
  gtk_layer_set_margin(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_RIGHT, 0);
}

static void first_frame_cb(MyApplication *self, FlView *view)
{
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

typedef struct
{
  GtkWidget *toplevel;
  GtkWidget *view;
  int width;
  int height;
} SizeRequestData;

static void apply_resize_in_place(GtkWidget *toplevel, GdkWindow *gdk_toplevel,
                                  GtkWidget *view, int width, int height)
{
  if (gtk_layer_is_layer_window(GTK_WINDOW(toplevel)))
  {
    gtk_layer_set_anchor(GTK_WINDOW(toplevel), GTK_LAYER_SHELL_EDGE_LEFT, FALSE);
    gtk_layer_set_anchor(GTK_WINDOW(toplevel), GTK_LAYER_SHELL_EDGE_RIGHT, FALSE);
  }

  gtk_widget_set_size_request(view, width, height);

  if (gdk_toplevel)
  {
    gdk_window_resize(gdk_toplevel, width, height);
  }
  else
  {
    gtk_window_resize(GTK_WINDOW(toplevel), width, height);
  }

  gtk_widget_queue_resize(view);
  gtk_widget_queue_resize(toplevel);
}

static void apply_resize_and_center(GtkWidget *toplevel, GdkWindow *gdk_toplevel,
                                    GtkWidget *view, int width, int height)
{
  if (gtk_layer_is_layer_window(GTK_WINDOW(toplevel)))
  {
    gtk_layer_set_anchor(GTK_WINDOW(toplevel), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(toplevel), GTK_LAYER_SHELL_EDGE_LEFT, FALSE);
    gtk_layer_set_anchor(GTK_WINDOW(toplevel), GTK_LAYER_SHELL_EDGE_RIGHT, FALSE);

    GdkDisplay *display = gdk_display_get_default();
    if (display)
    {
      GdkMonitor *monitor = gdk_display_get_primary_monitor(display);
      if (monitor)
      {
        GdkRectangle workarea;
        gdk_monitor_get_workarea(monitor, &workarea);
        int margin_x = (workarea.width - width) / 2;
        gtk_layer_set_margin(GTK_WINDOW(toplevel), GTK_LAYER_SHELL_EDGE_LEFT, margin_x);
      }
    }
  }
  else
  {
    GdkDisplay *display = gdk_display_get_default();
    if (!display)
      return;

    GdkMonitor *monitor = gdk_display_get_primary_monitor(display);
    if (!monitor)
      return;

    GdkRectangle workarea;
    gdk_monitor_get_workarea(monitor, &workarea);
    int new_x = workarea.x + (workarea.width - width) / 2;
    int new_y = workarea.y;

    if (gdk_toplevel)
    {
      gdk_window_move_resize(gdk_toplevel, new_x, new_y, width, height);
    }
    else
    {
      gtk_window_move(GTK_WINDOW(toplevel), new_x, new_y);
      gtk_window_resize(GTK_WINDOW(toplevel), width, height);
    }
  }

  gtk_widget_set_size_request(view, width, height);

  gtk_widget_queue_resize(view);
  gtk_widget_queue_resize(toplevel);
}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *call, gpointer user_data)
{
  const gchar *method = fl_method_call_get_name(call);

  if (g_strcmp0(method, "setAlwaysOnTop") == 0)
  {
    FlValue *args = fl_method_call_get_args(call);
    gboolean keep = TRUE;

    if (!args)
      return;

    if (fl_value_get_type(args) == FL_VALUE_TYPE_BOOL)
    {
      keep = fl_value_get_bool(args);
    }
    else if (args && fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) > 0)
    {
      FlValue *v = fl_value_get_list_value(args, 0);
      if (fl_value_get_type(v) == FL_VALUE_TYPE_BOOL)
        keep = fl_value_get_bool(v);
    }

    FlView *view = FL_VIEW(user_data);
    GtkWidget *toplevel = gtk_widget_get_toplevel(GTK_WIDGET(view));

    if (GTK_IS_WINDOW(toplevel))
    {
      GdkWindow *gdk_toplevel = gtk_widget_get_window(toplevel);
      if (gdk_toplevel)
      {
        keep ? gdk_window_raise(gdk_toplevel) : gdk_window_lower(gdk_toplevel);
      }
    }

    FlValue *result = fl_value_new_bool(TRUE);
    fl_method_call_respond_success(call, result, nullptr);
    return;
  }

  gboolean is_resize_method = (g_strcmp0(method, "setSize") == 0 ||
                               g_strcmp0(method, "resetSize") == 0 ||
                               g_strcmp0(method, "setSizeAndCenter") == 0);

  if (!is_resize_method)
  {
    fl_method_call_respond_not_implemented(call, nullptr);
    return;
  }

  int width = 0;
  int height = 0;
  FlView *view = FL_VIEW(user_data);

  if (g_strcmp0(method, "resetSize") == 0)
  {
    width = DOCK_SIZE_WIDTH;
    height = DOCK_SIZE_HEIGHT;
  }
  else
  {
    FlValue *args = fl_method_call_get_args(call);
    if (!args || fl_value_get_type(args) != FL_VALUE_TYPE_LIST || fl_value_get_length(args) < 2)
    {
      FlValue *err = fl_value_new_string("Invalid arguments: expected [width, height]");
      fl_method_call_respond_error(call, "bad_args", "Expected [width, height]", err, nullptr);
      return;
    }

    width = fl_value_get_int(fl_value_get_list_value(args, 0));
    height = fl_value_get_int(fl_value_get_list_value(args, 1));
  }
  GtkWidget *toplevel = gtk_widget_get_toplevel(GTK_WIDGET(view));
  if (!GTK_IS_WINDOW(toplevel))
  {
    fl_method_call_respond_error(call, "no_window", "No toplevel window found", nullptr, nullptr);
    return;
  }

  GdkWindow *gdk_toplevel = gtk_widget_get_window(toplevel);

  if (g_strcmp0(method, "setSize") == 0)
  {
    apply_resize_in_place(toplevel, gdk_toplevel, GTK_WIDGET(view), width, height);
  }
  else if (g_strcmp0(method, "setSizeAndCenter") == 0 || g_strcmp0(method, "resetSize") == 0)
  {
    apply_resize_and_center(toplevel, gdk_toplevel, GTK_WIDGET(view), width, height);
  }

  FlValue *result = fl_value_new_bool(TRUE);
  fl_method_call_respond_success(call, result, nullptr);
}

static void my_application_activate(GApplication *application)
{
  MyApplication *self = MY_APPLICATION(application);

  GtkWindow *window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  GdkDisplay *display = gdk_display_get_default();
  GdkMonitor *monitor = gdk_display_get_primary_monitor(display);
  GdkRectangle workarea;
  gdk_monitor_get_workarea(monitor, &workarea);

  gtk_window_set_decorated(window, FALSE);
  gtk_window_set_resizable(window, FALSE);
  gtk_window_set_keep_above(window, TRUE);

  setup_layer_shell(GTK_WIDGET(window), DOCK_SIZE_HEIGHT);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);
  FlView *view = fl_view_new(project);

  GdkRGBA background_color;
  gdk_rgba_parse(&background_color, "#00000000");
  fl_view_set_background_color(view, &background_color);

  gtk_widget_set_size_request(GTK_WIDGET(view), DOCK_SIZE_WIDTH, DOCK_SIZE_HEIGHT);

  GdkScreen *screen = gtk_window_get_screen(window);
  GdkVisual *visual = gdk_screen_get_rgba_visual(screen);
  if (visual != nullptr && gdk_screen_is_composited(screen))
  {
    gtk_widget_set_visual(GTK_WIDGET(window), visual);
  }
  gtk_widget_set_app_paintable(GTK_WIDGET(window), TRUE);

  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb), self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  FlEngine *engine = fl_view_get_engine(view);
  FlBinaryMessenger *messenger = fl_engine_get_binary_messenger(engine);
  FlMethodChannel *channel = fl_method_channel_new(
      messenger,
      "moore/resize",
      FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(channel, method_call_cb, view, nullptr);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

static gboolean my_application_local_command_line(GApplication *application,
                                                  gchar ***arguments,
                                                  int *exit_status)
{
  MyApplication *self = MY_APPLICATION(application);
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error))
  {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

static void my_application_startup(GApplication *application)
{
  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

static void my_application_shutdown(GApplication *application)
{
  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

static void my_application_dispose(GObject *object)
{
  MyApplication *self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass *klass)
{
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication *self) {}

MyApplication *my_application_new()
{
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
