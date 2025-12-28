import 'dart:async';
import 'package:dbus/dbus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moore/core/providers/notifications/notification_object.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modelo de dados para notificação
class NotificationData {
  final int id;
  final String appName;
  final String appIcon;
  final String summary;
  final String body;
  final List<String> actions;
  final int expireTimeout;

  NotificationData({
    required this.id,
    required this.appName,
    required this.appIcon,
    required this.summary,
    required this.body,
    required this.actions,
    required this.expireTimeout,
  });
}

// Provider do cliente D-Bus (mantém conexão ativa)
final dbusClientProvider = Provider<DBusClient>((ref) {
  final client = DBusClient.session();
  ref.onDispose(() => client.close());
  return client;
});

// Provider do servidor de notificações
final notificationServerProvider = Provider<OrgFreedesktopNotifications>((ref) {
  final controller = StreamController<NotificationData>.broadcast();
  ref.onDispose(() => controller.close());
  return OrgFreedesktopNotifications(controller);
});

final dbusServerInitProvider = FutureProvider<void>((ref) async {
  final client = ref.watch(dbusClientProvider);
  final server = ref.watch(notificationServerProvider);

  await client.requestName(
    'org.freedesktop.Notifications',
    flags: {
      DBusRequestNameFlag.replaceExisting,
      DBusRequestNameFlag.allowReplacement,
    },
  );

  await client.registerObject(server);
});

final notificationsManagerProvider = StreamProvider<NotificationData?>((ref) async* {
  ref.watch(dbusServerInitProvider);

  final server = ref.watch(notificationServerProvider);

  yield null;

  await for (final notification in server.controller.stream) {
    yield notification;

    final historyNotifier = ref.read(notiticationsHistoryProvider.notifier);
    await historyNotifier.addNotification(notification);

    yield await Future.delayed(
      Duration(milliseconds: notification.expireTimeout > 0 ? notification.expireTimeout : 5000),
    ).then((_) => null);
  }
}, dependencies: [notiticationsHistoryProvider]);

final notiticationsHistoryProvider = NotifierProvider(NotificationsHistoryNotifier.new);

class NotificationsHistoryNotifier extends Notifier<List<NotificationData>> {
  @override
  build() {
    final prefs = ref.read(sharedPreferencesProvider);

    final historyData = prefs?.getStringList('notifications_history') ?? [];

    final history = historyData.map((data) {
      final parts = data.split('||');
      return NotificationData(
        id: int.parse(parts[0]),
        appName: parts[1],
        appIcon: parts[2],
        summary: parts[3],
        body: parts[4],
        actions: parts[5].split(','),
        expireTimeout: int.parse(parts[6]),
      );
    }).toList();

    return history;
  }

  Future<void> addNotification(NotificationData notification) async {
    state = [notification, ...state];

    final prefs = ref.read(sharedPreferencesProvider);

    final historyData = state.map((notif) {
      return '${notif.id}||${notif.appName}||${notif.appIcon}||${notif.summary}||${notif.body}||${notif.actions.join(',')}||${notif.expireTimeout}';
    }).toList();

    await prefs?.setStringList('notifications_history', historyData);
  }

  Future<void> clearAll() async {
    state = [];

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs?.remove('notifications_history');
  }
}

final sharedPreferencesProvider = NotifierProvider(SharedPreferencesNotifier.new);

class SharedPreferencesNotifier extends Notifier<SharedPreferences?> {
  @override
  build() => null;

  Future<void> init() async {
    state = await SharedPreferences.getInstance();
  }
}
