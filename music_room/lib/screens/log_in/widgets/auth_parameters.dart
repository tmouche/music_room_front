import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/screens/log_in/widgets/auth_field.dart';
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
                icon: Icon(Icons.person, color: Coloring.onSurfaceVarient,),
                hint: 'your_username',
                controller: _usernameCtrl,
                textInputAction: TextInputAction.next,
              ),
            AuthField(
              title: 'Email',
              icon: Icon(Icons.mail, color: Coloring.onSurfaceVarient,),
              hint: 'your@email.com',
              controller: _emailCtrl,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
            ),
            AuthField(
              title: 'Password',
              icon: Icon(Icons.lock, color: Coloring.onSurfaceVarient,),
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

class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.knowUser,
    required this.onTap,
  });

  final bool knowUser;
  final VoidCallback onTap;

  Widget  _buildSwitchButton({
    required String text,
    required bool selected,
    required VoidCallback onTap
  }) {
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
        onPressed: onTap,
        child: Text(text, style: Texting.titleSmall),
      ),
    );
  }

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
            child: _buildSwitchButton(
              text: 'Log In',
              selected: knowUser,
              onTap: onTap,
            ),
          ),
          Expanded(
            child: _buildSwitchButton(
              text: 'Sign Up',
              selected: !knowUser,
              onTap: onTap,
            ),
          )
        ],
      ),
    );
  }
}
