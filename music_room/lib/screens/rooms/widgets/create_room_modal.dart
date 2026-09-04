import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/features/room/provider.dart';
import 'package:music_room/screens/log_in/widgets/auth_parameters.dart';

class CreateRoomModal extends ConsumerStatefulWidget {
  const CreateRoomModal({super.key});

  @override
  ConsumerState<CreateRoomModal> createState() => _CreateRoomModalState();
}

class _CreateRoomModalState extends ConsumerState<CreateRoomModal> {
  bool _isLoading = false;

  bool _isPublic = true;
  bool _isPrivate = false;


  void  _publish() {
    setState(() {
      _isPublic = true;
      _isPrivate = false;
    });
  }

  void  _private() {
    setState(() {
      _isPublic = false;
      _isPrivate = true;
    });
  }

  Future<void>  _onCreateRoom() async {

    setState(() => _isLoading = true);

    try {
      await ref.read(roomProvider.notifier).createRoom();
      if (_isPrivate) {
        await ref.read(roomProvider.notifier).privatizeRoom();
      }
    }  on ApiException catch (e) {
      logger.debug('Api Error on refresh rooms: $e');
      if (mounted) UiUtils.showError(context, 'Connection Error');
    } catch (e) {
      logger.debug('Error on login password: $e');
      if (mounted) UiUtils.showError(context, 'Internal Server Error.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        context.pop();
      }
    }
    return ;
  }

  Widget _buildVisibilityButtons(
    bool isSelected,
    IconData  icon,
    String text,
    VoidCallback onPressed,
  ) {
    Color color = isSelected
          ? Coloring.primary.withValues(green: 0.2, blue: 0.5)
          : Coloring.onSurfaceVarient.withValues(alpha: 0.70);

    return Container(
      height: 40,
      margin: const EdgeInsets.all(Spacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color) 
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Spacing.xs,
          children: [
            Icon(icon, color: color, size: 20),
            Text(text, style: Texting.bodyMedium.copyWith(fontWeight: FontWeight(700), color: color)),
          ],
        ) 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        border: Border(top: BorderSide(
            color: const Color.fromARGB(255, 70, 70, 70),
          )
        ),
        color: const Color.fromARGB(255, 18, 18, 18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.sm2,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Coloring.onSurfaceVarient.withValues(alpha: 0.4)
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text("New Room", style: Texting.titleMedium),
          ),
          Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text("VISIBILITY", style: Texting.bodyMiddle,),
              ),
              SizedBox(
                child: Row(
                  spacing: Spacing.sm,
                  children: [
                    Expanded(
                      child: _buildVisibilityButtons(
                        _isPublic,
                        Icons.public,
                        'Public',
                        _publish,
                      )
                    ),
                    Expanded(
                      child: _buildVisibilityButtons(
                        _isPrivate,
                        Icons.lock_outline,
                        'Private',
                        _private,
                      )
                    ),
                  ]
                )
              )
            ],
          ),
          Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Coloring.secondary,
                  Coloring.primary,
                ]
              ),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : _onCreateRoom, 
              child: Text(
                'Create Room',
                textAlign: TextAlign.center,
                style: Texting.titleMiddle,
              )
            )
          ),
        ],
      ),
    );
  }
}