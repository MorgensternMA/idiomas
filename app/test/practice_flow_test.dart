import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idiomas/core/models.dart';
import 'package:idiomas/core/progress_store.dart';
import 'package:idiomas/features/lessons/practice_view.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  final lesson = Lesson.fromJson({
    'id': 'l',
    'title': 'L',
    'explain': 'x',
    'practice': [
      {'type': 'write', 'prompt': 'She ___ (work).', 'answers': ['works']},
    ],
    'mission': {'kind': 'write', 'title': 'M', 'task': 't'},
  });
  final lang = Language.fromJson({'code': 'en', 'name': 'Inglés', 'lessons': [], 'grammar': [], 'groups': []});

  testWidgets('corrige, deja reintentar y termina la práctica', (tester) async {
    final store = (await tester.runAsync(
        () => ProgressStore.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath)))!;

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: store,
      child: MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(body: PracticeView(lang: lang, lesson: lesson)),
        ),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'work');
    await tester.tap(find.text('Comprobar'));
    await tester.pump();
    expect(find.textContaining('No es así'), findsOneWidget);
    expect(find.text('Ver respuesta'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'works');
    await tester.tap(find.text('Comprobar'));
    await tester.pump();
    expect(find.text('Bien.'), findsOneWidget);

    await tester.tap(find.text('Seguir'));
    await tester.pump();
    expect(find.text('Práctica terminada'), findsOneWidget);
    // Falló una vez: aparece en la lista de repaso.
    expect(find.text('She ___ (work).'), findsOneWidget);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect((await store.progress('l')).practiceDone, isTrue);
      await store.close();
    });
  });
}
