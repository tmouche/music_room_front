import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';

class SubscriptionCard extends ConsumerStatefulWidget {
  const SubscriptionCard({super.key});

  @override
  ConsumerState<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends ConsumerState<SubscriptionCard> {
  bool _isLoading = false;

  Future<void>  _onSub() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
    return ;
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _isLoading ? null : _onSub,
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
