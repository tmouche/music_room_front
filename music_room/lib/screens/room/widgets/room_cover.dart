import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/screens/room/provider.dart';
import 'package:music_room/screens/room/widgets/listeners_list.dart';
import 'package:music_room/screens/room/widgets/tracks_list.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';

class RoomCover extends ConsumerStatefulWidget {
  const RoomCover({
    super.key,
    required this.room
  });

  final Room room;

  @override
  ConsumerState<RoomCover> createState() => _RoomCoverState();
}

class _RoomCoverState extends ConsumerState<RoomCover> with SingleTickerProviderStateMixin {
  static const double _collapsedHeaderHeight = 70.0;
  static const double _modalMinHeight = 60.0;
  bool _isModalOpen = false;
  bool _isUserModal = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  RoomView get roomView => ref.watch(roomViewProvider);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }  

  void  _toggleUserModal() {
    if (_isModalOpen) {
      if (_isUserModal == true) {
        _toggleModal();
      } else {
        setState(() => _isUserModal = true);
      }
    } else {
      _isUserModal = true;
      _toggleModal();
    }
  }

  void  _toggleMusicModal() {
    if (_isModalOpen) {
      if (_isUserModal == false) {
        _toggleModal();
      } else {
        setState(() => _isUserModal = false);
      }
    } else {
      _isUserModal = false;
      _toggleModal();
    }
  }

  void  _toggleModal() {
    setState(() => _isModalOpen = !_isModalOpen);
    if (_isModalOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget _buildTrackInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.room.currentTrack?.title ?? 'Owner is choosing...',
          style: Texting.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          widget.room.currentTrack?.artist ?? '...',
          style: Texting.bodyLarge,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildListenerMenuIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.sm,
      children: [
        BackgroundedIconsButton(
          onPressed: _toggleUserModal,
          icon: CupertinoIcons.group,
          iconSize: 22,
          boxPadding: 5,
        ),
        BackgroundedIconsButton(
          onPressed: _toggleMusicModal,
          icon: CupertinoIcons.music_note_list,
          iconSize: 22,
          boxPadding: 5,
        ),
      ],
    );
  }

  Widget _buildModal(double t) {
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Container(
        margin: EdgeInsets.only(top: Spacing.md),
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight < _modalMinHeight) {
              return const SizedBox.shrink();
            }
            return _isUserModal ? ListenersList(room: widget.room) : TracksList(room: widget.room,);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final t = _animation.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              final headerHeight = lerpDouble(
                constraints.maxHeight,
                _collapsedHeaderHeight,
                t,
              )!;
              return Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final infoWidth = constraints.maxWidth - 70 - 12;
                        return Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: lerpDouble(0, Spacing.xs, t)!),
                          child: Align(
                            alignment: Alignment.lerp(
                              Alignment.center,
                              const Alignment(-1, -1),
                              t,
                            )!,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: lerpDouble(230, 70, t),
                                  height: lerpDouble(230, 70, t),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        blurRadius: lerpDouble(30, 5, t)!,
                                        spreadRadius: 0.5,
                                        offset: Offset(lerpDouble(10, 1, t)!, lerpDouble(10, 1, t)!),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: widget.room.currentTrack?.imageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: widget.room.currentTrack!.imageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: Coloring.defaultCover,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: lerpDouble(0, 12, t)),
                                Opacity(
                                  opacity: ((t - 0.6) / 0.4).clamp(0.0, 1.0),
                                  child: SizedBox(
                                    width: lerpDouble(0, infoWidth, t),
                                    child: Row(
                                      spacing: Spacing.sm,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: _buildTrackInfo()),
                                        if (roomView.isListening(widget.room)) FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: _buildListenerMenuIcons(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(0, lerpDouble(0, -60, t)!),
                            child: Opacity(
                              opacity: (1 - t * 3).clamp(0.0, 1.0),
                              child: Container(
                                alignment: Alignment.bottomLeft,
                                child: _buildTrackInfo(),
                              ),
                            ),
                          ),
                        ),
                        if (roomView.isListening(widget.room)) Align(
                          alignment: Alignment.bottomRight,
                          child: Opacity(
                            opacity: (1 - t * 3).clamp(0.0, 1.0),
                            child: _buildListenerMenuIcons(),
                          ),
                        ),
                      ],
                        );
                      },
                    )
                  ),
                  Expanded(child: _buildModal(t)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}