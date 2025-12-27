import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moore/modules/island/presentation/island.dart';
import 'package:moore/modules/island/presentation/widgets/volume_control.dart';

final islandRoutesProvider = Provider((_) {
  return ShellRoute(
    builder: (_, _, child) => Island(child: child),
    routes: [
      GoRoute(
        path: StartPage.routeName,
        builder: (context, state) => const StartPage(),
      ),
      GoRoute(
        path: CalendarPage.routeName,
        builder: (context, state) => const CalendarPage(),
      ),
      GoRoute(
        path: VolumeControl.routeName,
        builder: (context, state) => const VolumeControl(),
      ),
    ],
  );
});
