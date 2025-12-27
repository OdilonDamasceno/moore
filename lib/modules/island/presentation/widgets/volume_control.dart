import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moore/core/providers/audio_devices_provider.dart';
import 'package:moore/core/providers/volume_manager_provider.dart';
import 'package:moore/core/ui/themes/app_colors.dart';
import 'package:moore/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pulseaudio/pulseaudio.dart';

class VolumeControl extends ConsumerStatefulWidget {
  static const String routeName = '/island/volume_control';

  const VolumeControl({super.key});

  @override
  ConsumerState<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends ConsumerState<VolumeControl> {
  Widget _buildVolumeControl(List<(PulseAudioSink, bool)> device) {
    final notifier = ref.read(audioDevicesProvider.notifier);

    final defaultSink = device.firstWhere((d) => d.$2).$1;
    final volume = ref.watch(volumeManagerProvider(defaultSink));
    final notifierVolume = ref.read(volumeManagerProvider(defaultSink).notifier);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      child: ListView(
        children: [
          ExpansionTile(
            minTileHeight: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Audio will play on",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            subtitle: Text(defaultSink.description),
            backgroundColor: AppColors.black10,
            collapsedBackgroundColor: AppColors.black10,
            trailing: Icon(PhosphorIcons.waveform()),
            children: device
                .map(
                  (d) => RadioGroup<PulseAudioSink>(
                    onChanged: (d) {
                      if (d != null) notifier.setDefaultSink(d.name);
                    },
                    groupValue: defaultSink,
                    child: RadioListTile<PulseAudioSink>(
                      value: d.$1,
                      title: Text(d.$1.description),
                      subtitle: Text(d.$1.name),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const .symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.musicNote(),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.volume,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Slider(
              // ignore: deprecated_member_use
              year2023: false,
              padding: .zero,
              value: volume.value?.level ?? 0.0,
              min: 0,
              max: 1,
              onChanged: (newVolume) {
                notifierVolume.setVolume(newVolume);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(audioDevicesProvider);
    return devices.when(
      data: (devices) => _buildVolumeControl(devices),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
