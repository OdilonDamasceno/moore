import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moore/core/providers/audio_devices_provider.dart';
import 'package:pulseaudio/pulseaudio.dart';

final volumeManagerProvider = StreamNotifierProvider.family(
  (PulseAudioSink sink) => VolumeManager(sink),
  dependencies: [audioDevicesProvider],
);

class VolumeManager extends StreamNotifier<Volume> {
  final PulseAudioSink _sink;
  final client = PulseAudioClient();

  VolumeManager(this._sink);

  @override
  Stream<Volume> build() async* {
    await client.initialize();

    for (final sinks in await client.getSinkList()) {
      if (sinks.name == _sink.name) {
        yield Volume(sinks.volume);
        break;
      }
    }

    await for (final event in client.onSinkChanged) {
      if (event.name == _sink.name) {
        yield Volume(event.volume);
      }
    }
  }

  Future<void> setVolume(double level) async {
    final serverInfo = await client.getServerInfo();
    final sink = serverInfo.defaultSinkName;
    await client.setSinkVolume(sink, level);
  }
}

class Volume {
  final double level;
  Volume(this.level);
}
