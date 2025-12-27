import 'package:flutter/material.dart';

class IslandShape extends ShapeBorder {
  const IslandShape({this.radius = 12.0});

  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final r = radius;

    path.moveTo(rect.left, rect.top);
    path.quadraticBezierTo(
      rect.left + r,
      rect.top,
      rect.left + r,
      rect.top + r,
    );

    path.lineTo(rect.left + r, rect.bottom - r);
    path.quadraticBezierTo(
      rect.left + r,
      rect.bottom,
      rect.left + r * 2,
      rect.bottom,
    );

    path.lineTo(rect.right - (r * 2), rect.bottom);
    path.quadraticBezierTo(
      rect.right - r,
      rect.bottom,
      rect.right - r,
      rect.bottom - r,
    );

    path.lineTo(rect.right - r, rect.top + r);
    path.quadraticBezierTo(
      rect.right - r,
      rect.top,
      rect.right,
      rect.top,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
