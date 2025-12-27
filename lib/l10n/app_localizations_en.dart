// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get clockFormatter => 'EEE MMM dd hh:mm a';

  @override
  String get noEventsForThisDay => 'No events for this day';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get volume => 'Volume';
}
