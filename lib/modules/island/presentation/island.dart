import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moore/core/providers/window_manager_provider.dart';
import 'package:moore/modules/island/presentation/widgets/calendar.dart';
import 'package:moore/modules/island/presentation/widgets/clock_widget.dart';
import 'package:moore/modules/island/presentation/widgets/media_player.dart';
import 'package:moore/modules/island/presentation/widgets/notifications.dart';
import 'package:moore/modules/island/presentation/widgets/volume_control.dart';
import 'package:moore/modules/status/presentation/status_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Island extends ConsumerStatefulWidget {
  static const String routeName = '/island';
  final Widget child;

  const Island({super.key, required this.child});

  @override
  ConsumerState<Island> createState() => _IslandState();
}

class _IslandState extends ConsumerState<Island> {
  late final WindowManager windowManager;

  @override
  void initState() {
    super.initState();
    windowManager = ref.read(windowManagerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      windowManager.updateWindowSizeAndCenter(600, 180);
      windowManager.setAlwaysOnTop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: ModalRoute.of(context)?.isCurrent == false,
      child: MouseRegion(
        onExit: (_) async {
          windowManager.resetWindowSize();
          if (context.mounted) context.go(StatusBar.routeName);
        },
        child: Padding(
          padding: const .fromLTRB(
            20.0,
            4,
            20.0,
            8,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: .center,
                children: [
                  IconButton(
                    onPressed: () => context.go(StartPage.routeName),
                    icon: Icon(
                      PhosphorIcons.monitorPlay(PhosphorIconsStyle.duotone),
                      size: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go(CalendarPage.routeName),
                    icon: Icon(
                      PhosphorIcons.calendar(PhosphorIconsStyle.duotone),
                      size: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go(VolumeControl.routeName),
                    icon: Icon(
                      PhosphorIcons.equalizer(PhosphorIconsStyle.duotone),
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  const ClockWidget(),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  static const String routeName = '/island';

  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: MediaPlayer()),
        SizedBox(width: 8),
        Expanded(child: Notifications()),
      ],
    );
  }
}

class CalendarPage extends StatelessWidget {
  static const String routeName = '/island/calendar';

  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomCalendar();
  }
}
