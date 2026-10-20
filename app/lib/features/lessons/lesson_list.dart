import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/progress_store.dart';
import '../../core/theme.dart';
import 'lesson_screen.dart';

class LessonList extends StatelessWidget {
  const LessonList(this.lang, {super.key});

  final Language lang;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProgressStore>();
    return FutureBuilder(
      future: store.progressFor(lang.code),
      builder: (context, snap) {
        final progress = snap.data ?? const {};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Md(lang.intro),
            const SizedBox(height: 16),
            for (final (i, l) in lang.lessons.indexed)
              _LessonCard(lang: lang, lesson: l, number: i + 1, progress: progress[l.id]),
          ],
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lang, required this.lesson, required this.number, this.progress});

  final Language lang;
  final Lesson lesson;
  final int number;
  final LessonProgress? progress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = progress ?? const LessonProgress();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => LanguageTheme(language: lang, child: LessonScreen(lang: lang, lesson: lesson))),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primaryContainer,
                child: Text('$number', style: TextStyle(color: scheme.onPrimaryContainer)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(lesson.summary, style: text.bodyMedium),
                    const SizedBox(height: 8),
                    Wrap(spacing: 12, children: [
                      _Status(done: p.practiceDone, label: 'Práctica'),
                      _Status(done: p.missionDone, label: 'Consigna'),
                      if (lesson.level.isNotEmpty) Text(lesson.level, style: text.labelSmall),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = done ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    ]);
  }
}
