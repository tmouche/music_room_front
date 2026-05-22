import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/controllers/auth_controller.dart';
import '../app/theme/spacing.dart';
import '../app/utils/exception.dart';
import '../components/widgets/gradient_text.dart';

class LogInPage extends ConsumerStatefulWidget {
  const LogInPage({super.key});

  @override
  ConsumerState<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends ConsumerState<LogInPage> {
  bool knowUser = true;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _onSignInSelected() {
    setState(() {
      knowUser = false;
    });
  }

  void _onLogInSelected() {
    setState(() {
      knowUser = true;
    });
  }

  Future<void>  _resetPasswordHandler() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      // Faire vibrer la case Email en la collorant en rouge
      return ;
    }

    setState(() => _isLoading = true);

    try {
      ref.read(authProvider.notifier).forgotPassword(email);
    } on ApiException catch (e) {
      return ;
    } catch (e) {
      return ;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onLogIn() {
    return ;
  }

  void _onCreateAccount() {
    return ;
  }

    void _onGoogleSSO() {
    return ;
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
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        appColor.primary,
                        appColor.secondary,
                        appColor.tertiary,
                      ]
                    ),
                  ),
                  child: const Icon(Icons.queue_music, size: 38, color: Colors.white),
                ),
                const SizedBox(height: Spacing.sm),
                GradientText(
                  'Music Room',
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      appColor.primary,
                      appColor.secondary,
                      appColor.tertiary,
                    ]
                  )
                ),
                Text(
                  'Listen Together, Anytime',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appColor.onSurfaceVariant,
                    fontSize: 18,
                  ),
                ),
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
                        emailController: _emailController,
                        passwordController: _passwordController,
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
                          onPressed: knowUser ? _onLogIn : _onCreateAccount, 
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
                            minimumSize: Size.zero
                          ),
                          onPressed: _isLoading ? null : _resetPasswordHandler, 
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: appColor.secondary, 
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

class AuthParameters extends StatelessWidget {
  const AuthParameters({
    super.key,
    required this.knowUser,
    required this._usernameController,
    required this._emailController,
    required this._passwordController,
  });

  final bool knowUser;
  final TextEditingController _usernameController;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;

    return Column(
      spacing: Spacing.md,
      children: [
        if (!knowUser)
          _AuthField(
            title: 'Username',
            icon: Icon(Icons.person, color: appColor.onSurfaceVariant,),
            hint: 'your_username',
            controller: _usernameController,
            textInputAction: TextInputAction.next,
          ),
        _AuthField(
          title: 'Email',
          icon: Icon(Icons.mail, color: appColor.onSurfaceVariant,),
          hint: 'your@email.com',
          controller: _emailController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
        ),
        _AuthField(
          title: 'Password',
          icon: Icon(Icons.lock, color: appColor.onSurfaceVariant,),
          hint: '•••••••••',
          controller: _passwordController,
          textInputAction: TextInputAction.done,
          obscureText: true,
        ),     
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
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
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;
    
    return Column(
      spacing: Spacing.xs,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: appText.titleSmall,
          ),
        ),
        SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: TextStyle(fontSize: 13, color: appColor.onSurfaceVariant),
            cursorColor: appColor.onSurface,
            cursorWidth: 1,
            decoration: InputDecoration(
              prefixIcon: icon,
              filled: true,
              fillColor: appColor.onSurfaceVariant.withValues(alpha: 0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: appColor.secondary.withAlpha(150)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          )
        )
      ],
    );
  }
}

class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    super.key,
    required this.knowUser,
    required this.onLogin,
    required this.onSignup,
  });

  final bool knowUser;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

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
              onPressed: onLogin,
            ),
          ),
          Expanded(
            child: _SwitchButton(
              text: 'Sign Up',
              selected: !knowUser,
              onPressed: onSignup,
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