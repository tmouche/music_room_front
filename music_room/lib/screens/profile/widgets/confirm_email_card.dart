import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/features/auth/provider.dart';

class ConfirmEmailCard extends ConsumerStatefulWidget {
  const ConfirmEmailCard({super.key});

  @override
  ConsumerState<ConfirmEmailCard> createState() => _ConfirmEmailCardState();
}

class _ConfirmEmailCardState extends ConsumerState<ConfirmEmailCard> {
  bool _isLoading = false;

  Future<void>  _onResendEmail() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
    return ;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Coloring.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        spacing: Spacing.sm2,
        children: [
          Icon(CupertinoIcons.mail, size: 30, color: Coloring.tertiary,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Verify your email", style: Texting.titleMiddle.copyWith(color: Coloring.tertiary)),
                Text("Confirm ${authState.user!.email} to unlock rooms", style: Texting.bodyMedium),
                TextButton(
                  onPressed: _isLoading ? null : _onResendEmail,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    "Resend",
                    style: Texting.titleMiddle.copyWith(color: Coloring.tertiary)
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
