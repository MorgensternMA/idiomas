import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../grammar/grammar_list.dart';
import 'mission_view.dart';
import 'practice_view.dart';

/// Una lección en tres pasos: entender, practicar y hacer algo afuera.
class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lang, required this.lesson});

  final Language lang;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.title),
          bottom: const TabBar(tabs: [
            Tab(text: '1 · Entender'),
            Tab(text: '2 · Practicar'),
            Tab(text: '3 · Afuera'),
          ]),
        ),
        body: TabBarView(children: [
          _ExplainView(lang: lang, lesson: lesson),
          PracticeView(lang: lang, lesson: lesson),
          MissionView(lang: lang, lesson: lesson),
        ]),
      ),
    );
  }
}

class _ExplainView extends StatelessWidget {
  const _ExplainView({required this.lang, required this.lesson});

  final Language lang;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final related = lesson.grammar.map(lang.topic).whereType<GrammarTopic>().toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Md(lesson.explain),
        if (related.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Para profundizar', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final t in related)
                ActionChip(
                  avatar: const Icon(Icons.menu_book_outlined, size: 16),
                  label: Text(t.title),
                  onPressed: () => openTopic(context, lang, t),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            onPressed: () => DefaultTabController.of(context).animateTo(1),
            child: const Text('A practicar'),
          ),
        ),
      ],
    );
  }
}
