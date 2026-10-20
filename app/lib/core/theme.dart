import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'models.dart';

const _accents = {
  'en': Color(0xFF3D5A80),
  'pt': Color(0xFF2E7D5B),
  'ja': Color(0xFFB5452F),
};

Color accentFor(String lang) => _accents[lang] ?? const Color(0xFF555555);

ThemeData buildTheme(Brightness brightness, {Color seed = const Color(0xFF3D5A80)}) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}

/// Envuelve una pantalla con el tema del idioma.
class LanguageTheme extends StatelessWidget {
  const LanguageTheme({super.key, required this.language, required this.child});

  final Language language;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Theme(data: buildTheme(b, seed: accentFor(language.code)), child: child);
  }
}

class Md extends StatelessWidget {
  const Md(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = MarkdownStyleSheet.fromTheme(theme);
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: base.copyWith(
        p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        listBullet: theme.textTheme.bodyLarge,
        h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        h2Padding: const EdgeInsets.only(top: 16),
        blockquoteDecoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 3)),
        ),
        blockquotePadding: const EdgeInsets.all(12),
        tableBorder: TableBorder.all(color: theme.colorScheme.outlineVariant),
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        tableColumnWidth: const IntrinsicColumnWidth(),
      ),
    );
  }
}
