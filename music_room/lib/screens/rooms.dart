import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/widgets/backgrounded_icons_button.dart';
import 'package:music_room/widgets/room_card.dart';

class RoomsPage extends ConsumerStatefulWidget {
  const RoomsPage({super.key});

  @override
  ConsumerState<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {


  void _show_notifications() {
    showModalBottomSheet(
      context: context,
      builder: (_) => NotificationModalTest(), 
    );
  }

  void _create_rooms() {
    return ;
  }

  void _refresh_rooms() {
    return ;
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;

    // final rooms = ref.watch(roomsProvider)

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
                            onPressed: _create_rooms,
                            icon: CupertinoIcons.plus,
                            bgColor: Color.fromRGBO(239, 68, 68, 1),
                            iconSize: 25,
                            boxPadding: 5,
                          ),
                          BackgroundedIconsButton(
                            onPressed: _show_notifications,
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Coloring.onSurfaceVarient.withValues(alpha: 0.25),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
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
                            BackgroundedIconsButton(
                              onPressed: _refresh_rooms,
                              icon: CupertinoIcons.arrow_2_circlepath,
                              iconSize: 20,
                              boxPadding: 5,
                            ),
                          ],
                        )
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