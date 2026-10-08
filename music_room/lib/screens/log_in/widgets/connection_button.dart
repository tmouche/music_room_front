
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/core/utils/regex.dart';
import 'package:music_room/features/auth/controller.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/log_in/provider.dart';
import 'package:music_room/screens/log_in/widgets/auth_field.dart';

class ConnectionButton extends ConsumerStatefulWidget {
  const ConnectionButton({
    super.key,
    required this.isLoginMode,
    required this.usernameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
  });

  final bool  isLoginMode;
  final AuthFieldController usernameCtrl;
  final AuthFieldController emailCtrl;
  final AuthFieldController passwordCtrl;
  
  @override
  ConsumerState<ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends ConsumerState<ConnectionButton> {
  bool  _onPasswordReseting = false;

  BusyNotifier get _busy => ref.read(loginBusyProvider.notifier);
  AuthController get _auth => ref.read(authProvider.notifier);

  bool _validate({bool withUsername = false}) {
    if (widget.emailCtrl.isEmpty) {
      widget.emailCtrl.shake();
      return false;
    }
    if (widget.passwordCtrl.isEmpty) {
      widget.passwordCtrl.shake();
      return false;
    }
    if (withUsername && widget.usernameCtrl.isEmpty) {
      widget.usernameCtrl.shake();
      return false;
    }
    return _validateEmailFormat();
  }

  bool _validateEmailFormat() {
    if (isValidEmail(widget.emailCtrl.value)) return true;
    ref.read(notificationProvider.notifier).hint(
      'Invalid Email',
      description: 'The Email format is wrong try something like xxxxxxxx@xxxx.xxx',
    );
    return false;
  }

  Future<void>  _resetPasswordHandler() async {
    if (_onPasswordReseting) return;
    if (widget.emailCtrl.isEmpty) {
      widget.emailCtrl.shake();
      return;
    }
    if (!_validateEmailFormat()) return;

    final ok = await _busy.run(
      () => _auth.forgotPassword(widget.emailCtrl.value),
      label: 'Reset password',
    );
    if (ok && mounted) setState(() => _onPasswordReseting = true);
  }

  Future<void> _onLogIn() async {
    if (!_validate()) return;
    await _busy.run(
      () => _auth.login(widget.emailCtrl.value, widget.passwordCtrl.value),
      label: 'Log in',
      apiErrorKind: NotificationKind.hint,
    );
  }

  Future<void> _onSignIn() async {
    if (!_validate(withUsername: true)) return;
    await _busy.run(
      () => _auth.signin(
        widget.usernameCtrl.value,
        widget.emailCtrl.value,
        widget.passwordCtrl.value,
      ),
      label: 'Sign up',
      apiErrorKind: NotificationKind.hint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(loginBusyProvider);
    return Column(
      spacing: Spacing.xs,
      children: [
        Container(
          height: 45,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                Coloring.secondary,
                Coloring.primary,
              ]
            ),
          ),
          child: TextButton(
            onPressed: busy ? null : widget.isLoginMode ? _onLogIn : _onSignIn, 
            child: Text(
              widget.isLoginMode ? 'Log In' : 'Create Account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Coloring.onSurface)
            )
          )
        ),
        if (widget.isLoginMode)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            onPressed: busy || _onPasswordReseting ? null : _resetPasswordHandler, 
            child: !_onPasswordReseting
              ? Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Coloring.secondary, 
                    fontSize: 12,
                  )
              )
              : Text(
                  'Check Your Email!',
                  style: TextStyle(
                    color: Colors.green, 
                    fontSize: 12,
              )
            )
          ),
      ],
    );
  }
}
