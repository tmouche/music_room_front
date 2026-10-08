import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/log_in/provider.dart';
import 'package:music_room/screens/log_in/widgets/logo_global.dart';
import 'package:music_room/widgets/separator.dart';
import 'widgets/auth_parameters.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Spacing.lg,
              children: [
                LogoGlobal(),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  padding: EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Coloring.onSurfaceVarient.withValues(alpha: 0.15), width: 1),
                    color: Colors.transparent
                  ),
                  child: Column(
                    spacing: Spacing.sm,
                    children: [
                      AuthParameters(),
                      Row(
                        children: [
                          Expanded(child: separator()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: Texting.bodyMedium),
                          ),
                          Expanded(child: separator()),
                        ],
                      ),
                      const GoogleSsoButton()
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      style: Texting.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ) 
              ],
            )
          ),
        ),
      ),
    );
  }
}


class GoogleSsoButton extends ConsumerStatefulWidget {
  const GoogleSsoButton({super.key});

  @override
  ConsumerState<GoogleSsoButton>  createState() => _GoogleSsoButtonState();
}

class _GoogleSsoButtonState extends ConsumerState<GoogleSsoButton> {
  Future<void> _onGoogleSSO() async {
    await ref.read(loginBusyProvider.notifier).run(
      () => ref.read(authProvider.notifier).loginGoogle(),
      label: 'Google sign in',
      apiErrorKind: NotificationKind.hint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(loginBusyProvider);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            margin: EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: Coloring.onSurfaceVarient.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: TextButton(
              onPressed: busy ? null : _onGoogleSSO,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/google.png', height: 18, width: 18,),
                  const SizedBox(width: 8),
                  Text('Google', style: TextStyle(fontSize: 14, color: Coloring.onSurface))
                ],
              )
            ),
          )
        ),
      ],
    );
  }
}

