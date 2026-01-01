import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moore/core/providers/window_manager_provider.dart';
import 'package:moore/core/ui/painting/rounded_gapped_slider_track_shape.dart';
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
      windowManager.updateWindowSizeAndCenter(540, 220);
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
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: .stretch,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: Icon(PhosphorIcons.gps()),
                        onPressed: () {},
                        label: const Text('Open Apps'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        icon: Icon(PhosphorIcons.gps()),
                        onPressed: () {},
                        label: const Text('Open Apps'),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 24,
                    trackShape: const RoundedGappedSliderTrackShape(),
                    thumbSize: WidgetStateProperty.all(const Size(2, 30)),
                  ),
                  child: Slider(
                    padding: .zero,
                    // ignore: deprecated_member_use
                    year2023: false,
                    value: 0.1,
                    onChanged: (v) {},
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: MediaPlayer(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Notifications()),
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
