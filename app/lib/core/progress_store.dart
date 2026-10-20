import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Todo lo del usuario vive acá, en una base SQLite en el teléfono. No hay
/// cuentas ni nube.
class ProgressStore extends ChangeNotifier {
  ProgressStore._(this._db);

  final Database _db;

  static Future<ProgressStore> open({DatabaseFactory? factory, String? path}) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await f.getDatabasesPath(), 'idiomas.db');
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: 1, onCreate: _create),
    );
    return ProgressStore._(db);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lesson_progress (
        lesson_id TEXT PRIMARY KEY,
        lang TEXT NOT NULL,
        practice_done_at INTEGER,
        mission_done_at INTEGER
      )''');
    // Cada intento queda guardado: es la base para el repaso espaciado.
    await db.execute('''
      CREATE TABLE exercise_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id TEXT NOT NULL,
        exercise_index INTEGER NOT NULL,
        answer TEXT NOT NULL,
        correct INTEGER NOT NULL,
        at INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE journal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lang TEXT NOT NULL,
        lesson_id TEXT,
        kind TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        checklist TEXT,
        at INTEGER NOT NULL
      )''');
  }

  Future<void> close() => _db.close();

  Future<LessonProgress> progress(String lessonId) async {
    final rows = await _db.query('lesson_progress',
        where: 'lesson_id = ?', whereArgs: [lessonId]);
    return rows.isEmpty ? const LessonProgress() : LessonProgress.fromRow(rows.first);
  }

  Future<Map<String, LessonProgress>> progressFor(String lang) async {
    final rows = await _db.query('lesson_progress', where: 'lang = ?', whereArgs: [lang]);
    return {for (final r in rows) r['lesson_id'] as String: LessonProgress.fromRow(r)};
  }

  Future<void> markPracticeDone(String lang, String lessonId) =>
      _mark(lang, lessonId, 'practice_done_at');

  Future<void> markMissionDone(String lang, String lessonId) =>
      _mark(lang, lessonId, 'mission_done_at');

  Future<void> _mark(String lang, String lessonId, String column) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.rawInsert('''
      INSERT INTO lesson_progress (lesson_id, lang, $column) VALUES (?, ?, ?)
      ON CONFLICT(lesson_id) DO UPDATE SET $column = excluded.$column''',
        [lessonId, lang, now]);
    notifyListeners();
  }

  Future<void> recordAttempt(String lessonId, int index, String answer, bool correct) =>
      _db.insert('exercise_attempts', {
        'lesson_id': lessonId,
        'exercise_index': index,
        'answer': answer,
        'correct': correct ? 1 : 0,
        'at': DateTime.now().millisecondsSinceEpoch,
      });

  Future<void> addJournal(JournalEntry e) async {
    await _db.insert('journal', e.toRow()..remove('id'));
    notifyListeners();
  }

  Future<List<JournalEntry>> journal(String lang) async {
    final rows = await _db.query('journal',
        where: 'lang = ?', whereArgs: [lang], orderBy: 'at DESC, id DESC');
    return rows.map(JournalEntry.fromRow).toList();
  }

  Future<void> deleteJournal(int id) async {
    await _db.delete('journal', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }
}

class LessonProgress {
  const LessonProgress({this.practiceDone = false, this.missionDone = false});

  final bool practiceDone;
  final bool missionDone;

  factory LessonProgress.fromRow(Map<String, Object?> r) => LessonProgress(
        practiceDone: r['practice_done_at'] != null,
        missionDone: r['mission_done_at'] != null,
      );
}

enum JournalKind { mission, practice }

class JournalEntry {
  JournalEntry({
    this.id,
    required this.lang,
    this.lessonId,
    required this.kind,
    required this.title,
    required this.body,
    this.checklist = const {},
    DateTime? at,
  }) : at = at ?? DateTime.now();

  final int? id;
  final String lang;
  final String? lessonId;
  final JournalKind kind;
  final String title;
  final String body;

  /// Ítem de la checklist → si lo marcaste.
  final Map<String, bool> checklist;
  final DateTime at;

  Map<String, Object?> toRow() => {
        'id': id,
        'lang': lang,
        'lesson_id': lessonId,
        'kind': kind.name,
        'title': title,
        'body': body,
        'checklist': checklist.isEmpty ? null : jsonEncode(checklist),
        'at': at.millisecondsSinceEpoch,
      };

  factory JournalEntry.fromRow(Map<String, Object?> r) => JournalEntry(
        id: r['id'] as int,
        lang: r['lang'] as String,
        lessonId: r['lesson_id'] as String?,
        kind: JournalKind.values.byName(r['kind'] as String),
        title: r['title'] as String,
        body: r['body'] as String,
        checklist: r['checklist'] == null
            ? const {}
            : Map<String, bool>.from(jsonDecode(r['checklist'] as String)),
        at: DateTime.fromMillisecondsSinceEpoch(r['at'] as int),
      );
}
