import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playerctl/core/media_player_manager.dart';

final audioHandlerProvider = StreamProvider((ref) async* {
  final manager = MediaPlayerManager();
  await manager.initialize();
  manager.setLogLevel(.none);
  yield* manager.stateStream;
});
