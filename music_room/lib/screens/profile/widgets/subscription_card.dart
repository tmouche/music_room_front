import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/screens/profile/provider.dart';

class SubscriptionCard extends ConsumerStatefulWidget {
  const SubscriptionCard({super.key});

  @override
  ConsumerState<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends ConsumerState<SubscriptionCard> {
  BusyNotifier get _busy => ref.read(profileBusyProvider.notifier);

  Future<void>  _onSub() async {
    await _busy.run(
      () => ref.read(authProvider.notifier).subscribe(),
      label: 'Subscribe',
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(profileBusyProvider);
    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Coloring.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        spacing: Spacing.sm2,
        children: [
          Icon(Icons.diamond, size: 30, color: Coloring.tertiary,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Premium Subsciption", style: Texting.titleMiddle.copyWith(color: Coloring.tertiary)),
                Text("Subscribe to the premium version to private room", style: Texting.bodyMedium),
                TextButton(
                  onPressed: busy ? null : _onSub,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    "Subscribe",
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
