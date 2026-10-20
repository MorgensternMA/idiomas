import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/answer_check.dart';
import '../../core/models.dart';
import '../../core/progress_store.dart';
import '../../core/theme.dart';

/// Los ejercicios de a uno. No hay puntos ni vidas: al final ves cuáles te
/// costaron y podés repetir.
class PracticeView extends StatefulWidget {
  const PracticeView({super.key, required this.lang, required this.lesson});

  final Language lang;
  final Lesson lesson;

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<PracticeView> with AutomaticKeepAliveClientMixin {
  int _index = 0;
  int _round = 0;
  final _missed = <int>{};

  @override
  bool get wantKeepAlive => true;

  List<Exercise> get _exercises => widget.lesson.practice;

  void _next(bool firstTry) {
    if (!firstTry) _missed.add(_index);
    setState(() => _index++);
    if (_index == _exercises.length) {
      context.read<ProgressStore>().markPracticeDone(widget.lang.code, widget.lesson.id);
    }
  }

  void _restart() => setState(() {
        _index = 0;
        _round++;
        _missed.clear();
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_index >= _exercises.length) return _summary(context);

    final ex = _exercises[_index];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: _index / _exercises.length),
        const SizedBox(height: 8),
        Text('${_index + 1} de ${_exercises.length}', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 16),
        ExerciseCard(
          key: ValueKey('$_round-$_index'),
          exercise: ex,
          lang: widget.lang,
          lesson: widget.lesson,
          index: _index,
          onDone: _next,
        ),
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Práctica terminada', style: text.headlineSmall),
        const SizedBox(height: 8),
        if (_missed.isEmpty)
          const Text('Todo salió al primer intento. Pasá a la consigna de afuera: ahí está lo importante.')
        else ...[
          const Text('Estos te costaron. Releelos con calma antes de seguir:'),
          const SizedBox(height: 8),
          for (final i in _missed)
            ListTile(
              dense: true,
              leading: const Icon(Icons.replay, size: 18),
              title: Text(_exercises[i].prompt),
              subtitle: _exercises[i].answers.isEmpty ? null : Text(_exercises[i].answers.first),
            ),
        ],
        const SizedBox(height: 16),
        Row(children: [
          OutlinedButton(onPressed: _restart, child: const Text('Repetir')),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => DefaultTabController.of(context).animateTo(2),
            child: const Text('Ir a la consigna'),
          ),
        ]),
      ],
    );
  }
}

class ExerciseCard extends StatefulWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.lang,
    required this.lesson,
    required this.index,
    required this.onDone,
  });

  final Exercise exercise;
  final Language lang;
  final Lesson lesson;
  final int index;

  /// Se llama con true si salió al primer intento.
  final void Function(bool firstTry) onDone;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final _controller = TextEditingController();
  Verdict? _verdict;
  bool _revealed = false;
  bool _failedOnce = false;
  bool _showHint = false;

  Exercise get ex => widget.exercise;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final answer = _controller.text;
    if (answer.trim().isEmpty) return;
    final v = checkAnswer(answer, ex.answers);
    context.read<ProgressStore>().recordAttempt(widget.lesson.id, widget.index, answer, v != Verdict.wrong);
    setState(() {
      _verdict = v;
      if (v == Verdict.wrong) _failedOnce = true;
    });
  }

  void _compare() {
    if (_controller.text.trim().isEmpty) return;
    context.read<ProgressStore>().addJournal(JournalEntry(
          lang: widget.lang.code,
          lessonId: widget.lesson.id,
          kind: JournalKind.practice,
          title: ex.prompt,
          body: _controller.text.trim(),
        ));
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isOpen = ex.type == ExerciseType.open;
    final solved = _verdict == Verdict.correct || _verdict == Verdict.accents || _revealed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ex.instruction.isNotEmpty) Text(ex.instruction, style: text.bodyMedium),
        const SizedBox(height: 8),
        Text(ex.prompt, style: text.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          autofocus: true,
          enabled: !solved,
          minLines: isOpen ? 4 : 1,
          maxLines: isOpen ? 10 : 2,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: isOpen ? TextInputAction.newline : TextInputAction.done,
          onSubmitted: isOpen ? null : (_) => _check(),
          decoration: InputDecoration(
            hintText: isOpen ? 'Escribí acá, sin mirar el modelo' : 'Tu respuesta',
          ),
        ),
        if (_showHint && ex.hint.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Pista: ${ex.hint}', style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 12),
        if (isOpen) ..._openFeedback(context) else ..._writeFeedback(context),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!solved && !isOpen && ex.hint.isNotEmpty && !_showHint)
              TextButton(onPressed: () => setState(() => _showHint = true), child: const Text('Pista')),
            if (!solved && !isOpen && _failedOnce)
              TextButton(onPressed: () => setState(() => _revealed = true), child: const Text('Ver respuesta')),
            const SizedBox(width: 8),
            if (!solved)
              FilledButton(
                onPressed: isOpen ? _compare : _check,
                child: Text(isOpen ? 'Comparar con un modelo' : 'Comprobar'),
              )
            else
              FilledButton(
                onPressed: () => widget.onDone(!_failedOnce),
                child: const Text('Seguir'),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _writeFeedback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final expected = ex.answers.first;
    Widget box(Color bg, Color fg, String msg) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(msg, style: TextStyle(color: fg)),
            if (ex.note.isNotEmpty) ...[const SizedBox(height: 6), Md(ex.note)],
          ]),
        );

    if (_revealed) {
      return [box(scheme.secondaryContainer, scheme.onSecondaryContainer, 'Respuesta: $expected')];
    }
    return switch (_verdict) {
      Verdict.correct => [box(scheme.primaryContainer, scheme.onPrimaryContainer, 'Bien.')],
      Verdict.accents => [
          box(scheme.tertiaryContainer, scheme.onTertiaryContainer, 'Bien, pero ojo con los acentos: $expected')
        ],
      Verdict.wrong => [
          box(scheme.errorContainer, scheme.onErrorContainer, 'No es así. Probá de nuevo; si no sale, mirá la respuesta.')
        ],
      null => const [],
    };
  }

  List<Widget> _openFeedback(BuildContext context) {
    if (!_revealed) return const [];
    final text = Theme.of(context).textTheme;
    return [
      Text('Una versión posible', style: text.titleSmall),
      const SizedBox(height: 4),
      Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(ex.model, style: text.bodyLarge))),
      const SizedBox(height: 8),
      Text(
        'No tiene que ser igual. Fijate si usaste las estructuras de la lección y si algo del modelo te sirve. '
        'Lo que escribiste quedó en tu diario.',
        style: text.bodySmall,
      ),
    ];
  }
}
