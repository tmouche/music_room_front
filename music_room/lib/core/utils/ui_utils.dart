import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/widgets/pulse.dart';

class UiUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError
                ? colorScheme.onErrorContainer
                : colorScheme.onSecondaryContainer,
          ),
        ),
        backgroundColor: isError
            ? colorScheme.errorContainer
            : colorScheme.secondaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, isError: true);
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, isError: false);
  }



  static OverlayEntry? _topBannerEntry;

  static void showErrorBanner(
    BuildContext context,
    String title,
    {String? description,}
  )  {
    showTopBanner(
      context,
      title,
      Coloring.onError,
      Icons.close,
      description: description
    );
  }

  static void showHintBanner(
    BuildContext context,
    String title,
    {String? description,}
  )  {
    showTopBanner(
      context,
      title,
      Colors.orange,
      Icons.lightbulb_outlined,
      description: description
    );
  }

  static void showSuccessBanner(
    BuildContext context,
    String title,
    {String? description,}
  )  {
    showTopBanner(
      context,
      title,
      Coloring.onSuccess,
      Icons.check,
      description: description
    );
  }

  static void showTopBanner(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    {String? description,}
  ) {
    _topBannerEntry?.remove();
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    final popBannerKey = GlobalKey<_PopBannerState>();

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: _PopBanner(
              key: popBannerKey,
              duration: const Duration(seconds: 5),
              onDismissed: () {
                entry.remove();
                if (identical(_topBannerEntry, entry)) {
                  _topBannerEntry = null;
                }
              },
              child: _BannerContent(
                title: title,
                description: description,
                color: color,
                icon: icon,
                onExpandedChanged: (expanded) =>
                    popBannerKey.currentState?.setPaused(expanded),
                onDismiss: () => popBannerKey.currentState?._dismiss(),
              ),
            ),
          ),
        ),
      ),
    );

    _topBannerEntry = entry;
    overlay.insert(entry);
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
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
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
    _timer = paused ? null : Timer(widget.duration, _dismiss);
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
    this.description,
    this.onExpandedChanged,
    this.onDismiss,
  });

  final String title;
  final String? description;
  final Color color;
  final IconData icon;
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
        constraints: _expanded ? const BoxConstraints(maxWidth: 400) : const BoxConstraints(maxWidth: 250),
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
