import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models.dart';
import '../../core/progress_store.dart';
import '../../core/theme.dart';

const _kindLabels = {
  MissionKind.write: ('Escribir', Icons.edit_outlined),
  MissionKind.speak: ('Hablar', Icons.record_voice_over_outlined),
  MissionKind.listen: ('Escuchar', Icons.hearing_outlined),
  MissionKind.read: ('Leer', Icons.auto_stories_outlined),
};

/// La consigna para hacer fuera del teléfono. Al volver, marcás la checklist
/// y anotás cómo te fue; queda en el diario.
class MissionView extends StatefulWidget {
  const MissionView({super.key, required this.lang, required this.lesson});

  final Language lang;
  final Lesson lesson;

  @override
  State<MissionView> createState() => _MissionViewState();
}

class _MissionViewState extends State<MissionView> with AutomaticKeepAliveClientMixin {
  late final Map<String, bool> _checks = {for (final c in widget.lesson.mission.checklist) c: false};
  final _notes = TextEditingController();
  bool _saved = false;

  @override
  bool get wantKeepAlive => true;

  Mission get m => widget.lesson.mission;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = context.read<ProgressStore>();
    await store.addJournal(JournalEntry(
      lang: widget.lang.code,
      lessonId: widget.lesson.id,
      kind: JournalKind.mission,
      title: m.title,
      body: _notes.text.trim(),
      checklist: Map.of(_checks),
    ));
    await store.markMissionDone(widget.lang.code, widget.lesson.id);
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final text = Theme.of(context).textTheme;
    final (label, icon) = _kindLabels[m.kind]!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: text.labelLarge),
          if (m.minutes > 0) Text(' · unos ${m.minutes} minutos', style: text.labelLarge),
        ]),
        const SizedBox(height: 8),
        Text(m.title, style: text.headlineSmall),
        const SizedBox(height: 12),
        Md(m.task),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        Text('Cuando termines', style: text.titleMedium),
        const SizedBox(height: 4),
        Text('La lista es para vos: marcá solo lo que de verdad hiciste.', style: text.bodySmall),
        for (final item in _checks.keys)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _checks[item],
            onChanged: _saved ? null : (v) => setState(() => _checks[item] = v ?? false),
            title: Text(item),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          enabled: !_saved,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: '¿Cómo te fue?',
            hintText: 'Dudas, palabras que te faltaron, qué querés repasar...',
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: _saved
              ? const Chip(avatar: Icon(Icons.check, size: 16), label: Text('Guardado en el diario'))
              : FilledButton(onPressed: _save, child: const Text('Lo hice')),
        ),
      ],
    );
  }
}
