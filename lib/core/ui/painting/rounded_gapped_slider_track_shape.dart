import 'dart:math' as math;

import 'package:flutter/material.dart';

class RoundedGappedSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final double borderRadius;

  /// Create a slider track that draws two rectangles with rounded outer edges.
  const RoundedGappedSliderTrackShape({this.borderRadius = 6.0});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(sliderTheme.trackGap != null);
    assert(!sliderTheme.trackGap!.isNegative);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final inactiveTrackColorTween = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );
    final activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
    }

    // Gap, starting from the middle of the thumb.
    final double trackGap = sliderTheme.trackGap!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final trackCornerRadius = Radius.circular(borderRadius);
    const trackInsideCornerRadius = Radius.circular(2.0);

    final trackRRect = RRect.fromRectAndCorners(
      trackRect,
      topLeft: trackCornerRadius,
      bottomLeft: trackCornerRadius,
      topRight: trackCornerRadius,
      bottomRight: trackCornerRadius,
    );

    final leftRRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      trackRect.top,
      math.max(trackRect.left, thumbCenter.dx - trackGap),
      trackRect.bottom,
      topLeft: trackCornerRadius,
      bottomLeft: trackCornerRadius,
      topRight: trackInsideCornerRadius,
      bottomRight: trackInsideCornerRadius,
    );

    final rightRRect = RRect.fromLTRBAndCorners(
      thumbCenter.dx + trackGap,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      topRight: trackCornerRadius,
      bottomRight: trackCornerRadius,
      topLeft: trackInsideCornerRadius,
      bottomLeft: trackInsideCornerRadius,
    );

    context.canvas
      ..save()
      ..clipRRect(trackRRect);
    final bool drawLeftTrack = thumbCenter.dx > (leftRRect.left + (sliderTheme.trackHeight! / 2));
    final bool drawRightTrack =
        thumbCenter.dx < (rightRRect.right - (sliderTheme.trackHeight! / 2));
    if (drawLeftTrack) {
      context.canvas.drawRRect(leftRRect, leftTrackPaint);
    }
    if (drawRightTrack) {
      context.canvas.drawRRect(rightRRect, rightTrackPaint);
    }

    final isLTR = textDirection == TextDirection.ltr;
    final bool showSecondaryTrack =
        (secondaryOffset != null) &&
        switch (isLTR) {
          true => secondaryOffset.dx > thumbCenter.dx + trackGap,
          false => secondaryOffset.dx < thumbCenter.dx - trackGap,
        };

    if (showSecondaryTrack) {
      final secondaryTrackColorTween = ColorTween(
        begin: sliderTheme.disabledSecondaryActiveTrackColor,
        end: sliderTheme.secondaryActiveTrackColor,
      );
      final secondaryTrackPaint = Paint()
        ..color = secondaryTrackColorTween.evaluate(enableAnimation)!;
      if (isLTR) {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            thumbCenter.dx + trackGap,
            trackRect.top,
            secondaryOffset.dx,
            trackRect.bottom,
            topLeft: trackInsideCornerRadius,
            bottomLeft: trackInsideCornerRadius,
            topRight: trackCornerRadius,
            bottomRight: trackCornerRadius,
          ),
          secondaryTrackPaint,
        );
      } else {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            secondaryOffset.dx - trackGap,
            trackRect.top,
            thumbCenter.dx,
            trackRect.bottom,
            topLeft: trackInsideCornerRadius,
            bottomLeft: trackInsideCornerRadius,
            topRight: trackCornerRadius,
            bottomRight: trackCornerRadius,
          ),
          secondaryTrackPaint,
        );
      }
    }
    context.canvas.restore();

    const stopIndicatorRadius = 2.0;
    final double stopIndicatorTrailingSpace = sliderTheme.trackHeight! / 2;
    final stopIndicatorOffset = Offset(
      (textDirection == TextDirection.ltr)
          ? trackRect.centerRight.dx - stopIndicatorTrailingSpace
          : trackRect.centerLeft.dx + stopIndicatorTrailingSpace,
      trackRect.center.dy,
    );

    final bool showStopIndicator = (textDirection == TextDirection.ltr)
        ? thumbCenter.dx < stopIndicatorOffset.dx
        : thumbCenter.dx > stopIndicatorOffset.dx;
    if (showStopIndicator && !isDiscrete) {
      final stopIndicatorRect = Rect.fromCircle(
        center: stopIndicatorOffset,
        radius: stopIndicatorRadius,
      );
      context.canvas.drawCircle(stopIndicatorRect.center, stopIndicatorRadius, activePaint);
    }
  }

  @override
  bool get isRounded => true;
}
