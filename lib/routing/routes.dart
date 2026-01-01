import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moore/core/providers/window_manager_provider.dart';
import 'package:moore/core/ui/painting/island_shape.dart';
import 'package:moore/modules/island/routing/routes.dart';
import 'package:moore/modules/status/presentation/status_bar.dart';
import 'package:moore/modules/status/routing/routes.dart';

final routesProvider = Provider((ref) {
  final statusRoute = ref.read(statusRoutesProvider);
  final islandRoute = ref.read(islandRoutesProvider);

  final routes = <RouteBase>[
    statusRoute,
    islandRoute,
  ];

  final baseRoute = ShellRoute(
    builder: (context, state, child) => ResizableWidget(child: child),
    routes: routes,
  );

  return GoRouter(
    initialLocation: StatusBar.routeName,
    routes: [baseRoute],
  );
});

class ResizableWidget extends ConsumerWidget {
  final Widget child;

  const ResizableWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final window = ref.watch(windowManagerProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        decoration: const ShapeDecoration(
          shape: IslandShape(),
          color: Colors.black,
          shadows: [
            BoxShadow(
              color: Color.fromARGB(255, 22, 22, 22),
              blurRadius: 4,
              offset: .zero,
            ),
          ],
        ),
        width: window.width,
        height: window.height,
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
    );
  }
}
