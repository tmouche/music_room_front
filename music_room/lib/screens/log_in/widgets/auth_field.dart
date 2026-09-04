import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/screens/log_in/widgets/auth_field_controller.dart';

class AuthField extends ConsumerStatefulWidget {
  const AuthField({
    super.key,
    this.title,
    required this.icon,
    required this.hint,
    required this.controller,
    required this.textInputAction,
    this.obscureText = false,
    this.keyboardType,
  });

  final String? title;
  final Icon icon;
  final String hint;
  final AuthFieldController controller;
  final TextInputAction textInputAction;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  ConsumerState<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends ConsumerState<AuthField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<double> _shakeAnimation;
  late final Animation<Color?> _colorAnimation;
  late final FocusNode _focusNode;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animation);

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Coloring.borderPrimary, end: Coloring.borderFocused),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Coloring.borderFocused, end: Coloring.borderPrimary),
        weight: 50,
      ),
    ]).animate(_animation);

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);

    widget.controller.addListener(_shake);
  }

  @override
  void didUpdateWidget(AuthField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_shake);
      widget.controller.addListener(_shake);
    }
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _shake() {
    _animation.forward(from: 0);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_shake);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Spacing.xs,
      children: [
        if (widget.title != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.title!, style: Texting.titleSmall),
          ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(sin(_shakeAnimation.value * pi) * 8, 0),
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: widget.controller.text,
                  focusNode: _focusNode,
                  textInputAction: widget.textInputAction,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  style: Texting.bodyMediumAccent,
                  cursorColor: Coloring.onSurface,
                  cursorWidth: 1,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: widget.icon,
                    filled: true,
                    fillColor: Coloring.onSurfaceVarient.withValues(alpha: 0.15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: _isFocused ? 2 : 1,
                        color: _colorAnimation.value ?? Coloring.borderPrimary,
                      ),
                    ),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(fontSize: 13),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Coloring.borderFocused),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
