import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';
import 'package:music_room/screens/room/widgets/glass_pop_menu.dart';
import 'package:music_room/screens/room/widgets/listener_card.dart';
import 'package:music_room/screens/room/widgets/music_search.dart';
import 'package:music_room/widgets/search_modal.dart';
import 'package:music_room/screens/room/widgets/seek_bar.dart';
import 'package:music_room/screens/room/widgets/track_card.dart';

class RoomPage extends ConsumerStatefulWidget {
  final Room room;

  const RoomPage({
    super.key,
    required this.room,
  });

  @override
  ConsumerState<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends ConsumerState<RoomPage>
  with SingleTickerProviderStateMixin {

  static const double _collapsedHeaderHeight = 70.0;
  static const double _modalMinHeight = 60.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  late bool _isListener;
  late bool _isOwner;

  late Room _room;

  bool _isPlaying = false;
  bool _isModalOpen = false;
  bool _isUserModal = false;

  double audioVolume = 0;
  bool _isVolumeDragging = false;

  bool _isLoading = false;

  Future<void>  _privatize() async {

    setState(() => _isLoading = true);

    try {
      await ref.read(roomProvider.notifier).privatizeRoom();
    } on ApiException catch (e) {
      logger.debug('API Error on privatizing room: $e');
      if (mounted) UiUtils.showError(context, 'Privatize Room Failed, Server Error.');
    } catch (e) {
      logger.debug('Error on Privatize Room: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void>  _togglePlaying() async {

    setState(() => _isLoading = true);

    try {
      if (ref.read(roomProvider).currentRoom?.currentTrack != null) {
        if (_isPlaying) {
          await ref.read(roomProvider.notifier).pauseTrack();
        } else {
          await ref.read(roomProvider.notifier).playTrack();
        }
      }
    } on ApiException catch (e) {
      logger.debug('API Error on privatizing room: $e');
      if (mounted) UiUtils.showError(context, 'Privatize Room Failed, Server Error.');
    } catch (e) {
      logger.debug('Error on Privatize Room: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Future<void>  _onSkipPrev() async {
    setState(() => _isLoading = true);

    try {
      ref.read(roomProvider.notifier).skipPrevTrack();
    } on ApiException catch (e) {
      logger.debug('API Error on SkipPrev: $e');
      if (mounted) UiUtils.showError(context, 'SkipPrev, Server Error.');
    } catch (e) {
      logger.debug('Error on SkipPrev: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void>  _onSkipNext() async {
    setState(() => _isLoading = true);

    try {
      ref.read(roomProvider.notifier).skipNextTrack();
    } on ApiException catch (e) {
      logger.debug('API Error on SkipNext: $e');
      if (mounted) UiUtils.showError(context, 'SkipNext, Server Error.');
    } catch (e) {
      logger.debug('Error on SkipNext: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void  _onAddMusicButton() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        topic: "Musics",
        contentBuilder: (query) => MusicSearch(query: query)
      )
    );
  }

  void  _onInviteButton() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        topic: "Friends",
        contentBuilder: (query) => MusicSearch(query: query)
      )
    );
  }

  Future<void>  _onJoinRoom() async {
    try {
      await ref.read(roomProvider.notifier).joinRoom(widget.room);
    } catch (e) {
      logger.error("Error during joining the room");
      logger.debug("Detail: $e");
    }
  }

  Future<void>  _onLeaveRoom() async {
    try {
      await ref.read(roomProvider.notifier).leaveRoom();
      if (mounted) context.pop();
    } catch (e) {
      logger.error("Error during leaving the room");
      logger.debug("Detail: $e");
    }
  }

  Future<void>  _onReorderingList(int oldPos, int newPos) async {
    try {
      await ref.read(roomProvider.notifier).reorderQueueItem(oldPos, newPos);
    } catch (e) {
      logger.error("Error during reordering the roomQueue");
      logger.debug("Detail: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: Spacing.md,
          children: [
            if (context.canPop()) BackgroundedIconsButton(
              onPressed: () => context.pop(),
              icon: CupertinoIcons.chevron_down,
              iconSize: 30,
              boxPadding: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLAYING FROM', style: Texting.bodyMiddle),
                Text(_room.name, style: Texting.titleSmall)
              ],
            ),
          ],
        ),
        if (_isListener) GlassPopMenu(
          items: [
            if (_isOwner) _room.isLicensed ?
            GlassPopMenuItem(icon: Icons.speaker_notes_off, label: 'Unlicense')
            : GlassPopMenuItem(icon: Icons.speaker_notes, label: 'License'),
            if (_isOwner) _room.isPublic ?
            GlassPopMenuItem(icon: CupertinoIcons.lock, label: 'Privatize', onTap: _privatize)
            : GlassPopMenuItem(icon: CupertinoIcons.lock_open, label: 'Publish'),
            GlassPopMenuItem(icon: Icons.exit_to_app, label: 'Quit', onTap: _onLeaveRoom),
          ]
        )
      ],
    );
  }

  Widget _buildTrackInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _room.currentTrack?.title ?? 'Owner is choosing...',
          style: Texting.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          _room.currentTrack?.artist ?? '...',
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

  Widget _buildCoverHeader(double t) {
    return LayoutBuilder(
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
                    child: _room.currentTrack?.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: _room.currentTrack!.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Coloring.primary, Coloring.secondary],
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
                        if (_isListener) FittedBox(
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
        if (_isListener) Align(
          alignment: Alignment.bottomRight,
          child: Opacity(
            opacity: (1 - t * 3).clamp(0.0, 1.0),
            child: _buildListenerMenuIcons(),
          ),
        ),
      ],
        );
      },
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
            return _isUserModal ? _buildModalContentUser() : _buildModalContentMusic();
          },
        ),
      ),
    );
  }

  Widget _buildModalContentUser() {
    return Column(
      spacing: Spacing.sm,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text('User List', style: Texting.titleMiddle),
                  Text('${_room.people} ${_room.people == 1 ? 'listener' : 'listeners'}', style: Texting.bodyMedium)
              ],
            ),
            if (_isOwner) TextButton(
              onPressed: _onInviteButton,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(Spacing.sm, Spacing.xs, Spacing.sm, Spacing.xs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Coloring.onSurfaceVarientMuted,
                  border: Border.all(color: Coloring.onSurfaceVarient)
                ),
                child: Row(
                  spacing: Spacing.xs,
                  children: [
                    Icon(Icons.add, color: Coloring.onSurface, size: 10),
                    Text('Invite', style: Texting.titleMiddle,),
                  ],
                ) 
              )
            ),
          ]
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: Spacing.md,
              children: _room.listeners.map(
                (toElement) => ListenerCard(
                  listener: toElement,
                  isOwner: toElement.username == _room.owner,
                  amIOwner: _isOwner,
                )
              ).toList(),
            )
          )
        )
      ],
    );
  }

  Widget _buildModalContentMusic() {
    return Column(
          spacing: Spacing.sm,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text('Up Next', style: Texting.titleMiddle),
                      Text('${_room.queue.length} songs', style: Texting.bodyMedium)
                  ],
                ),
                if (_isOwner) TextButton(
                  onPressed: _onAddMusicButton,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(Spacing.sm, Spacing.xs, Spacing.sm, Spacing.xs),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Coloring.onSurfaceVarientMuted,
                      border: Border.all(color: Coloring.onSurfaceVarient)
                    ),
                    child: Row(
                      spacing: Spacing.xs,
                      children: [
                        Icon(Icons.add, color: Coloring.onSurface, size: 10),
                        Text('Add', style: Texting.titleMiddle,),
                      ],
                    ) 
                  )
                ),
              ]
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: Spacing.sm),
                    sliver: SliverReorderableList(
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            final t = Curves.easeInOut.transform(animation.value);
                            return Material(
                              color: Colors.transparent,
                              elevation: 0,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    top: -4 * t,
                                    bottom: -4 * t,
                                    left: -6,
                                    right: -6,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.25 * t),
                                            blurRadius: 10 * t,
                                            spreadRadius: 1 * t,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 15 * t,
                                            sigmaY: 15 * t,
                                          ),
                                          child: Container(
                                            color: Colors.white.withValues(alpha: 0.05 * t),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child,
                                ],
                              ),
                            );
                          },
                        );
                      },
                      itemCount: _room.queue.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          key: ValueKey(_room.queue[index].id),
                          padding: EdgeInsets.symmetric(vertical: Spacing.sm / 2),
                          child: TrackCard(
                            queueItem: _room.queue[index],
                            index: index,
                          ),
                        );
                      },
                      onReorderItem: _onReorderingList,
                    ),
                  ),
                ],
              ),
            ),
          ]
    );
  }

  Widget _buildControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _onSkipPrev,
          child: Icon(CupertinoIcons.backward_end, color: Coloring.onSurface, size: 32),
        ),
        TextButton(
          onPressed: _togglePlaying,
          style: TextButton.styleFrom(
            overlayColor: Colors.white.withValues(alpha: 0.1),
            shape: CircleBorder()
          ),
          child: Container(
            alignment: Alignment.center,
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _isPlaying ?
              Icon(CupertinoIcons.pause_fill, color: Colors.black, size: 32)
              : Icon(CupertinoIcons.play_fill, color: Colors.black, size: 32)
          )
        ),
        TextButton(
          onPressed: _onSkipNext,
          child: Icon(CupertinoIcons.forward_end, color: Coloring.onSurface, size: 32),
        ),
      ],
    );
  }

  Widget _buildVolumeRow() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _isVolumeDragging ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, t, _) {
        final iconColor = Color.lerp(Coloring.onSurfaceVarient, Coloring.onSurface, t)!;
        return Transform.scale(
          scale: lerpDouble(1.0, 1.06, t)!,
          child: Row(
            spacing: Spacing.lg,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.volume_mute, color: iconColor, size: 18),
              Expanded(child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: audioVolume,
                    min: 0,
                    max:  100,
                    onChanged: (value) {
                      setState(() => audioVolume = value);
                      ref.read(roomProvider.notifier).setVolume(value / 100);
                    },
                    onChangeStart: (_) => setState(() => _isVolumeDragging = true),
                    onChangeEnd: (_) => setState(() => _isVolumeDragging = false),
                    activeColor: iconColor,
                    inactiveColor: Colors.white.withValues(alpha: lerpDouble(0.2, 0.35, t)!),
                  )
                ),
              ),
              Icon(CupertinoIcons.volume_up, color: iconColor, size: 18),
            ]
          ),
        );
      },
    );
  }

  Widget  _joinRoomButton() {
    return Expanded(
      child: Container(
      decoration: BoxDecoration(
        color: Coloring.onSurface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextButton(
        onPressed: _onJoinRoom,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Spacing.sm,
          children: [
            Icon(Icons.headphones_outlined, color: Coloring.surfacePrimary, size: 25, fontWeight: FontWeight(500)),
            Text('Join to listen music', style: Texting.titleMiddle.copyWith(color: Coloring.surfacePrimary, fontWeight: FontWeight(700)))
          ],
        )
      ),
      ),
    );
  }

  Widget  _nextInQueueCard() {
    return Container(
      padding: EdgeInsets.all(Spacing.sm2),
      decoration: BoxDecoration(
        color: Coloring.onSurface.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
      ),
      child: Row(
        spacing: Spacing.md,
        children: [
          SizedBox(
            width: 55,
            height: 55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _room.currentTrack?.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _room.currentTrack!.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Coloring.primary, Coloring.secondary],
                        ),
                      ),
                    ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 0,
            children: [
              Text('UP NEXT', style: Texting.bodyMiddleTrans),
              Text(
                _room.currentTrack?.title ?? 'Nothing queued',
                style: Texting.bodyLarge.copyWith(color: Coloring.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _room.currentTrack?.artist ?? '...',
                style: Texting.bodyMiddleTrans,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ],
      )
    );
  }


  Widget  _buildOwnerView() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RepaintBoundary(child: SeekBar()),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildControlsRow(),
                  _buildVolumeRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget  _buildListenerView() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: Spacing.lg),
        child: Column(
          spacing: Spacing.md,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RepaintBoundary(child: SeekBar()),
            Expanded(
              child: Column(
                spacing: Spacing.lg,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _nextInQueueCard(),
                  _buildVolumeRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget  _buildPreView() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: Spacing.lg),
        child: Column(
          spacing: Spacing.md,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RepaintBoundary(child: SeekBar()),
            Expanded(
              child: Column(
                spacing: Spacing.md,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _nextInQueueCard(),
                  _joinRoomButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget  _returnRightView() {
    if (!_isListener) {
      return _buildPreView();
    } else if (!_isOwner) {
      return _buildListenerView();
    }
    return _buildOwnerView();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(roomProvider.select((s) => s.roomClosedMessage), (_, message) {
      if (message == null) return;
      ref.read(roomProvider.notifier).clearRoomClosedMessage();
      UiUtils.showError(context, message);
      if (context.canPop()) context.pop();
    });
    ref.listen(roomProvider.select((s) => s.playerErrorMessage), (_, message) {
      if (message == null) return;
      ref.read(roomProvider.notifier).clearPlayerErrorMessage();
      UiUtils.showError(context, message);
    });

    final authState = ref.watch(authProvider);
    final roomState = ref.watch(roomProvider);

    _isPlaying = roomState.isPlaying;
    if (!_isVolumeDragging) audioVolume = roomState.volume * 100;

    final currentRoom = roomState.currentRoom;
    _room = (currentRoom != null && currentRoom.id == widget.room.id)
        ? currentRoom
        : widget.room;
    _isListener = currentRoom != null && currentRoom.id == widget.room.id;
    _isOwner = _room.owner == authState.user?.id;
  
    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        bottom: false,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.room.gradientColor!.map((toElement) => toElement.withValues(alpha: 0.7)).toList()
            ),
          ),
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
          child: Column(
            spacing: Spacing.xs,
            children: [
              _buildHeader(),
              Expanded(
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
                              child: _buildCoverHeader(t),
                            ),
                            Expanded(child: _buildModal(t)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _returnRightView(),
            ],
          ),
        ),
      ),
    );
  }
}
