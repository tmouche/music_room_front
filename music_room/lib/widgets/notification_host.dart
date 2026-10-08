import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/widgets/pulse.dart';

/// Application-level layer that draws the current [AppNotification] from
/// [notificationProvider] above [child].
///
/// It must sit outside the [Navigator] and outside any scrolling wrapper so
/// the banner stays fixed relative to the window and is never clipped. The
/// banner width is derived from the available width, never from a fixed
/// pixel value.
class NotificationHost extends ConsumerStatefulWidget {
  const NotificationHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends ConsumerState<NotificationHost> {
  /// Key of the banner currently on screen. Recreated for each notification
  /// id so a new message restarts the entrance animation and timer instead
  /// of updating the previous banner in place.
  GlobalKey<_PopBannerState>? _popKey;
  int? _popKeyId;

  GlobalKey<_PopBannerState> _keyFor(AppNotification notification) {
    if (_popKey == null || _popKeyId != notification.id) {
      _popKey = GlobalKey<_PopBannerState>();
      _popKeyId = notification.id;
    }
    return _popKey!;
  }

  static Color _colorOf(NotificationKind kind) => switch (kind) {
        NotificationKind.error => Coloring.onError,
        NotificationKind.hint => Colors.orange,
        NotificationKind.success => Coloring.onSuccess,
      };

  static IconData _iconOf(NotificationKind kind) => switch (kind) {
        NotificationKind.error => Icons.close,
        NotificationKind.hint => Icons.lightbulb_outlined,
        NotificationKind.success => Icons.check,
      };

  @override
  Widget build(BuildContext context) {
    final notification = ref.watch(notificationProvider);
    final popKey = notification == null ? null : _keyFor(notification);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (notification != null && popKey != null)
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Window width minus the outer margin on both sides and the
                  // banner's own horizontal padding and border.
                  final maxContentWidth = math.max(
                    0.0,
                    constraints.maxWidth - 2 * Spacing.md - 2 * Spacing.md - 2,
                  );

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: Spacing.md),
                      child: Material(
                        color: Colors.transparent,
                        child: _PopBanner(
                          key: popKey,
                          duration: notification.duration,
                          onDismissed: () => ref
                              .read(notificationProvider.notifier)
                              .dismiss(notification.id),
                          child: _BannerContent(
                            title: notification.title,
                            description: notification.description,
                            color: _colorOf(notification.kind),
                            icon: _iconOf(notification.kind),
                            maxContentWidth: maxContentWidth,
                            onExpandedChanged: (expanded) =>
                                popKey.currentState?.setPaused(expanded),
                            onDismiss: () => popKey.currentState?.dismiss(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _PopBanner extends StatefulWidget {
  const _PopBanner({
    super.key,
    required this.child,
    required this.duration,
    required this.onDismissed,
  });

  final Widget child;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_PopBanner> createState() => _PopBannerState();
}

class _PopBannerState extends State<_PopBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _controller.forward();
    _timer = Timer(widget.duration, dismiss);
  }

  Future<void> dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  /// Pauses the auto-dismiss countdown while [paused] is true, and restarts
  /// it from scratch once it becomes false again.
  void setPaused(bool paused) {
    if (!mounted) return;
    _timer?.cancel();
    _timer = paused ? null : Timer(widget.duration, dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
      child: FadeTransition(
        opacity: _controller,
        child: widget.child,
      ),
    );
  }
}

class _BannerContent extends StatefulWidget {
  const _BannerContent({
    required this.title,
    required this.color,
    required this.icon,
    required this.maxContentWidth,
    this.description,
    this.onExpandedChanged,
    this.onDismiss,
  });

  static const double _collapsedWidth = 250;
  static const double _expandedWidth = 400;

  final String title;
  final String? description;
  final Color color;
  final IconData icon;

  /// Upper bound for the content width, provided by the host from the
  /// available window width.
  final double maxContentWidth;
  final ValueChanged<bool>? onExpandedChanged;
  final VoidCallback? onDismiss;

  @override
  State<_BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends State<_BannerContent> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpandedChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.description != null && widget.description!.isNotEmpty;
    final preferredWidth = _expanded
        ? _BannerContent._expandedWidth
        : _BannerContent._collapsedWidth;
    final maxWidth = math.min(preferredWidth, widget.maxContentWidth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
      decoration: BoxDecoration(
        color: Coloring.surfacePrimary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: widget.color,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: _expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Spacing.sm,
              children: [
                PulseWidget(
                  child: Icon(widget.icon, size: 20, color: widget.color,)
                ),
                Flexible(
                  fit: _expanded ? FlexFit.tight : FlexFit.loose,
                  child: Text(widget.title, style: Texting.titleMiddle, overflow: TextOverflow.ellipsis,),
                ),
                if (hasDescription)
                  TextButton(
                    onPressed: _toggle,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(Icons.keyboard_arrow_down, size: 20, color: Coloring.onSurfaceVarient,),
                    ),
                  ),
              ],
            ),
            if (hasDescription)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topLeft,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: Spacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Spacing.md,
                          children: [
                            Text(widget.description!, style: Texting.bodyMedium, textAlign: TextAlign.start),
                            TextButton(
                              onPressed: widget.onDismiss,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: widget.color.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Text('Got It', style: Texting.titleMiddle,),
                              )
                            )
                          ],
                        )
                      )
                    : const SizedBox(width: double.infinity),
              ),
          ],
        ),
      ),
    );
  }
}
