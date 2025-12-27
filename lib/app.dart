import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moore/core/providers/notifications_manager_provider.dart';
import 'package:moore/core/ui/themes/app_themes.dart';
import 'package:moore/l10n/app_localizations.dart';
import 'package:moore/routing/routes.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext _, WidgetRef ref) {
    final lightTheme = ref.watch(lightAppThemeProvider);
    final darkTheme = ref.watch(darkAppThemeProvider);
    final router = ref.watch(routesProvider);
    ref.read(sharedPreferencesProvider.notifier).init();
    ref.watch(notificationsManagerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Moore',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
      themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
