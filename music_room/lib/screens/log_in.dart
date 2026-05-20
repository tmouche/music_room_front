import 'package:flutter/material.dart';
import 'package:music_room/app/theme/text_theme.dart';
import '../app/theme/colors.dart';
import '../app/theme/spacing.dart';
import '../components/widgets/gradient_text.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool knowUser = true;

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

  void _resetPasswordHandler() {
    return ;
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
    return Scaffold(
      backgroundColor: appColorSheme().surface,
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
                        appColorSheme().primary,
                        appColorSheme().secondary,
                        appColorSheme().tertiary,
                      ]
                    ),
                  ),
                  child: const Icon(Icons.queue_music, size: 38, color: Colors.white),
                ),
                const SizedBox(height: Spacing.md),
                GradientText(
                  'Music Room',
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      appColorSheme().primary,
                      appColorSheme().secondary,
                      appColorSheme().tertiary,
                    ]
                  )
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Listen Together, Anytime',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appColorSheme().onSurfaceVariant,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  padding: EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: appColorSheme().onSurfaceVariant.withValues(alpha: 0.15), width: 1),
                    color: Colors.transparent
                  ),
                  child: Column(
                    children: [
                      AuthSwith(
                        knowUser: knowUser,
                        onLogin: _onLogInSelected,
                        onSignup: _onSignInSelected
                      ),
                      if (!knowUser)
                        SizedBox(
                          child: Column(
                            children: [
                              SizedBox(height: Spacing.md),
                              SizedBox(
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            'Username',
                                            style: appTextTheme().titleSmall,
                                        )
                                      ),
                                      SizedBox(height: Spacing.sm),
                                      SizedBox(
                                        height: 45,
                                        child: TextField(
                                          obscureText: false,
                                          style: TextStyle(fontSize: 13, color: appColorSheme().onSurfaceVariant),
                                          cursorColor: appColorSheme().onSurface,
                                          cursorWidth: 1,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.person, color: appColorSheme().onSurfaceVariant,),
                                            filled: true,
                                            fillColor: appColorSheme().onSurfaceVariant.withValues(alpha: 0.15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            hintText: 'your_username',
                                            hintStyle: TextStyle(fontSize: 13),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 2, color: appColorSheme().secondary.withAlpha(150)),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                        )
                                      )
                                    ],
                                  ),
                              ),
                            ],
                          )
                        ),
                      SizedBox(height: Spacing.md),
                      SizedBox(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    'Email',
                                    style: appTextTheme().titleSmall,
                                )
                              ),
                              SizedBox(height: Spacing.sm),
                              SizedBox(
                                height: 45,
                                child: TextField(
                                  obscureText: false,
                                  style: TextStyle(fontSize: 13, color: appColorSheme().onSurfaceVariant),
                                  cursorColor: appColorSheme().onSurface,
                                  cursorWidth: 1,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.mail, color: appColorSheme().onSurfaceVariant,),
                                    filled: true,
                                    fillColor: appColorSheme().onSurfaceVariant.withValues(alpha: 0.15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    hintText: 'your@email.com',
                                    hintStyle: TextStyle(fontSize: 13),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2, color: appColorSheme().secondary.withAlpha(150)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                )
                              )
                            ],
                          ),
                      ),
                      SizedBox(height: Spacing.md),
                      SizedBox(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Password', style: appTextTheme().titleSmall),
                                if (knowUser)
                                  SizedBox(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero
                                      ),
                                      onPressed: _resetPasswordHandler, 
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: appColorSheme().secondary, 
                                          fontSize: 12,
                                        )
                                      )
                                    )
                                  )
                              ],
                            ),
                            SizedBox(height: Spacing.sm),
                            SizedBox(
                              height: 45,
                              child: TextField(
                                obscureText: true,
                                style: TextStyle(fontSize: 13, color: appColorSheme().onSurfaceVariant),
                                cursorColor: appColorSheme().onSurface,
                                cursorWidth: 1,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock, color: appColorSheme().onSurfaceVariant,),
                                  filled: true,
                                  fillColor: appColorSheme().onSurfaceVariant.withValues(alpha: 0.15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  hintText: '•••••••••',
                                  hintStyle: TextStyle(fontSize: 13),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2, color: appColorSheme().secondary.withAlpha(150)),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              )
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),
                      Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              appColorSheme().secondary,
                              appColorSheme().primary,
                            ]
                          ),
                        ),
                        child: TextButton(
                          onPressed: knowUser ? _onLogIn : _onCreateAccount, 
                          child: Text(
                            knowUser ? 'Log In' : 'Create Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: appColorSheme().onSecondary)
                          )
                        )
                      ),
                      const SizedBox(height: Spacing.md),
                      Row(
                        children: [
                          Expanded(child: Divider(color: appColorSheme().onSurfaceVariant)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: appTextTheme().bodyMedium),
                          ),
                          Expanded(child: Divider(color: appColorSheme().onSurfaceVariant)),
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
                                  color: appColorSheme().onSurfaceVariant.withValues(alpha: 0.15),
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
                                      Text('Google', style: TextStyle(fontSize: 14, color: appColorSheme().onSecondary))
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
                      style: appTextTheme().bodySmall,
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



class AuthSwith extends StatelessWidget {
  const AuthSwith({
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
        child: Text(text, style: appTextTheme().titleSmall),
      ),
    );
  }


}