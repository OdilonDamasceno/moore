// This file was generated using the following command and may be overwritten.
// dart-dbus generate-object org.freedesktop.Notifications.xml
// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:math';

import 'package:dbus/dbus.dart';
import 'package:moore/core/providers/notifications/notifications_manager_provider.dart';

class OrgFreedesktopNotifications extends DBusObject {
  final StreamController<NotificationData> _controller;

  /// Creates a new object to expose on [path].
  OrgFreedesktopNotifications(
    this._controller, {
    DBusObjectPath path = const DBusObjectPath.unchecked('/org/freedesktop/Notifications'),
  }) : super(path);

  StreamController<NotificationData> get controller => _controller;

  /// Implementation of org.freedesktop.Notifications.GetCapabilities()
  Future<DBusMethodResponse> doGetCapabilities() async {
    return DBusMethodErrorResponse(
      'org.freedesktop.Notifications.GetCapabilities() not implemented',
    );
  }

  /// Implementation of org.freedesktop.Notifications.Notify()
  Future<DBusMethodResponse> doNotify(
    String app_name,
    int replaces_id,
    String app_icon,
    String summary,
    String body,
    List<String> actions,
    Map<String, DBusValue> hints,
    int expire_timeout,
  ) async {
    final id = Random().nextInt(1 << 32);
    final dbusResponse = DBusMethodSuccessResponse([DBusUint32(id)]);

    controller.add(
      NotificationData(
        appName: app_name,
        appIcon: app_icon,
        summary: summary,
        body: body,
        actions: actions,
        expireTimeout: expire_timeout,
        id: id,
      ),
    );
    return dbusResponse;
  }

  /// Implementation of org.freedesktop.Notifications.CloseNotification()
  Future<DBusMethodResponse> doCloseNotification(int id) async {
    return DBusMethodSuccessResponse([]);
  }

  /// Implementation of org.freedesktop.Notifications.GetServerInformation()
  Future<DBusMethodResponse> doGetServerInformation() async {
    return DBusMethodSuccessResponse(const [
      DBusString('Moore Notification Server'),
      DBusString('Moore'),
      DBusString('1.0.0'),
      DBusString('1.2'),
    ]);
  }

  /// Emits signal org.freedesktop.Notifications.NotificationClosed
  Future<void> emitNotificationClosed(int id, int reason) async {
    await emitSignal('org.freedesktop.Notifications', 'NotificationClosed', [
      DBusUint32(id),
      DBusUint32(reason),
    ]);
  }

  /// Emits signal org.freedesktop.Notifications.ActionInvoked
  Future<void> emitActionInvoked(int id, String action_key) async {
    await emitSignal('org.freedesktop.Notifications', 'ActionInvoked', [
      DBusUint32(id),
      DBusString(action_key),
    ]);
  }

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
              DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_, name: 'body'),
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
              DBusIntrospectArgument(DBusSignature('u'), DBusArgumentDirection.out, name: 'id'),
            ],
          ),
          DBusIntrospectMethod(
            'CloseNotification',
            args: [
              DBusIntrospectArgument(DBusSignature('u'), DBusArgumentDirection.in_, name: 'id'),
            ],
          ),
          DBusIntrospectMethod(
            'GetServerInformation',
            args: [
              DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out, name: 'name'),
              DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out, name: 'vendor'),
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
              DBusIntrospectArgument(DBusSignature('u'), DBusArgumentDirection.out, name: 'id'),
              DBusIntrospectArgument(DBusSignature('u'), DBusArgumentDirection.out, name: 'reason'),
            ],
          ),
          DBusIntrospectSignal(
            'ActionInvoked',
            args: [
              DBusIntrospectArgument(DBusSignature('u'), DBusArgumentDirection.out, name: 'id'),
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
    if (methodCall.interface == 'org.freedesktop.Notifications') {
      if (methodCall.name == 'GetCapabilities') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doGetCapabilities();
      } else if (methodCall.name == 'Notify') {
        if (methodCall.signature != DBusSignature('susssasa{sv}i')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doNotify(
          methodCall.values[0].asString(),
          methodCall.values[1].asUint32(),
          methodCall.values[2].asString(),
          methodCall.values[3].asString(),
          methodCall.values[4].asString(),
          methodCall.values[5].asStringArray().toList(),
          methodCall.values[6].asStringVariantDict(),
          methodCall.values[7].asInt32(),
        );
      } else if (methodCall.name == 'CloseNotification') {
        if (methodCall.signature != DBusSignature('u')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doCloseNotification(methodCall.values[0].asUint32());
      } else if (methodCall.name == 'GetServerInformation') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doGetServerInformation();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'org.freedesktop.Notifications') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'org.freedesktop.Notifications') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }
}
