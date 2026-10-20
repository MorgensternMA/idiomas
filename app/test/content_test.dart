import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:idiomas/core/models.dart';

void main() {
  test('el content.json generado por Go se parsea entero', () {
    final raw = File('assets/content.json').readAsStringSync();
    final b = Bundle.fromJson(jsonDecode(raw));

    expect(b.languages.map((l) => l.code), containsAll(['en', 'pt', 'ja']));
    for (final lang in b.languages) {
      expect(lang.lessons, isNotEmpty, reason: lang.code);
      for (final lesson in lang.lessons) {
        for (final ref in lesson.grammar) {
          expect(lang.topic(ref), isNotNull, reason: '${lesson.id} → $ref');
        }
      }
    }
  });
}
