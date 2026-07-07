/// The Daily Cart design system — vintage newspaper. Colors and type ramp
/// lifted verbatim from the design prototype.
library;

import 'package:flutter/material.dart';

abstract final class NewsInk {
  static const paper = Color(0xFFF4EFE2); // page background
  static const card = Color(0xFFFBF7EA); // raised paper
  static const cardDim = Color(0xFFECE5D2); // hover / pressed paper
  static const black = Color(0xFF17150F); // ink
  static const blackHover = Color(0xFF2B2820);
  static const red = Color(0xFFB3271B); // masthead red
  static const redDark = Color(0xFF8F1E14);
  static const mustard = Color(0xFFE3B505); // ticker yellow
  static const mustardHover = Color(0xFFF0C520);
  static const green = Color(0xFF1F5C33); // under-par green
  static const gray = Color(0xFF6B675C); // secondary text
  static const grayFaint = Color(0xFF9A9482); // tertiary text
  static const rule = Color(0xFFE8E0CA); // hairlines on paper
  static const ruleDark = Color(0xFFD8D0B8);
  static const body = Color(0xFF3A372E); // article body text
  static const borderDim = Color(0xFF4A463C); // unselected on dark
}

abstract final class Fonts {
  static const anton = 'Anton';
  static const mono = 'IBMPlexMono';
  static const serif = 'DMSerifDisplay';
  static const barcode = 'LibreBarcode39';
}

abstract final class News {
  /// Anton display — headlines, mastheads, scores.
  static TextStyle anton(double size,
          {Color color = NewsInk.black, double? height, double spacing = 0}) =>
      TextStyle(
        fontFamily: Fonts.anton,
        fontSize: size,
        color: color,
        height: height,
        letterSpacing: spacing,
      );

  /// Mono body/label text.
  static TextStyle mono(double size,
          {Color color = NewsInk.black,
          FontWeight weight = FontWeight.w400,
          double spacing = 0,
          double? height}) =>
      TextStyle(
        fontFamily: Fonts.mono,
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
      );

  /// The all-caps letterspaced kicker labels ("TRIP LEDGER — SEASON 1").
  static TextStyle kicker(double size,
          {Color color = NewsInk.black, double spacing = 2}) =>
      mono(size, color: color, weight: FontWeight.w700, spacing: spacing);

  /// Frank's pull quotes.
  static TextStyle serifQuote(double size,
          {Color color = NewsInk.black, double height = 1.4}) =>
      TextStyle(
        fontFamily: Fonts.serif,
        fontStyle: FontStyle.italic,
        fontSize: size,
        color: color,
        height: height,
      );

  static TextStyle barcode(double size, {Color color = NewsInk.black}) =>
      TextStyle(fontFamily: Fonts.barcode, fontSize: size, color: color);

  static const cardShadow = [
    BoxShadow(
      color: Color(0x1F17150F), // rgba(23,21,15,0.12)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

ThemeData buildNewsTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NewsInk.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NewsInk.red,
        primary: NewsInk.black,
        secondary: NewsInk.red,
        surface: NewsInk.paper,
      ),
      fontFamily: Fonts.mono,
      splashFactory: NoSplash.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: NewsInk.black,
        selectionColor: Color(0x33E3B505),
        selectionHandleColor: NewsInk.black,
      ),
    );
