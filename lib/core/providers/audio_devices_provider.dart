import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulseaudio/pulseaudio.dart';

final audioDevicesProvider = StreamNotifierProvider(
  AudioDevicesNotifier.new,
);

class AudioDevicesNotifier extends StreamNotifier<List<(PulseAudioSink, bool)>> {
  final client = PulseAudioClient();

  @override
  build() async* {
    await client.initialize();

    final serverInfo = await client.getServerInfo();

    final sinks = await client.getSinkList();
    final defaultSinkName = serverInfo.defaultSinkName;

    final sinkList = sinks.map((sink) {
      final isDefault = sink.name == defaultSinkName;
      return (sink, isDefault);
    }).toList();

    yield sinkList;
    await for (final info in client.onServerInfoChanged) {
      final updatedSinks = await client.getSinkList();
      final updatedSinkList = updatedSinks.map((sink) {
        final isDefault = sink.name == info.defaultSinkName;
        return (sink, isDefault);
      }).toList();
      yield updatedSinkList;
    }
  }

  Future<void> setDefaultSink(String sinkName) async {
    await client.setDefaultSink(sinkName);
  }

  Future<void> setVolume(String sinkName, double level) async {
    await client.setSinkVolume(sinkName, level);
  }
}
