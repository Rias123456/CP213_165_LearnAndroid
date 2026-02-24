import 'package:flutter/material.dart';

class ColonAlignedHourHeaderPainter extends CustomPainter {
  ColonAlignedHourHeaderPainter({
    required this.labels,
    required this.leftGutter,
    required this.slotWidth,
    required this.textStyle,
    this.bottomPadding = 4,
  });

  final List<String> labels;
  final double leftGutter;
  final double slotWidth;
  final TextStyle textStyle;
  final double bottomPadding;

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty) {
      return;
    }

    const textDirection = TextDirection.ltr;
    final double baselineOffset;
    if (bottomPadding <= 0) {
      baselineOffset = 0;
    } else if (bottomPadding >= size.height) {
      baselineOffset = size.height;
    } else {
      baselineOffset = bottomPadding;
    }

    for (var index = 0; index < labels.length; index++) {
      final label = labels[index];
      final colonIndex = label.indexOf(':');
      if (colonIndex == -1) {
        continue;
      }

      final fullPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: textDirection,
      )..layout();

      double prefixWidth = 0;
      if (colonIndex > 0) {
        final beforeColon = label.substring(0, colonIndex);
        final prefixPainter = TextPainter(
          text: TextSpan(text: beforeColon, style: textStyle),
          textDirection: textDirection,
        )..layout();
        prefixWidth = prefixPainter.width;
      }

      final gridLineX = leftGutter + slotWidth * index;
      final finalX = gridLineX - prefixWidth;
      final double rawTopY = size.height - baselineOffset - fullPainter.height;
      final double topY;
      if (rawTopY <= 0) {
        topY = 0;
      } else if (rawTopY + fullPainter.height >= size.height) {
        topY = size.height - fullPainter.height;
      } else {
        topY = rawTopY;
      }

      fullPainter.paint(canvas, Offset(finalX, topY));
    }
  }

  @override
  bool shouldRepaint(covariant ColonAlignedHourHeaderPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.leftGutter != leftGutter ||
        oldDelegate.slotWidth != slotWidth ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.bottomPadding != bottomPadding;
  }
}
