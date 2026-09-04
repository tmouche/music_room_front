import 'package:flutter/material.dart';

/// Owns the text of an [AuthField] and lets the parent trigger its shake
/// animation without holding a [GlobalKey] on the field's state.
///
/// Create one per field, pass it to [AuthField.controller], and dispose it
/// with the owning [State].
class AuthFieldController extends ChangeNotifier {
  final TextEditingController text = TextEditingController();

  /// Trimmed content of the field.
  String get value => text.text.trim();

  bool get isEmpty => value.isEmpty;

  void clear() => text.clear();

  /// Plays the shake animation on the attached [AuthField], if any.
  void shake() => notifyListeners();

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }
}
