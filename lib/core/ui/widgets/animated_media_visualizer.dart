import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moore/core/ui/themes/app_colors.dart';

class AnimatedMediaVisualizer extends StatefulWidget {
  final int bars;
  final bool isPlaying;
  final double height;
  final Color color;

  const AnimatedMediaVisualizer({
    super.key,
    this.bars = 5,
    this.isPlaying = false,
    this.height = 24,
    this.color = AppColors.primary,
  });

  @override
  State<AnimatedMediaVisualizer> createState() => _AnimatedMediaVisualizerState();
}

class _AnimatedMediaVisualizerState extends State<AnimatedMediaVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _values;
  final _random = Random();

  @override
  void initState() {
    super.initState();

    _values = List.generate(widget.bars, (_) => 0.1);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_updateBars);

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  void _updateBars() {
    setState(() {
      for (int i = 0; i < _values.length; i++) {
        _values[i] = widget.isPlaying ? 0.2 + _random.nextDouble() * 0.6 : 0.1;
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedMediaVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: .center,
        children: List.generate(widget.bars, (i) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: widget.height * _values[i],
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 1,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
