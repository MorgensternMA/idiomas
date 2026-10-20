import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/content_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _url = TextEditingController(text: context.read<ContentRepository>().devServer ?? '');

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContentRepository>();
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tus datos', style: text.titleMedium),
          const SizedBox(height: 4),
          const Text('El progreso y el diario se guardan solo en este teléfono. No hay cuentas ni nube.'),
          const SizedBox(height: 24),
          Text('Contenido', style: text.titleMedium),
          const SizedBox(height: 4),
          Text('Versión ${repo.bundle?.version ?? '—'}'
              '${repo.fromDevServer ? ' (desde el server de desarrollo)' : ' (incluida en la app)'}'),
          const SizedBox(height: 16),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Server de desarrollo (opcional)',
              hintText: 'http://192.168.0.10:8080',
              helperText: 'Para ver cambios del contenido sin recompilar. En el emulador de Android: http://10.0.2.2:8080',
              helperMaxLines: 3,
            ),
          ),
          if (repo.error != null) ...[
            const SizedBox(height: 8),
            Text(repo.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 12),
          Row(children: [
            FilledButton(onPressed: () => repo.setDevServer(_url.text), child: const Text('Guardar y recargar')),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _url.clear();
                repo.setDevServer(null);
              },
              child: const Text('Usar el de la app'),
            ),
          ]),
        ],
      ),
    );
  }
}
