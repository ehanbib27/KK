import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../state/kamus_state.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.state});
  final KamusState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final items = state.history;
        return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat penjelajahan', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (items.isNotEmpty)
            TextButton(onPressed: state.clearHistory, child: const Text('Hapus semua')),
          const SizedBox(width: 8),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: EmptyState(title: 'Belum ada riwayat', message: 'Kata yang dibuka akan tercatat di sini.', icon: Icons.history_rounded))
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final DictionaryEntry entry = items[index];
                return Card(child: ListTile(
                  leading: CircleAvatar(backgroundColor: colors.secondaryContainer, child: Icon(Icons.menu_book_rounded, color: colors.onSecondaryContainer)),
                  title: Text(entry.word, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(entry.meaning, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailScreen(state: state, entry: entry))),
                ));
              },
            ),
    );
      },
    );
  }
}
