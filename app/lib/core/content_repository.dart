import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// El contenido viene empaquetado en la app (assets/content.json). Si se
/// configura un server de desarrollo (`idiomas serve`), se lee de ahí para
/// ver los cambios sin recompilar.
class ContentRepository extends ChangeNotifier {
  static const _devServerKey = 'dev_server_url';

  Bundle? bundle;
  String? devServer;
  String? error;
  bool fromDevServer = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    devServer = prefs.getString(_devServerKey);
    error = null;
    fromDevServer = false;

    if (devServer != null && devServer!.isNotEmpty) {
      try {
        final res = await http
            .get(Uri.parse('$devServer/api/bundle'))
            .timeout(const Duration(seconds: 4));
        if (res.statusCode != 200) throw Exception(res.body);
        bundle = Bundle.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
        fromDevServer = true;
        notifyListeners();
        return;
      } catch (e) {
        error = 'No pude leer el server de desarrollo, uso el contenido de la app.\n$e';
      }
    }

    final raw = await rootBundle.loadString('assets/content.json');
    bundle = Bundle.fromJson(jsonDecode(raw));
    notifyListeners();
  }

  Future<void> setDevServer(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    final clean = url?.trim().replaceAll(RegExp(r'/+$'), '');
    if (clean == null || clean.isEmpty) {
      await prefs.remove(_devServerKey);
    } else {
      await prefs.setString(_devServerKey, clean);
    }
    await load();
  }
}
