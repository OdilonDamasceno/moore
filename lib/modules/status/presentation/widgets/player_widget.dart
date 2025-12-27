import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moore/core/providers/audio_manager_provider.dart';
import 'package:moore/core/ui/widgets/animated_media_visualizer.dart';

class PlayerWidget extends ConsumerWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioHandlerProvider);
    final textTheme = Theme.of(context).textTheme;

    return playerState.when(
      data: (state) => Row(
        mainAxisSize: .min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              state.currentMedia.artUrl ?? '',
              height: 24,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                child: Icon(
                  Icons.music_note,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.currentMedia.title,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedMediaVisualizer(
            isPlaying: state.currentMedia.status == "Playing",
          ),
        ],
      ),
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
