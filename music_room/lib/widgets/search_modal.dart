import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/core/utils/extention.dart';

final searchBusyProvider = NotifierProvider.autoDispose<BusyNotifier, bool>(BusyNotifier.new);

class SearchModal<T> extends ConsumerStatefulWidget {
  const SearchModal({
    super.key,
    required this._topic,
    required this._contentBuilder,
    this._toSearch,
  });

  final String                              _topic;
  final Widget  Function({T? content})      _contentBuilder;
  final Future<T> Function(String query)?   _toSearch;

  @override
  ConsumerState<SearchModal<T>> createState() => _SearchModalState<T>();
}

class _SearchModalState<T> extends ConsumerState<SearchModal<T>> {
  bool    _isLoading = false;
  Widget  _searchedList = SizedBox();
  String  _query = '';

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetContent();
  }

  void  _resetContent() {
    if (mounted) setState(() => _searchedList = widget._contentBuilder(content: null));
  }

  Future<void>  _onSearch() async {
    final String searchFor = _searchController.text;
    if (searchFor.trim().isEmpty) {
      _resetContent();
      return ;
    }
    setState(() => _query = searchFor);
    Widget  myWidget;
    if (widget._toSearch == null) {
      myWidget = _onSearchOut();
    } else {
      myWidget = await _onSearchIn();
    }
    if (mounted) setState(() => _searchedList = myWidget);
    return ;
  }

  Widget _onSearchOut() {
    return widget._contentBuilder(content: _query as T);
  }

  Future<Widget>  _onSearchIn() async {
    setState(() => _isLoading = true);
      final T? result = await ref.read(searchBusyProvider.notifier).fetch(
      () => widget._toSearch!(_query),
      label: 'Search for ${widget._topic} failed',
    );
    if (mounted) setState(() => _isLoading = false);
    if (result == null) return SizedBox();
    return widget._contentBuilder(content: result);
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
                hintText: "Search ${widget._topic.toLowerCase()}",
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
              padding: EdgeInsets.fromLTRB(
                0, Spacing.sm, 0, Spacing.md,
              ),
              decoration: BoxDecoration(
                border: BoxBorder.fromLTRB(
                  bottom: BorderSide(
                    color: Coloring.onSurfaceVarientMuted,
                    width: 1,
                  )
                )
              ),
              child: Column(
                spacing: Spacing.sm,
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
                    child: Text(widget._topic.capitalizeFirst(), style: Texting.titleMedium),
                  ),
                  _buildSearchBar(),
                ],
              )
            ),
            Expanded(child: _searchedList),
          ],
        ),
      )
    );    
  }
}