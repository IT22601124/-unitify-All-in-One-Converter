import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF3157D5);
  static const secondary = Color(0xFF0E9F9A);

  static ThemeData light() => _theme(
    const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE8EDFF),
      onPrimaryContainer: Color(0xFF10215F),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD8F5F2),
      onSecondaryContainer: Color(0xFF073D3B),
      tertiary: Color(0xFF7C5CFC),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFEDE8FF),
      onTertiaryContainer: Color(0xFF281768),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFF6F8FC),
      onSurface: Color(0xFF172033),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFFFFFF),
      surfaceContainer: Color(0xFFF0F3F9),
      surfaceContainerHigh: Color(0xFFE9EDF5),
      surfaceContainerHighest: Color(0xFFE1E6F0),
      onSurfaceVariant: Color(0xFF637083),
      outline: Color(0xFF8994A5),
      outlineVariant: Color(0xFFDCE2EB),
      shadow: Color(0xFF111827),
      scrim: Color(0xFF111827),
      inverseSurface: Color(0xFF252E40),
      onInverseSurface: Color(0xFFF2F4FA),
      inversePrimary: Color(0xFFB8C4FF),
      surfaceTint: primary,
    ),
  );

  static ThemeData dark() => _theme(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFB8C4FF),
      onPrimary: Color(0xFF092873),
      primaryContainer: Color(0xFF233F9E),
      onPrimaryContainer: Color(0xFFDDE3FF),
      secondary: Color(0xFF80D5D0),
      onSecondary: Color(0xFF003735),
      secondaryContainer: Color(0xFF00504D),
      onSecondaryContainer: Color(0xFFA0F2ED),
      tertiary: Color(0xFFCDC2FF),
      onTertiary: Color(0xFF32226F),
      tertiaryContainer: Color(0xFF49398A),
      onTertiaryContainer: Color(0xFFE8E0FF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF0D1320),
      onSurface: Color(0xFFE5E9F2),
      surfaceContainerLowest: Color(0xFF080D17),
      surfaceContainerLow: Color(0xFF141B29),
      surfaceContainer: Color(0xFF192131),
      surfaceContainerHigh: Color(0xFF212A3B),
      surfaceContainerHighest: Color(0xFF2B3547),
      onSurfaceVariant: Color(0xFFADB7C8),
      outline: Color(0xFF778297),
      outlineVariant: Color(0xFF303A4D),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFE5E9F2),
      onInverseSurface: Color(0xFF252D3B),
      inversePrimary: primary,
      surfaceTint: Color(0xFFB8C4FF),
    ),
  );

  static ThemeData _theme(ColorScheme colors) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      fontFamily: 'Poppins',
    );
    final textTheme = base.textTheme.apply(
      fontFamily: 'Poppins',
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    );
    final isLight = colors.brightness == Brightness.light;

    return base.copyWith(
      scaffoldBackgroundColor: colors.surface,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 32,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -.7,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -.35,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -.15,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
        bodySmall: textTheme.bodySmall?.copyWith(height: 1.4),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: .1,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shadowColor: colors.shadow.withValues(alpha: .08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: .85)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: .8),
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        floatingLabelStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          textStyle: textTheme.labelLarge,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          side: BorderSide(color: colors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
            size: 23,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 8,
        iconTheme: IconThemeData(color: colors.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colors.onSurface),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surfaceContainerLow,
        selectedColor: colors.primaryContainer,
        side: BorderSide(color: colors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        labelStyle: textTheme.labelMedium,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(color: colors.outlineVariant),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.primaryContainer
                : colors.surfaceContainerLow,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight
            ? const Color(0xFF202A3C)
            : colors.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
