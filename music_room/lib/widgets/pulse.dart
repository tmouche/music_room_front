import 'package:flutter/material.dart';

class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const PulseWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: widget.maxOpacity,
      end: widget.minOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacityAnimation, child: widget.child);
  }
}
