import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/content_repository.dart';
import 'core/progress_store.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final content = ContentRepository();
  final progress = await ProgressStore.open();
  await content.load();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: content),
      ChangeNotifierProvider.value(value: progress),
    ],
    child: const IdiomasApp(),
  ));
}

class IdiomasApp extends StatelessWidget {
  const IdiomasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idiomas',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}
