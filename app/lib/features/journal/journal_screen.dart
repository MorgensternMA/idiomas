import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/progress_store.dart';

/// Todo lo que escribiste en las prácticas abiertas y lo que anotaste al
/// volver de cada consigna. Sirve para ver cómo cambia tu forma de escribir.
class JournalScreen extends StatelessWidget {
  const JournalScreen(this.lang, {super.key});

  final Language lang;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProgressStore>();
    return FutureBuilder(
      future: store.journal(lang.code),
      builder: (context, snap) {
        final entries = snap.data;
        if (entries == null) return const Center(child: CircularProgressIndicator());
        if (entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Acá van a aparecer lo que escribas en las prácticas y tus notas de cada consigna.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final lessons = {for (final l in lang.lessons) l.id: l.title};
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, i) => _EntryCard(entries[i], lessonTitle: lessons[entries[i].lessonId]),
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard(this.entry, {this.lessonTitle});

  final JournalEntry entry;
  final String? lessonTitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isMission = entry.kind == JournalKind.mission;
    final done = entry.checklist.values.where((v) => v).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(isMission ? Icons.flag_outlined : Icons.edit_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text('${_date(entry.at)}${lessonTitle == null ? '' : ' · $lessonTitle'}',
                    style: text.labelSmall, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Borrar',
                onPressed: () => _confirmDelete(context),
              ),
            ]),
            Text(entry.title, style: text.titleSmall),
            if (entry.body.isNotEmpty) ...[
              const SizedBox(height: 6),
              SelectableText(entry.body, style: text.bodyLarge),
            ],
            if (isMission && entry.checklist.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Checklist: $done de ${entry.checklist.length}', style: text.labelMedium),
              for (final MapEntry(:key, :value) in entry.checklist.entries)
                Text('${value ? '✓' : '·'}  $key', style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: const Text('¿Borrar esta entrada del diario?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<ProgressStore>().deleteJournal(entry.id!);
    }
  }
}

const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String _date(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
