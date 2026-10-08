import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/profile/provider.dart';

class ConfirmEmailCard extends ConsumerStatefulWidget {
  const ConfirmEmailCard({super.key});

  @override
  ConsumerState<ConfirmEmailCard> createState() => _ConfirmEmailCardState();
}

class _ConfirmEmailCardState extends ConsumerState<ConfirmEmailCard> {
  BusyNotifier get _busy => ref.read(profileBusyProvider.notifier);

  Future<void>  _onResendEmail() async {
    await _busy.run(
      () => ref.read(authProvider.notifier).sendConfirmationEmail(),
      label: 'Resend Email',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final busy = ref.watch(profileBusyProvider);
    final isSent = authState.isConfirmationEmailSent;
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
                  onPressed: busy || isSent ? null : _onResendEmail,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    isSent ? "Email sent" : "Resend",
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
