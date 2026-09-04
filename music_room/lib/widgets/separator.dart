
  import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';

Widget  separator({Color? color}) {
  return Container(
      height: 1,
      color: color ?? Coloring.onSurfaceVarient,
  );
}

Widget  tightSeparator({Color? color}) {
  return Container(
      height: 0.5,
      color: color ?? Coloring.onSurfaceVarient,
  );
}