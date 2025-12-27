import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final appTextThemeProvider = Provider((ref) {
  return GoogleFonts.spaceGroteskTextTheme();
});
