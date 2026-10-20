enum Verdict { correct, accents, wrong }

/// Compara la respuesta con las aceptadas. Ignora mayúsculas, espacios de
/// más, la puntuación final y, en japonés, los espacios y 。、. Si solo
/// difieren las tildes, lo marca aparte: no es un error, pero vale la pena
/// avisar.
Verdict checkAnswer(String input, List<String> accepted) {
  final got = normalize(input);
  if (got.isEmpty) return Verdict.wrong;

  final norm = accepted.map(normalize).toList();
  if (norm.contains(got)) return Verdict.correct;

  final bare = stripAccents(got);
  if (norm.any((a) => stripAccents(a) == bare)) return Verdict.accents;

  return Verdict.wrong;
}

final _japanese = RegExp(r'[぀-ヿ一-鿿]');
final _edgePunct = RegExp(r'^[\s¿¡"“”]+|[\s.!?。！？"“”]+$');
final _spaces = RegExp(r'\s+');

String normalize(String s) {
  var out = s
      .toLowerCase()
      .replaceAll(RegExp('[’‘`´]'), "'")
      .replaceAll(_edgePunct, '')
      .replaceAll(_spaces, ' ')
      .trim();
  if (_japanese.hasMatch(out)) {
    out = out.replaceAll(RegExp(r'[\s、。　]'), '');
  }
  return out;
}

const _accentMap = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

String stripAccents(String s) =>
    s.split('').map((c) => _accentMap[c] ?? c).join();
