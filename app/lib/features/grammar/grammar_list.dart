import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../core/theme.dart';

class GrammarList extends StatelessWidget {
  const GrammarList(this.lang, {super.key});

  final Language lang;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final group in lang.groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(group.title.toUpperCase(),
                style: text.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary, letterSpacing: 1.2)),
          ),
          for (final t in lang.grammar.where((t) => t.group == group.id))
            ListTile(
              title: Text(t.title),
              subtitle: Text(t.summary),
              trailing: t.level.isEmpty ? null : Text(t.level, style: text.labelSmall),
              onTap: () => openTopic(context, lang, t),
            ),
        ],
      ],
    );
  }
}

void openTopic(BuildContext context, Language lang, GrammarTopic topic) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LanguageTheme(language: lang, child: GrammarTopicScreen(topic))),
  );
}

class GrammarTopicScreen extends StatelessWidget {
  const GrammarTopicScreen(this.topic, {super.key});

  final GrammarTopic topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic.summary, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Md(topic.body),
          ],
        ),
      ),
    );
  }
}
