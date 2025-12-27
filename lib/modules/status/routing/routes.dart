import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moore/modules/status/presentation/status_bar.dart';

final statusRoutesProvider = Provider((_) {
  return GoRoute(
    path: StatusBar.routeName,
    builder: (context, state) => const StatusBar(),
  );
});
