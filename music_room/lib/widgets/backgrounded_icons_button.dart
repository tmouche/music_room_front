import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';

class BackgroundedIconsButton extends ConsumerWidget {
  const BackgroundedIconsButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.bgColor = Coloring.onSurfaceVarientMuted,
    this.iconColor = Coloring.onSurface,
    this.iconSize,
    this.boxPadding,
  });

    final Color bgColor;
    final VoidCallback onPressed;
    final IconData icon;
    final Color iconColor;
    final double? iconSize;
    final double? boxPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(45)
      ),
      child: IconButton(
        iconSize: iconSize,
        padding: EdgeInsets.all(boxPadding ?? 0),
        constraints: const BoxConstraints(),
        onPressed: onPressed,
        mouseCursor: SystemMouseCursors.click,
        icon: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}

class SpinningBackgroundedIconButton extends StatefulWidget {
  const SpinningBackgroundedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.bgColor = Coloring.onSurfaceVarientMuted,
    this.iconColor = Coloring.onSurface,
    this.iconSize,
    this.boxPadding,
    this.isLoading = false,
  });
  
  final Color bgColor;
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final double? iconSize;
  final double? boxPadding;
  final bool  isLoading;
  
  @override
  State<SpinningBackgroundedIconButton> createState() => SpinningBackgroundedIconButtonState();
}

class SpinningBackgroundedIconButtonState extends State<SpinningBackgroundedIconButton> 
with SingleTickerProviderStateMixin {
  late final AnimationController  _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  
  @override
  void didUpdateWidget(SpinningBackgroundedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(45)
      ),
      child: IconButton(
        iconSize: widget.iconSize,
        padding: EdgeInsets.all(widget.boxPadding ?? 0),
        constraints: const BoxConstraints(),
        onPressed: widget.isLoading ? null : widget.onPressed,
        mouseCursor: SystemMouseCursors.click,
        icon: RotationTransition(
          turns: _rotationController,
          child: Icon(
            widget.icon,
            color: widget.iconColor,
          ),
        )
      ),
    );
  }
}