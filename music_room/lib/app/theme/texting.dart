import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'coloring.dart';

class Texting {
  const Texting();

  static final titleLarge = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Coloring.onSurface,
  );

  static final titleMedium = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Coloring.onSurface,
  );

  static final titleSmall = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Coloring.onSurface,
  );

  static final bodyLarge = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    color: Coloring.onSurfaceVarient,
  );

  static final bodyMedium = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    color: Coloring.onSurfaceVarient,
  );

  static final bodyMediumAccent = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    color: Coloring.onSurface,
  );

  static final bodySmall = GoogleFonts.spaceGrotesk(
    fontSize: 8,
    color: Coloring.onSurfaceVarient,
  );

}