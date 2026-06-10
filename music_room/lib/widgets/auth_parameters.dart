import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/texting.dart';
import '../app/theme/spacing.dart';


class AuthParameters extends StatelessWidget {
  const AuthParameters({
    super.key,
    required this.knowUser,
    required this._usernameController,
    required this._usernameShakeKey,
    required this._emailController,
    required this._emailShakeKey,
    required this._passwordController,
    required this._passwordShakeKey,
  });

  final bool knowUser;
  final TextEditingController _usernameController;
  final GlobalKey<AuthFieldState> _usernameShakeKey;
  final TextEditingController _emailController;
  final GlobalKey<AuthFieldState> _emailShakeKey;
  final TextEditingController _passwordController;
  final GlobalKey<AuthFieldState> _passwordShakeKey;

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;

    return Column(
      spacing: Spacing.md,
      children: [
        if (!knowUser)
          AuthField(
            title: 'Username',
            icon: Icon(Icons.person, color: appColor.onSurfaceVariant,),
            hint: 'your_username',
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            key: _usernameShakeKey,
          ),
        AuthField(
          title: 'Email',
          icon: Icon(Icons.mail, color: appColor.onSurfaceVariant,),
          hint: 'your@email.com',
          controller: _emailController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          key: _emailShakeKey,
        ),
        AuthField(
          title: 'Password',
          icon: Icon(Icons.lock, color: appColor.onSurfaceVariant,),
          hint: '•••••••••',
          controller: _passwordController,
          textInputAction: TextInputAction.done,
          obscureText: true,
          key: _passwordShakeKey,
        ),     
      ],
    );
  }
}

class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.title,
    required this.icon,
    required this.hint,
    required this.controller,
    required this.textInputAction,
    this.obscureText = false,
    this.keyboardType ,
  });

  final String title;
  final Icon icon;
  final String hint;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  State<AuthField> createState() => AuthFieldState();
}

class AuthFieldState extends State<AuthField>
  with SingleTickerProviderStateMixin {
    late AnimationController  _controller;
    late Animation<double>    _shakeAnimation;
    late Animation<Color?>    _colorAnimation;
    late FocusNode            _focusNode;

    bool _isFocused = false;

    @override
    void initState() {
      super.initState();

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500)
      );

      _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller);

      _colorAnimation = TweenSequence<Color?>([
        TweenSequenceItem(
          tween: ColorTween(begin: Coloring.borderPrimary, end: Coloring.borderFocused),
          weight: 50
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Coloring.borderFocused, end: Coloring.borderPrimary),
          weight: 50
        )
      ]).animate(_controller);

      _focusNode = FocusNode();
      _focusNode.addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
    }

    void shake() {
      _controller.forward(from: 0);
    }

    @override
    void dispose() {
      _controller.dispose();
      _focusNode.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        spacing: Spacing.xs,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: Texting.titleSmall,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(sin(_shakeAnimation.value * pi) * 8, 0),
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: widget.controller,
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
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          width: _isFocused ? 2 : 1,
                          color: _colorAnimation.value ?? Coloring.borderPrimary
                        ),
                      ),
                      hintText: widget.hint,
                      hintStyle: TextStyle(fontSize: 13),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Coloring.borderFocused),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  )
                )
              );
            }
          ),
        ],
      );
    }  
}
