import 'dart:async';
import 'package:dbus/dbus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class NotificationServer extends DBusObject {
  NotificationServer(this._controller) : super(DBusObjectPath('/org/freedesktop/Notifications'));

  int _notificationId = 0;
  final StreamController<NotificationData> _controller;

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        'org.freedesktop.Notifications',
        methods: [
          DBusIntrospectMethod(
            'GetCapabilities',
            args: [
              DBusIntrospectArgument(
                DBusSignature('as'),
                DBusArgumentDirection.out,
                name: 'capabilities',
              ),
            ],
          ),
          DBusIntrospectMethod(
            'Notify',
            args: [
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.in_,
                name: 'app_name',
              ),
              DBusIntrospectArgument(
                DBusSignature('u'),
                DBusArgumentDirection.in_,
                name: 'replaces_id',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.in_,
                name: 'app_icon',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.in_,
                name: 'summary',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.in_,
                name: 'body',
              ),
              DBusIntrospectArgument(
                DBusSignature('as'),
                DBusArgumentDirection.in_,
                name: 'actions',
              ),
              DBusIntrospectArgument(
                DBusSignature('a{sv}'),
                DBusArgumentDirection.in_,
                name: 'hints',
              ),
              DBusIntrospectArgument(
                DBusSignature('i'),
                DBusArgumentDirection.in_,
                name: 'expire_timeout',
              ),
              DBusIntrospectArgument(
                DBusSignature('u'),
                DBusArgumentDirection.out,
                name: 'id',
              ),
            ],
          ),
          DBusIntrospectMethod(
            'CloseNotification',
            args: [
              DBusIntrospectArgument(
                DBusSignature('u'),
                DBusArgumentDirection.in_,
                name: 'id',
              ),
            ],
          ),
          DBusIntrospectMethod(
            'GetServerInformation',
            args: [
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.out,
                name: 'name',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.out,
                name: 'vendor',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.out,
                name: 'version',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.out,
                name: 'spec_version',
              ),
            ],
          ),
        ],
        signals: [
          DBusIntrospectSignal(
            'NotificationClosed',
            args: [
              DBusIntrospectArgument(
                DBusSignature('u'),
                DBusArgumentDirection.out,
                name: 'id',
              ),
              DBusIntrospectArgument(
                DBusSignature('u'),
                DBusArgumentDirection.out,
                name: 'reason',
              ),
            ],
          ),
          DBusIntrospectSignal(
            'ActionInvoked',
            args: [
              DBusIntrospectArgument(
                DBusSignature('u'),
                DBusArgumentDirection.out,
                name: 'id',
              ),
              DBusIntrospectArgument(
                DBusSignature('s'),
                DBusArgumentDirection.out,
                name: 'action_key',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.freedesktop.Notifications') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'GetCapabilities':
        return DBusMethodSuccessResponse([
          DBusArray.string(['actions', 'body', 'body-markup', 'icon-static']),
        ]);

      case 'Notify':
        final appName = methodCall.values[0].asString();
        final replacesId = methodCall.values[1].asUint32();
        final appIcon = methodCall.values[2].asString();
        final summary = methodCall.values[3].asString();
        final body = methodCall.values[4].asString();
        final actions = methodCall.values[5].asStringArray().toList();
        final expireTimeout = methodCall.values[7].asInt32();

        final id = replacesId > 0 ? replacesId : ++_notificationId;

        // ⭐ EMITIR notificação para o stream
        _controller.add(
          NotificationData(
            id: id,
            appName: appName,
            appIcon: appIcon,
            summary: summary,
            body: body,
            actions: actions,
            expireTimeout: expireTimeout,
          ),
        );

        // Auto-fechar após timeout
        if (expireTimeout > 0) {
          Future.delayed(Duration(milliseconds: expireTimeout), () {
            emitSignal(
              'org. freedesktop.Notifications',
              'NotificationClosed',
              [DBusUint32(id), const DBusUint32(1)],
            );
          });
        }

        return DBusMethodSuccessResponse([DBusUint32(id)]);

      case 'CloseNotification':
        final id = methodCall.values[0].asUint32();
        emitSignal(
          'org.freedesktop. Notifications',
          'NotificationClosed',
          [DBusUint32(id), const DBusUint32(3)],
        );
        return DBusMethodSuccessResponse([]);

      case 'GetServerInformation':
        return DBusMethodSuccessResponse([
          const DBusString('Dart Notification Daemon'),
          const DBusString('OdilonDamasceno'),
          const DBusString('1.0'),
          const DBusString('1.2'),
        ]);

      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

// Provider do cliente D-Bus (mantém conexão ativa)
final dbusClientProvider = Provider<DBusClient>((ref) {
  final client = DBusClient.session();
  ref.onDispose(() => client.close());
  return client;
});

// Provider do servidor de notificações
final notificationServerProvider = Provider<NotificationServer>((ref) {
  final controller = StreamController<NotificationData>.broadcast();
  ref.onDispose(() => controller.close());
  return NotificationServer(controller);
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

  await for (final notification in server._controller.stream) {
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
