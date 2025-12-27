import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moore/core/providers/audio_manager_provider.dart';
import 'package:moore/core/providers/notifications_manager_provider.dart';
import 'package:moore/core/utils/debouncer.dart';
import 'package:moore/modules/island/presentation/island.dart';
import 'package:moore/modules/status/presentation/widgets/player_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum MediaStatus {
  playing("Playing"),
  paused("Paused"),
  stopped("Stopped")
  ;

  const MediaStatus(this.status);

  final String status;
}

class StatusBar extends ConsumerWidget {
  static const String routeName = '/status';
  static final Debouncer _debouncer = Debouncer(milliseconds: 300);

  const StatusBar({super.key});

  Future<void> _onHover(BuildContext context) async {
    if (context.mounted) context.go(Island.routeName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(audioHandlerProvider);
    final notification = ref.watch(notificationsManagerProvider);

    return Offstage(
      offstage: ModalRoute.of(context)?.isCurrent == false,
      child: MouseRegion(
        onEnter: (_) async {
          _debouncer.run(() {
            _onHover(context);
          });
        },
        onExit: (_) {
          _debouncer.dispose();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 6.0,
          ),
          child: Row(
            crossAxisAlignment: .center,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return media.maybeWhen(
                    orElse: () {
                      return const SizedBox.shrink();
                    },
                    data: (state) {
                      if (state.currentMedia.status == MediaStatus.stopped.status) {
                        return const SizedBox.shrink();
                      }

                      if (notification.hasValue && notification.value != null) {
                        return const SizedBox.shrink();
                      }

                      return child!;
                    },
                  );
                },
                child: const Expanded(child: PlayerWidget()),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final notification = ref.watch(notificationsManagerProvider);
                  if (!notification.hasValue || notification.value == null) {
                    return const SizedBox.shrink();
                  }

                  if (notification.value?.summary.isEmpty == true) {
                    return const SizedBox.shrink();
                  }

                  return Expanded(
                    child: Material(
                      child: Row(
                        mainAxisSize: .max,
                        crossAxisAlignment: .center,
                        children: [
                          Padding(
                            padding: const .only(
                              right: 8.0,
                              left: 4.0,
                            ),
                            child: Icon(
                              PhosphorIcons.bellRinging(),
                              size: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              notification.value?.body ?? "",
                              style: const TextStyle(
                                color: Colors.white70,
                                overflow: .ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
