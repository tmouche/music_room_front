
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/regex.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/log_in/provider.dart';
import 'package:music_room/screens/log_in/widgets/auth_field_controller.dart';

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

  void _onGeneralError(String log, String message) {
    logger.debug(log);
    if (mounted) {
      UiUtils.showHintBanner(
        context, 
        message,
      );
    }
  }

  void _onEmailFormatError() {
    if (mounted) {
      UiUtils.showHintBanner(
        context, 
        'Invalid Email',
        description: 'The Email format is wrong try something like xxxxxxxx@xxxx.xxx'
      );
    }
  }

  void  _onServerError(String message) {
      logger.debug(message);
      if (mounted) UiUtils.showErrorBanner(context, 'Internal Server Error.');
  }

  Future<void>  _resetPasswordHandler() async {
    if (_onPasswordReseting) return;
    if (widget.emailCtrl.isEmpty) {
      widget.emailCtrl.shake();
      return ;
    }
    if (!isValidEmail(widget.emailCtrl.value)) {
      _onEmailFormatError();
      return ;
    }
    try {
      await ref.read(loginBusyProvider.notifier).run(
        () => ref.read(authProvider.notifier).forgotPassword(widget.emailCtrl.value)
      );
      if (mounted) setState(() => _onPasswordReseting = true);
    } catch (exc) {
      _onServerError('Error LogIn screen reset password: $exc');
    }
  }

  Future<void> _onLogIn() async {
    if (widget.emailCtrl.isEmpty) {
      widget.emailCtrl.shake();
      return ;
    }
    if (widget.passwordCtrl.isEmpty) {
      widget.passwordCtrl.shake();
      return ;
    }
    if (!isValidEmail(widget.emailCtrl.value)) {
      _onEmailFormatError();
      return ;
    }
    try {
      await ref.read(loginBusyProvider.notifier).run(
        () => ref.read(authProvider.notifier).login(
          widget.emailCtrl.value,
          widget.passwordCtrl.value
        )
      );
    } on ApiException catch (apiExc) {
      _onGeneralError(
        'API Error on log in: $apiExc',
        apiExc.message
      );
    } catch (exc) {
      _onServerError('Error LogIn screen log in: $exc');
    }
  }

  Future<void> _onSignIn() async {
    if (widget.emailCtrl.isEmpty) {
      widget.emailCtrl.shake();
      return ;
    }
    if (widget.passwordCtrl.isEmpty) {
      widget.passwordCtrl.shake();
      return ;
    }
    if (widget.usernameCtrl.isEmpty) {
      widget.usernameCtrl.shake();
      return ;
    }
    if (!isValidEmail(widget.emailCtrl.value)) {
      _onEmailFormatError();
      return ;
    }
    try {
      await ref.read(loginBusyProvider.notifier).run(
        () => ref.read(authProvider.notifier).signin(
          widget.usernameCtrl.value,
          widget.emailCtrl.value,
          widget.passwordCtrl.value
        )
      );
    } on ApiException catch (apiExc) {
      _onGeneralError(
        'API Error on sign in: $apiExc',
        apiExc.message
      );
    } catch (exc) {
      _onServerError('Error on sign in: $exc');
    }
    return ;
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
