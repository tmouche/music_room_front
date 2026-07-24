import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';

class GlassPopMenuItem {
  const GlassPopMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

class GlassPopMenu extends StatefulWidget {
  const GlassPopMenu({
    super.key,
    required this.items,
    bool? baseFilled,
  }): _baseFilled = baseFilled ?? true;

  final List<GlassPopMenuItem>  items;
  final bool                    _baseFilled;

  @override
  State<GlassPopMenu> createState() => _GlassPopMenuState();
}

class _GlassPopMenuState extends State<GlassPopMenu>
    with SingleTickerProviderStateMixin {
  static const _buttonSize = 40.0;

  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _animation;
  late final CurvedAnimation _scale;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = CurvedAnimation(
      parent: _animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    _animation.dispose();
    super.dispose();
  }

  void _open() {
    _portal.show();
    _animation.forward();
  }

  Future<void> _close() async {
    if (!mounted) return;
    await _animation.reverse();
    if (mounted) _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: _GlassRoundButton(
          size: _buttonSize,
          icon: Icons.more_vert,
          onTap: _open,
          baseFilled: widget._baseFilled,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.topRight,
            child: _buildMenu(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu() {
    // Largeur adaptee au contenu, avec un minimum pour que le bouton
    // reste bien pose sur le panneau.
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: IntrinsicWidth(
        child: _buildMenuBody(),
      ),
    );
  }

  Widget _buildMenuBody() {
    return Stack(
      children: [
        // Le panneau commence au milieu du bouton pour que celui-ci
        // depasse du menu comme une excroissance. Seul le panneau est
        // anime : le bouton reste fixe, le menu sort de dessous.
        Padding(
          padding: const EdgeInsets.only(top: _buttonSize / 2),
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.topRight,
            child: FadeTransition(
              opacity: _animation,
              child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  padding: const EdgeInsets.only(
                    top: _buttonSize / 2 + Spacing.xs,
                    bottom: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.items.map(_buildItem).toList(),
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: _GlassRoundButton(
            size: _buttonSize,
            icon: Icons.more_vert,
            onTap: _close,
            filled: true,
            baseFilled: widget._baseFilled,
          ),
        ),
      ],
    );
  }

  Widget _buildItem(GlassPopMenuItem item) {
    return InkWell(
      onTap: () {
        _close();
        item.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          spacing: Spacing.sm,
          children: [
            Icon(item.icon, size: 18, color: Coloring.onSurface),
            Text(item.label, style: Texting.bodyMediumAccent),
          ],
        ),
      ),
    );
  }
}

class _GlassRoundButton extends StatelessWidget {
  const _GlassRoundButton({
    required this.size,
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.baseFilled = true,
  });

  final double size;
  final IconData icon;
  final VoidCallback onTap;
  // Version "ouverte" du bouton, integree au menu : fond plus present
  // et bord blanc assortis au panneau.
  final bool filled;
  final bool baseFilled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipOval(
          child: BackdropFilter(
            filter: filled
                ? ImageFilter.blur(sigmaX: 30, sigmaY: 30)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? Colors.white.withValues(alpha: 0.15)
                    : baseFilled ? Coloring.onSurfaceVarientMuted : Colors.transparent,
                border: filled
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(icon, size: 20, color: Coloring.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
