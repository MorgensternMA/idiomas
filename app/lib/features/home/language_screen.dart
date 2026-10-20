import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/content_repository.dart';
import '../../core/theme.dart';
import '../grammar/grammar_list.dart';
import '../journal/journal_screen.dart';
import '../lessons/lesson_list.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen(this.code, {super.key});

  final String code;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<ContentRepository>().bundle?.language(widget.code);
    if (lang == null) return const Scaffold(body: Center(child: Text('Idioma no encontrado')));

    final pages = [LessonList(lang), GrammarList(lang), JournalScreen(lang)];
    return LanguageTheme(
      language: lang,
      child: Scaffold(
        appBar: AppBar(title: Text(lang.name)),
        body: pages[_tab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Lecciones'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Gramática'),
            NavigationDestination(icon: Icon(Icons.edit_note_outlined), label: 'Diario'),
          ],
        ),
      ),
    );
  }
}
