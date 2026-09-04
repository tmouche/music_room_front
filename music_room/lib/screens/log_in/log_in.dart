import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/regex.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/log_in/widgets/auth_switch.dart';
import 'package:music_room/screens/log_in/widgets/logo_global.dart';
import 'widgets/auth_parameters.dart';

class LogInPage extends ConsumerStatefulWidget {
  const LogInPage({super.key});

  @override
  ConsumerState<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends ConsumerState<LogInPage> {
  bool knowUser = true;

  final _usernameController = TextEditingController();
  final _usernameShakeKey = GlobalKey<AuthFieldState>();
  final _emailController = TextEditingController();
  final _emailShakeKey = GlobalKey<AuthFieldState>();
  final _passwordController = TextEditingController();
  final _passwordShakeKey = GlobalKey<AuthFieldState>();

  bool _isLoading = false;
  bool _askedReset = false;

  void _onSignInSelected() {
    setState(() {
      knowUser = false;
      _passwordController.clear();
    });
  }

  void _onLogInSelected() {
    setState(() {
      knowUser = true;
      _passwordController.clear();
    });
  }

  void __emailFormatUtils() {
    if (mounted) {
      UiUtils.showHintBanner(
        context, 
        'Invalid Email',
        description: 'The Email format is wrong try something like xxxxxxxx@xxxx.xxx'
      );
    }
  }

  void  _onServerErrorUtils(String message) {
      logger.debug(message);
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
  }

  Future<void>  _resetPasswordHandler() async {
    if (_askedReset) return;
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      if (mounted) {_emailShakeKey.currentState?.shake();}
      return ;
    }
    if (!isValidEmail(email)) {
      __emailFormatUtils();
      return ;
    }
    setState(() => _isLoading = true);
    try {
      ref.read(authProvider.notifier).forgotPassword(email);
      if (mounted) setState(() => _askedReset = true);
    } catch (exc) {
      _onServerErrorUtils('Error LogIn screen reset password: $exc');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onLogIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    if (email.isEmpty || !isValidEmail(email)) {
      _emailShakeKey.currentState?.shake();
      return ;
    }
    if (password.isEmpty) {
      _passwordShakeKey.currentState?.shake();
      return ;
    }
    if (!isValidEmail(email)) {
      __emailFormatUtils();
      return ;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(email, password);
    } on ApiException catch (e) {
      logger.debug('API Error on log in: $e');
        if (mounted) {
          UiUtils.showHintBanner(
          context, 
          e.message,
        );
      }
    } catch (e) {
      logger.debug('Error on log in: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onCreateAccount() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String username = _usernameController.text.trim();
    if (email.isEmpty) {
      _emailShakeKey.currentState?.shake();
      return ;
    }
    if (password.isEmpty) {
      _passwordShakeKey.currentState?.shake();
      return ;
    }
    if (username.isEmpty) {
      _usernameShakeKey.currentState?.shake();
      return ;
    }
    if (!isValidEmail(email)) {
      __emailFormatUtils();
      return ;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signin(username, email, password);
    } on ApiException catch (e) {
      if (mounted) UiUtils.showError(context, e.message);
    } catch (e) {

      _onServerErrorUtils('Error on sign in: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    return ;
  }

  Future<void> _onGoogleSSO() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).loginGoogle();
    } on ApiException catch (e) {
      if (mounted) UiUtils.showError(context, e.message);
    } catch (e) {
      if (mounted) {
        UiUtils.showError(context, 'An unexpected error occured, Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    return ;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;

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
                      AuthSwitch(
                        knowUser: knowUser,
                        onLogin: _onLogInSelected,
                        onSignup: _onSignInSelected
                      ),
                      SizedBox(height: Spacing.md),
                      AuthParameters(
                        knowUser: knowUser,
                        usernameController: _usernameController,
                        usernameShakeKey: _usernameShakeKey,
                        emailController: _emailController,
                        emailShakeKey: _emailShakeKey,
                        passwordController: _passwordController,
                        passwordShakeKey: _passwordShakeKey,
                      ),
                      const SizedBox(height: Spacing.xl),
                      Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              appColor.secondary,
                              appColor.primary,
                            ]
                          ),
                        ),
                        child: TextButton(
                          onPressed: _isLoading ? null : knowUser ? _onLogIn : _onCreateAccount, 
                          child: Text(
                            knowUser ? 'Log In' : 'Create Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: appColor.onSecondary)
                          )
                        )
                      ),
                      const SizedBox(height: Spacing.xs),
                      if (knowUser)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _isLoading || _askedReset ? null : _resetPasswordHandler, 
                          child: !_askedReset
                            ? Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: appColor.secondary, 
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
                                  onPressed: _onGoogleSSO,
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
