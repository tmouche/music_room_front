
import 'package:flutter/material.dart';
import 'dart:math';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color normalColor;
  final Color shakeColor;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.normalColor = Colors.grey,
    this.shakeColor = Colors.red,
  });

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
with SingleTickerProviderStateMixin {
  late AnimationController  _controller;
  late Animation<double>    _shakeAnimation;
  late Animation<Color?>    _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24)
      .chain(CurveTween(curve: Curves.elasticIn))
      .animate(_controller);

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: widget.normalColor, end: widget.shakeColor),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: widget.shakeColor, end: widget.normalColor),
        weight: 50
      )
    ]).animate(_controller);
  }

  void shake() {
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_shakeAnimation.value * pi) * 8, 0),
          child: child, 
        );
      },
      child: widget.child,
    );
  }
}