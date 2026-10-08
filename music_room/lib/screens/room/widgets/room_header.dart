import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/room/controller.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/room/provider.dart';
import 'package:music_room/widgets/glass_pop_menu.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';

class RoomHeader extends ConsumerStatefulWidget {
  const RoomHeader({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  ConsumerState<RoomHeader> createState() => _RoomHeaderState();
}

class _RoomHeaderState extends ConsumerState<RoomHeader> {
  bool get _isPremium => ref.watch(authProvider.select((s) => s.user?.premiumUser ?? false));
  BusyNotifier get _busy => ref.read(roomBusyProvider.notifier);
  RoomController get _room => ref.read(roomProvider.notifier);
  RoomView get _roomView => ref.watch(roomViewProvider);

  Future<void>  _license() async {
    await _busy.run(
      () => _room.onEnableLicenseRoom(),
      label: 'License room',
    );
  }

  Future<void>  _unlicense() async {
    await _busy.run(
      () => _room.onDisableLicenseRoom(),
      label: 'Disable license room',
    );
  }

  Future<void>  _publish() async {
    await _busy.run(
      () => _room.onPublishRoom(),
      label: 'Publish room',
    );
  }

  Future<void>  _privatize() async {
    await _busy.run(
      () => _room.onPrivatizeRoom(),
      label: 'Privatize room',
    );
  }

  Future<void>  _onLeaveRoom() async {
    final ok = await _busy.run(
      () => _room.onLeaveRoom()
    );
    if (ok && mounted) if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
                Text(widget.room.name, style: Texting.titleSmall)
              ],
            ),
          ],
        ),
        if (_roomView.isListening(widget.room)) GlassPopMenu(
          items: [
            if (_roomView.isOwnerOf(widget.room)) widget.room.isLicensed ?
            GlassPopMenuItem(icon: Icons.speaker_notes_off, label: 'Unlicense', onTap: _unlicense)
            : GlassPopMenuItem(icon: Icons.speaker_notes, label: 'License', onTap: _license),
            if (_roomView.isOwnerOf(widget.room) && _isPremium) widget.room.isPublic ?
            GlassPopMenuItem(icon: CupertinoIcons.lock, label: 'Privatize', onTap: _privatize)
            : GlassPopMenuItem(icon: CupertinoIcons.lock_open, label: 'Publish', onTap: _publish),
            GlassPopMenuItem(icon: Icons.exit_to_app, label: 'Quit', onTap: _onLeaveRoom),
          ]
        )
      ],
    );
  }
}