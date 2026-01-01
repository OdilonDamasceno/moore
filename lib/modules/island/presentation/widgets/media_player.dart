import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moore/core/providers/audio_manager_provider.dart';
import 'package:moore/core/ui/themes/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:playerctl/core/media_player_manager.dart';

class MediaPlayer extends ConsumerWidget {
  const MediaPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaPlayer = ref.watch(audioHandlerProvider);
    final textTheme = Theme.of(context).textTheme;
    final mediaManager = MediaPlayerManager();

    return mediaPlayer.when(
      data: (state) {
        final isPlaying = state.currentMedia.status == "Playing";

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.grey.shade900.withAlpha(150)),
            color: AppColors.black10,
            image: DecorationImage(
              image: NetworkImage(state.currentMedia.artUrl ?? ''),
              onError: (_, _) {},
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                AppColors.black.withAlpha(200),
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: .min,
                          mainAxisAlignment: .center,
                          crossAxisAlignment: .start,
                          children: [
                            Expanded(
                              child: Text(
                                state.currentMedia.playerName.toUpperCase(),
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                state.currentMedia.title,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                state.currentMedia.artist,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: Icon(PhosphorIcons.skipBack(), color: Colors.white),
                                onPressed: mediaManager.previous,
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: Icon(
                                  isPlaying ? PhosphorIcons.pause() : PhosphorIcons.play(),
                                  color: Colors.white,
                                ),
                                onPressed: isPlaying ? mediaManager.pause : mediaManager.play,
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: Icon(PhosphorIcons.skipForward(), color: Colors.white),
                                onPressed: mediaManager.next,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SimpleBar(
                  value: state.currentMedia.position?.toDouble() ?? 0.0,
                  max: state.currentMedia.length?.toDouble() ?? 1.0,
                ),
              ],
            ),
          ),
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class SimpleBar extends StatelessWidget {
  final double value;
  final double max;

  const SimpleBar({
    super.key,
    required this.value,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value / max).clamp(0.0, 1.0);

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: percent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
