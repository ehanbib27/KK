import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'state/kamus_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = KamusState();
  try {
    await state.load();
  } catch (error) {
    runApp(_StartupErrorApp(error: error));
    return;
  }
  runApp(KamusKutaiApp(state: state));
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Gagal memuat data kamus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KamusKutaiApp extends StatelessWidget {
  const KamusKutaiApp({super.key, required this.state});

  final KamusState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kamus Kutai',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MainShell(state: state),
        );
      },
    );
  }
}
