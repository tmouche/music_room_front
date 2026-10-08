import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/rooms/provider.dart';
import 'package:music_room/screens/rooms/widgets/rooms_header.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';
import 'package:music_room/screens/rooms/widgets/create_room_modal.dart';
import 'package:music_room/screens/rooms/widgets/rooms_card.dart';

class RoomsPage extends ConsumerStatefulWidget {
  const RoomsPage({super.key});

  @override
  ConsumerState<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {
  bool  _isLoading = false;

  BusyNotifier get _busy => ref.read(roomsBusyProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(roomProvider.notifier).onRefreshRoom();
    });
  }

  void  _createRoom() {
    showModalBottomSheet(
      context: context,
      builder: (_) => CreateRoomModal(),
    );
  }

  Future<void> _refreshRooms() async {
    setState(() => _isLoading = true);
    await _busy.run(
      () => ref.read(roomProvider.notifier).onRefreshRoom(),
      label: 'Refresh Room',
      apiErrorKind: NotificationKind.error
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomProvider.select((s) => s.availableRooms)); 
    final busyState = ref.watch(roomsBusyProvider);
    return Scaffold(
      backgroundColor: Coloring.surfacePrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RoomsHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: Spacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Live Rooms", style: Texting.titleMedium),
                            SpinningBackgroundedIconButton(
                              onPressed: busyState ? null : _refreshRooms,
                              icon: Icons.refresh,
                              iconSize: 22,
                              boxPadding: 5,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                        SizedBox(height: Spacing.md,),
                        _isLoading ?
                          LoadingRoomCard()
                        : rooms.isNotEmpty ?
                          SingleChildScrollView(
                            child: Column(
                              spacing: Spacing.md,
                              children: rooms.map(
                                (toElement) => RoomCard(room: toElement)
                              ).toList()
                            ),
                          )
                        : AddRoomCard(onTap: _createRoom,)
                      ],
                    ),                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );   
  }
}
