// Espejo de backend/internal/content/model.go. El JSON lo genera
// `idiomas build`.

class Bundle {
  Bundle({required this.version, required this.languages});

  final String version;
  final List<Language> languages;

  factory Bundle.fromJson(Map<String, dynamic> j) => Bundle(
        version: j['version'] as String,
        languages: _list(j['languages'], Language.fromJson),
      );

  Language? language(String code) =>
      languages.where((l) => l.code == code).firstOrNull;
}

class Language {
  Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.intro,
    required this.groups,
    required this.grammar,
    required this.lessons,
  });

  final String code;
  final String name;
  final String nativeName;
  final String intro;
  final List<Group> groups;
  final List<GrammarTopic> grammar;
  final List<Lesson> lessons;

  factory Language.fromJson(Map<String, dynamic> j) => Language(
        code: j['code'] as String,
        name: j['name'] as String,
        nativeName: j['nativeName'] as String? ?? '',
        intro: j['intro'] as String? ?? '',
        groups: _list(j['groups'], Group.fromJson),
        grammar: _list(j['grammar'], GrammarTopic.fromJson),
        lessons: _list(j['lessons'], Lesson.fromJson),
      );

  GrammarTopic? topic(String id) => grammar.where((t) => t.id == id).firstOrNull;
}

class Group {
  Group({required this.id, required this.title});

  final String id;
  final String title;

  factory Group.fromJson(Map<String, dynamic> j) =>
      Group(id: j['id'] as String, title: j['title'] as String);
}

class GrammarTopic {
  GrammarTopic({
    required this.id,
    required this.title,
    required this.group,
    required this.level,
    required this.summary,
    required this.body,
  });

  final String id;
  final String title;
  final String group;
  final String level;
  final String summary;
  final String body;

  factory GrammarTopic.fromJson(Map<String, dynamic> j) => GrammarTopic(
        id: j['id'] as String,
        title: j['title'] as String,
        group: j['group'] as String,
        level: j['level'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        body: j['body'] as String,
      );
}

class Lesson {
  Lesson({
    required this.id,
    required this.title,
    required this.level,
    required this.summary,
    required this.grammar,
    required this.explain,
    required this.practice,
    required this.mission,
  });

  final String id;
  final String title;
  final String level;
  final String summary;
  final List<String> grammar;
  final String explain;
  final List<Exercise> practice;
  final Mission mission;

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        title: j['title'] as String,
        level: j['level'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        grammar: List<String>.from(j['grammar'] ?? const []),
        explain: j['explain'] as String,
        practice: _list(j['practice'], Exercise.fromJson),
        mission: Mission.fromJson(j['mission'] as Map<String, dynamic>),
      );
}

enum ExerciseType { write, open }

class Exercise {
  Exercise({
    required this.type,
    required this.instruction,
    required this.prompt,
    required this.answers,
    required this.hint,
    required this.model,
    required this.note,
  });

  final ExerciseType type;
  final String instruction;
  final String prompt;
  final List<String> answers;
  final String hint;
  final String model;
  final String note;

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        type: ExerciseType.values.byName(j['type'] as String),
        instruction: j['instruction'] as String? ?? '',
        prompt: j['prompt'] as String,
        answers: List<String>.from(j['answers'] ?? const []),
        hint: j['hint'] as String? ?? '',
        model: j['model'] as String? ?? '',
        note: j['note'] as String? ?? '',
      );
}

enum MissionKind { write, speak, listen, read }

class Mission {
  Mission({
    required this.kind,
    required this.title,
    required this.minutes,
    required this.task,
    required this.checklist,
  });

  final MissionKind kind;
  final String title;
  final int minutes;
  final String task;
  final List<String> checklist;

  factory Mission.fromJson(Map<String, dynamic> j) => Mission(
        kind: MissionKind.values.byName(j['kind'] as String),
        title: j['title'] as String,
        minutes: j['minutes'] as int? ?? 0,
        task: j['task'] as String,
        checklist: List<String>.from(j['checklist'] ?? const []),
      );
}

List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
    (raw as List? ?? const []).map((e) => f(e as Map<String, dynamic>)).toList();
