import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Keeps [child] at least [minWidth] wide.
///
/// Above [minWidth] the child fills the available width as usual. Below it,
/// the child stays at [minWidth] and the view scrolls horizontally, the same
/// way a vertical [SingleChildScrollView] behaves when content is too tall.
class MinWidthScroll extends StatelessWidget {
  const MinWidthScroll({
    super.key,
    required this.child,
    this.minWidth = 400,
  });

  final Widget child;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, minWidth);
        final needsScroll = width > constraints.maxWidth;

        return ScrollConfiguration(
          behavior: const _DragEverywhereScrollBehavior(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: needsScroll
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Lets the horizontal view be dragged with a mouse on desktop, where the
/// default behavior only reacts to touch and shift+wheel.
class _DragEverywhereScrollBehavior extends MaterialScrollBehavior {
  const _DragEverywhereScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
