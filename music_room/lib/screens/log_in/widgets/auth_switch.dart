import 'package:flutter/material.dart';
import 'package:music_room/app/theme/spacing.dart';

class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.knowUser,
    required this.onTap,
  });

  final bool knowUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchButton(
              text: 'Log In',
              selected: knowUser,
              onPressed: onTap,
            ),
          ),
          Expanded(
            child: _SwitchButton(
              text: 'Sign Up',
              selected: !knowUser,
              onPressed: onTap,
            ),
          )
        ],
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({
    required this.text,
    required this.selected,
    required this.onPressed,
  });

  final String text;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appText = Theme.of(context).textTheme;

    return Container(
      height: 40,
      margin: const EdgeInsets.all(Spacing.xs),
      decoration: BoxDecoration(
        color: selected
          ? Colors.grey.withAlpha(50)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, style: appText.titleSmall),
      ),
    );
  }
}