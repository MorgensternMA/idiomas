import 'package:flutter_test/flutter_test.dart';
import 'package:idiomas/core/answer_check.dart';

void main() {
  test('ignora mayúsculas, espacios y puntuación final', () {
    expect(checkAnswer('  she DOESN\'T drink   coffee. ', ["She doesn't drink coffee"]), Verdict.correct);
    expect(checkAnswer('¿Você já comeu?', ['Você já comeu']), Verdict.correct);
  });

  test('acepta apóstrofos tipográficos', () {
    expect(checkAnswer('I’ve already paid', ["I've already paid"]), Verdict.correct);
  });

  test('marca aparte cuando solo fallan las tildes', () {
    expect(checkAnswer('faco', ['faço']), Verdict.accents);
    expect(checkAnswer('voce ja comeu', ['Você já comeu']), Verdict.accents);
  });

  test('japonés: ignora espacios y 。', () {
    expect(checkAnswer('わたしは がくせいです。', ['わたしはがくせいです']), Verdict.correct);
    expect(checkAnswer('がくせいでした', ['がくせいです']), Verdict.wrong);
  });

  test('vacío o distinto es incorrecto', () {
    expect(checkAnswer('', ['works']), Verdict.wrong);
    expect(checkAnswer('work', ['works']), Verdict.wrong);
  });
}
