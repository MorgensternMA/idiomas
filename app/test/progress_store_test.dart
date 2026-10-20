import 'package:flutter_test/flutter_test.dart';
import 'package:idiomas/core/progress_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late ProgressStore store;

  setUp(() async {
    store = await ProgressStore.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
  });
  tearDown(() => store.close());

  test('práctica y consigna se marcan por separado', () async {
    await store.markPracticeDone('en', 'l1');
    var p = await store.progress('l1');
    expect(p.practiceDone, isTrue);
    expect(p.missionDone, isFalse);

    await store.markMissionDone('en', 'l1');
    p = await store.progress('l1');
    expect(p.practiceDone, isTrue);
    expect(p.missionDone, isTrue);
    expect((await store.progressFor('pt')), isEmpty);
  });

  test('el diario guarda la checklist y se filtra por idioma', () async {
    await store.addJournal(JournalEntry(
      lang: 'pt',
      lessonId: 'l',
      kind: JournalKind.mission,
      title: 'Lembrança',
      body: 'Me costó el perfeito.',
      checklist: {'Leí en voz alta': true, 'Usé a gente': false},
    ));
    await store.addJournal(JournalEntry(lang: 'en', kind: JournalKind.practice, title: 'x', body: 'y'));

    final pt = await store.journal('pt');
    expect(pt, hasLength(1));
    expect(pt.single.checklist, {'Leí en voz alta': true, 'Usé a gente': false});

    await store.deleteJournal(pt.single.id!);
    expect(await store.journal('pt'), isEmpty);
    expect(await store.journal('en'), hasLength(1));
  });
}
