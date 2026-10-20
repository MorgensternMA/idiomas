import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/content_repository.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../settings/settings_screen.dart';
import 'language_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final bundle = repo.bundle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idiomas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: bundle == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (repo.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(repo.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                Text('¿Qué estudiamos hoy?',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Un rato de lectura, un poco de práctica y algo para hacer fuera del teléfono.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                for (final lang in bundle.languages) _LanguageCard(lang),
              ],
            ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard(this.lang);

  final Language lang;

  @override
  Widget build(BuildContext context) {
    final accent = accentFor(lang.code);
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => LanguageScreen(lang.code))),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: accent, width: 6))),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang.name, style: text.titleLarge),
              Text(lang.nativeName, style: text.bodyMedium?.copyWith(color: accent)),
              const SizedBox(height: 8),
              Text('${lang.lessons.length} lecciones · ${lang.grammar.length} temas de gramática',
                  style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
