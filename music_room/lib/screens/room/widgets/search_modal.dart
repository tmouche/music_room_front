import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/extention.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/core/utils/ui_utils.dart';
import 'package:music_room/screens/room/widgets/music_list.dart';
import 'package:music_room/widgets/separator.dart';

class SearchModal extends ConsumerStatefulWidget {
  const SearchModal({
    super.key,
    required this.topic,
    required this.sourceBuilder,
  });

  final String                                                  topic;
  final Future<Widget>  Function(WidgetRef ref, String query)   sourceBuilder;

  @override
  ConsumerState<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends ConsumerState<SearchModal> {

  bool    _isLoading = false;
  Widget  _searchedList = SizedBox();

  final _searchController = TextEditingController();

  Future<void>  _onSearch() async {
    final String searchFor = _searchController.text;
    
    if (searchFor.trim().isEmpty) {
      setState(() => _searchedList = SizedBox());
      return ;
    }

    try {
      setState(() => _isLoading = true);
      final myWidget = await widget.sourceBuilder(ref, searchFor);
      if (mounted) setState(() => _searchedList = myWidget);
    } on ApiException catch (e) {
      logger.debug('Api Error on searching tracks: $e');
      if (mounted) {
        UiUtils.showError(context, 'Connection Error');
        setState(() => _searchedList = SizedBox());
      }
    } catch (e) {
      logger.debug('Error on searching tracks: $e');
      if (mounted) {
        UiUtils.showError(context, 'Internal Server Error.');
        setState(() => _searchedList = SizedBox());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    return ;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child:  SizedBox(
            height: 40,
            child: TextField(
              style: Texting.bodyMediumAccent,
              controller: _searchController,
              textInputAction: TextInputAction.done,
              cursorColor: Coloring.onSurface,
              cursorWidth: 1,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Coloring.onSurfaceVarient.withValues(alpha: 0.30)),
                hintText: "Search ${widget.topic.toLowerCase()}",
                hintStyle: Texting.bodyMedium,
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
        ),
        TextButton(
          onPressed: _isLoading ? null : _onSearch,
          child: Container(
            height: 40,
            padding: EdgeInsets.fromLTRB(Spacing.sm2, 0, Spacing.sm2, 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Coloring.primary.withValues(alpha: 0.8),
            ),
            child: Text('Search', style: Texting.bodyMediumAccent)
          )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75, // 75%
      child: Container(
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
              child: Text(widget.topic.capitalizeFirst(), style: Texting.titleMedium),
            ),
            _buildSearchBar(),
            Container(
              alignment: Alignment.centerLeft,
              child: Text('YOUR ${widget.topic.toUpperCase()}', style: Texting.bodyMedium,),
            ),
            separator(),
            Expanded(child: _searchedList),
          ],
        ),
      )
    );    
  }
}