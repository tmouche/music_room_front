import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/log_in/provider.dart';
import 'package:music_room/screens/log_in/widgets/logo_global.dart';
import 'widgets/auth_parameters.dart';

class LogInPage extends ConsumerStatefulWidget {
  const LogInPage({super.key});

  @override
  ConsumerState<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends ConsumerState<LogInPage> {
  Future<void> _onGoogleSSO() async {
    try {
      await ref.read(loginBusyProvider.notifier).run(
        () => ref.read(authProvider.notifier).loginGoogle()
      );
    } on ApiException catch (apiExc) {
      logger.debug('Api Error on Google Auth: $apiExc');
      if (mounted) {
        UiUtils.showHintBanner(
          context, 
          apiExc.message,
        );
      }
    } catch (e) {
      logger.debug('Internal Server Error on Google Auth: $e');
      if (mounted) UiUtils.showErrorBanner(context, 'Internal Server Error.');
    }
    return ;
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;
    final busy = ref.watch(loginBusyProvider);
    return Scaffold(
      backgroundColor: appColor.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoGlobal(),
                const SizedBox(height: Spacing.xl),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  padding: EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: appColor.onSurfaceVariant.withValues(alpha: 0.15), width: 1),
                    color: Colors.transparent
                  ),
                  child: Column(
                    children: [
                      AuthParameters(),
                      const SizedBox(height: Spacing.md - Spacing.xs),
                      Row(
                        children: [
                          Expanded(child: Divider(color: appColor.onSurfaceVariant)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: appText.bodyMedium),
                          ),
                          Expanded(child: Divider(color: appColor.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: Spacing.md-Spacing.xs),
                      SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                margin: EdgeInsets.all(Spacing.xs),
                                decoration: BoxDecoration(
                                  color: appColor.onSurfaceVariant.withValues(alpha: 0.15),
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
                                      Text('Google', style: TextStyle(fontSize: 14, color: appColor.onSecondary))
                                    ],
                                  )
                                ),
                              )
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                    child: Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      style: appText.bodySmall,
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
