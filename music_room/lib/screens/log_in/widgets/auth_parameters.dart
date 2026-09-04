import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/screens/log_in/widgets/auth_field.dart';
import 'package:music_room/screens/log_in/widgets/auth_field_controller.dart';
import 'package:music_room/screens/log_in/widgets/auth_switch.dart';
import 'package:music_room/screens/log_in/widgets/connection_button.dart';

class AuthParameters extends ConsumerStatefulWidget {
  const AuthParameters({super.key});

  @override
  ConsumerState<AuthParameters> createState() => _AuthParametersState();
}

class _AuthParametersState extends ConsumerState<AuthParameters> {
  bool _isLoginMode = true;

  final _usernameCtrl = AuthFieldController();
  final _emailCtrl = AuthFieldController();
  final _passwordCtrl = AuthFieldController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onToggleMode() {
    setState(() => _isLoginMode = _isLoginMode ? false : true);
    _passwordCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    return Column(
      spacing: Spacing.xl,
      children: [
        Column(
          spacing: Spacing.md,
          children: [
             AuthSwitch(
              knowUser: _isLoginMode,
              onTap: _onToggleMode,
            ),
            if (!_isLoginMode)
              AuthField(
                title: 'Username',
                icon: Icon(Icons.person, color: appColor.onSurfaceVariant,),
                hint: 'your_username',
                controller: _usernameCtrl,
                textInputAction: TextInputAction.next,
              ),
            AuthField(
              title: 'Email',
              icon: Icon(Icons.mail, color: appColor.onSurfaceVariant,),
              hint: 'your@email.com',
              controller: _emailCtrl,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
            ),
            AuthField(
              title: 'Password',
              icon: Icon(Icons.lock, color: appColor.onSurfaceVariant,),
              hint: '•••••••••',
              controller: _passwordCtrl,
              textInputAction: TextInputAction.done,
              obscureText: true,
            ),     
          ],
        ),
        ConnectionButton(
          isLoginMode: _isLoginMode,
          usernameCtrl: _usernameCtrl,
          emailCtrl: _emailCtrl,
          passwordCtrl: _passwordCtrl
        )
      ]
    );
  }
}
