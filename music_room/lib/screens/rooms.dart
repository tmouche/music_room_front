import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';
import 'package:music_room/widgets/create_room_modal.dart';
import 'package:music_room/widgets/room_card.dart';

class RoomsPage extends ConsumerStatefulWidget {
  const RoomsPage({super.key});

  @override
  ConsumerState<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(roomProvider.notifier).refreshRoom();
    });
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (_) => NotificationModalTest(), 
    );
  }

  void  _createRoom() {
    showModalBottomSheet(
      context: context,
      builder: (_) => CreateRoomModal(),
    );
  }

  Future<void> _refreshRooms() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(roomProvider.notifier).refreshRoom();
    } on ApiException catch (e) {
      logger.debug('Api Error on refresh rooms: $e');
      if (mounted) UiUtils.showError(context, 'Connection Error');
    } catch (e) {
      logger.debug('Error on login password: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }    return ;
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;

    final rooms = ref.watch(roomProvider).availableRooms; 

    return Scaffold(
      backgroundColor: appColor.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.md),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: appColor.surface,
                border: BoxBorder.fromLTRB(
                  bottom: BorderSide(color: appColor.onSurfaceVariant.withValues(alpha: 0.15))
                ),
              ),
              child: Column(
                spacing: Spacing.md,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Listen Now", style: appText.titleLarge,),
                      Row(
                        spacing: Spacing.xs,
                        children: [
                          BackgroundedIconsButton(
                            onPressed: _createRoom,
                            icon: CupertinoIcons.plus,
                            bgColor: Color.fromRGBO(239, 68, 68, 1),
                            iconSize: 25,
                            boxPadding: 5,
                          ),
                          BackgroundedIconsButton(
                            onPressed: _showNotifications,
                            icon: CupertinoIcons.bell,
                            iconSize: 25,
                            boxPadding: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      style: Texting.bodyMediumAccent,
                      cursorColor: Coloring.onSurface,
                      cursorWidth: 1,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Coloring.onSurfaceVarient.withValues(alpha: 0.30)),
                        hintText: "Search",
                        hintStyle: appText.bodyMedium,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Coloring.borderFocused),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Coloring.onSurfaceVarient.withValues(alpha: 0.25),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            width:  1,
                            color: Coloring.onSurfaceVarient.withValues(alpha: 0.30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ) 
            ),

            //Body Container
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
                              onPressed: _refreshRooms,
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

class NotificationModalTest extends StatelessWidget {
  const NotificationModalTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Coloring.onSurfaceVarientMuted,
        borderRadius: BorderRadius.circular(25),
        border: BoxBorder.all(color: Coloring.onSurfaceVarientMuted)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Notifications', style: Texting.titleMedium),
          TextButton(
            onPressed: null,
            child: Text('Mark all read', style: TextStyle(fontSize: 13, color: Coloring.secondary)),
          )
          // ...
        ],
      ),
    );
  }
}