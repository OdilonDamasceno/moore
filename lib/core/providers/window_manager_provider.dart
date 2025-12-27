import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final windowManagerProvider = NotifierProvider(WindowManager.new);

class WindowManager extends Notifier<Window> {
  final channel = const MethodChannel('moore/resize');

  @override
  build() => Window(width: 240, height: 32);

  void updateWindowSize(double width, double height) {
    state = state.copyWith(width: width, height: height);
    channel.invokeMethod('setSize', [width.toInt(), height.toInt()]);
  }

  void updateWindowSizeAndCenter(double width, double height) {
    state = state.copyWith(width: width, height: height);
    channel.invokeMethod('setSizeAndCenter', [width.toInt(), height.toInt()]);
  }

  void resetWindowSize() {
    state = state.copyWith(width: 240.0, height: 32.0);
    channel.invokeMethod('resetSize');
  }

  void setAlwaysOnTop(bool alwaysOnTop) {
    state = state.copyWith(alwaysOnTop: alwaysOnTop);
    channel.invokeMethod('setAlwaysOnTop', alwaysOnTop);
  }
}

class Window {
  double width;
  double height;
  bool alwaysOnTop;

  Window({required this.width, required this.height, this.alwaysOnTop = true});

  Window copyWith({double? width, double? height, bool? alwaysOnTop}) {
    return Window(
      width: width ?? this.width,
      height: height ?? this.height,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
    );
  }
}
