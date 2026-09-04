
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/widgets/separator.dart';

class ProfileSettingsModal extends ConsumerStatefulWidget {
  const ProfileSettingsModal({super.key});

  @override
  ConsumerState<ProfileSettingsModal> createState() => _ProfileSettingsModal();
}

class _ProfileSettingsModal extends ConsumerState<ProfileSettingsModal> {
  bool          hasChanged = false;
  bool          isLoading = false;
  late String   privacyLevel; 

  late String _initialUsername;
  late String _initialEmail;
  late String _initialPrivacy;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordCurrentController = TextEditingController();
  final _passwordNewController = TextEditingController();

  static const String publicPrivacy = 'Public';
  static const String friendsPrivacy = 'Friends'; 
  static const String privatePrivacy = 'Private'; 

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user!;
    _initialUsername = user.username;
    _initialEmail = user.email ?? '';
    _initialPrivacy = user.privacyLevel;
    privacyLevel = _initialPrivacy;
    _usernameController.text = _initialUsername;
    _emailController.text = _initialEmail;
    _usernameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _passwordNewController.addListener(_onFieldChanged);
  }

  Future<void>  _onSaveUsername(String newUsername) async {
    try {
      ref.read(authProvider.notifier).updateUsername(newUsername);
    } on ApiException catch (e) {
      logger.debug('API Error on username changement: $e');
      if (mounted) UiUtils.showError(context, 'Username Changement, Server Error.');
    } catch (e) {
      logger.debug('Error on username changement: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    }
  }

  Future<void>  _onSaveEmail(String newEmail) async {
    try {
      ref.read(authProvider.notifier).updateEmail(newEmail);
    } on ApiException catch (e) {
      logger.debug('API Error on username changement: $e');
      if (mounted) UiUtils.showError(context, 'Username Changement, Server Error.');
    } catch (e) {
      logger.debug('Error on username changement: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    }
  }

  Future<void>  _onSavePassword(String currentPassword, String newPassword) async {
    try {
      ref.read(authProvider.notifier).updatePassword(currentPassword, newPassword);
    } on ApiException catch (e) {
      logger.debug('API Error on username changement: $e');
      if (mounted) UiUtils.showError(context, 'Username Changement, Server Error.');
    } catch (e) {
      logger.debug('Error on username changement: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    }
  }

  Future<void>  _onSavePrivacy() async {}
  
  Future<void>  _onSave() async {
    final String newUsername = _usernameController.text.trim();
    final String newEmail = _emailController.text.trim();
    final String currentPassword = _passwordNewController.text.trim();
    final String newPassword = _passwordNewController.text.trim();
    setState(() => isLoading = true);
    try {
      if (newUsername != _initialUsername) {await _onSaveUsername(newUsername);}
      if (newEmail != _initialEmail) {await _onSaveEmail(newEmail);}
      if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {await _onSavePassword(currentPassword, newPassword);}
      if (privacyLevel != _initialPrivacy) {await _onSavePrivacy();}
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void  _onFieldChanged() {
    final changed = _usernameController.text != _initialUsername
        || _emailController.text != _initialEmail
        || (_passwordCurrentController.text.isNotEmpty && _passwordNewController.text.length >= 8) 
        || privacyLevel != _initialPrivacy;
    if (changed != hasChanged) setState(() => hasChanged = changed);
  }

  void  changePrivacyLevel(String newLevel) {
    setState(() => privacyLevel = newLevel);
    _onFieldChanged();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget  _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Edit profile', style: Texting.titleMiddle,),
        TextButton(
          onPressed: _onSave,
          child: Text(
            'Save',
            style: hasChanged ? Texting.bodyMedium.copyWith(color: Coloring.primary.shade300) : Texting.bodyMedium 
          )
        )
      ],
    );
  }

  Widget  __buildAccountTextField({
    required String field,
    required TextEditingController controller,
    String? hint,
    bool isObscure = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(field, style: Texting.bodyMedium,)
        ),
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.next,
            obscureText: isObscure,
            style: Texting.bodyMediumAccent,
            cursorColor: Coloring.onSurface,
            cursorWidth: 1,
            inputFormatters: [
              LengthLimitingTextInputFormatter(30),
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
            ),
          )
        )
      ],
    );
  }


  Widget  _buildAccount() {
    return Column(
      spacing: Spacing.sm,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text('ACCOUNT', style: Texting.bodyMedium)
        ),
        Container(
          padding: EdgeInsets.fromLTRB(Spacing.sm2, Spacing.sm2, 0, Spacing.sm2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Coloring.onSurfaceVarientMuted,
          ),
          child: Column(
            spacing: Spacing.sm2,
            children: [
              __buildAccountTextField(field:'Username', controller: _usernameController),
              tightSeparator(),
              __buildAccountTextField(field:'Email', controller: _emailController)
            ],
          ),
        ),
      ],        
    );
  }

  Widget  _buildPassword() {
    return Column(
      spacing: Spacing.sm,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text('PASSWORD', style: Texting.bodyMedium)
        ),
        Container(
          padding: EdgeInsets.fromLTRB(Spacing.sm2, Spacing.sm2, 0, Spacing.sm2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Coloring.onSurfaceVarientMuted,
          ),
          child: Column(
            spacing: Spacing.sm2,
            children: [
              __buildAccountTextField(field:'Current', controller: _passwordCurrentController, hint: '••••••••', isObscure: true),
              tightSeparator(),
              __buildAccountTextField(field:'New', controller: _passwordNewController, hint: 'At least 8 characters', isObscure: true)
            ],
          ),
        ),
      ],        
    );
  }

  Widget __buildPrivacyChoose({
    required VoidCallback onTap,
    required Color color,
    required Icon icon,
    required String title,
    required String description,
    required bool isChoosed
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: Colors.transparent,
        enabledMouseCursor: SystemMouseCursors.click
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isChoosed ? color.withValues(alpha: 0.10) : Colors.transparent
        ),
        padding: EdgeInsets.all(Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: Spacing.md,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isChoosed ? color : Coloring.onSurfaceVarientMuted,
              ),
              child: icon,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Texting.titleMiddle,),
                  Text(description, style: Texting.bodyMedium,),
                ],
              ),
            ),
            if (isChoosed) Container(
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45),
                color: color,
              ),
              child: Icon(Icons.check, size: 15, color: Coloring.onSurface,),
            )
          ],
        ),
      )
    );
  }

  Widget  _buildProfilePrivacy() {
    return Column(
      spacing: Spacing.sm,
      children: [
       Container(
          alignment: Alignment.centerLeft,
          child: Text('PROFILE PRIVACY', style: Texting.bodyMedium)
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Coloring.onSurfaceVarientMuted,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: [
                __buildPrivacyChoose(
                  onTap: () {changePrivacyLevel(publicPrivacy);},
                  color: Coloring.tertiary.shade700,
                  icon: Icon(CupertinoIcons.globe, color: Coloring.onSurface, size: 25,),
                  title: publicPrivacy,
                  description: "Anyone on Music Room sees your taste and rooms.",
                  isChoosed: privacyLevel == publicPrivacy,
                ),
                tightSeparator(),
                __buildPrivacyChoose(
                  onTap: () {changePrivacyLevel(friendsPrivacy);},
                  color:Coloring.primary.shade700,
                  icon: Icon(CupertinoIcons.person_2, color: Coloring.onSurface, size: 25,),
                  title: friendsPrivacy,
                  description: "Only your friends see your taste and activity.",
                  isChoosed: privacyLevel == friendsPrivacy,
                ),
                tightSeparator(),
                __buildPrivacyChoose(
                  onTap: () {changePrivacyLevel(privatePrivacy);},
                  color: Coloring.secondary.shade700,
                  icon: Icon(CupertinoIcons.lock, color: Coloring.onSurface, size: 25,),
                  title: privatePrivacy,
                  description: "Only your name is visible. Everything else hidden.",
                  isChoosed: privacyLevel == privatePrivacy,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget  build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Container(
        padding: EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, Spacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          border: Border(top: BorderSide(
              color: const Color.fromARGB(255, 70, 70, 70),
            )
          ),
          color: const Color.fromARGB(255, 18, 18, 18),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Coloring.onSurfaceVarient.withValues(alpha: 0.4)
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: Spacing.lg,
                  children: [
                    _buildHeader(),
                    _buildAccount(),
                    _buildPassword(),
                    _buildProfilePrivacy()
                  ],
                )
              )
            )
          ],
        ) 
      )
    );
  }
}