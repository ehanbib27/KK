import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../state/kamus_state.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.state});
  final KamusState state;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _view = 'favorit';

  void _openEntry(DictionaryEntry entry) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DetailScreen(state: widget.state, entry: entry)));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colors = Theme.of(context).colorScheme;
    final items = _view == 'favorit' ? state.favorites : state.history;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.bookmarks_rounded, color: colors.onSecondaryContainer)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ARSIP PRIBADI', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.secondary, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                Text('Kata tersimpan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
              ])),
            ]),
            const SizedBox(height: 10),
            Text('Simpan kosakata yang ingin kamu pelajari kembali.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.45)),
          ]),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'favorit', icon: Icon(Icons.bookmark_rounded), label: Text('Favorit')),
            ButtonSegment(value: 'riwayat', icon: Icon(Icons.history_rounded), label: Text('Riwayat')),
          ],
          selected: {_view},
          onSelectionChanged: (value) => setState(() => _view = value.first),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text(_view == 'favorit' ? '${items.length} kata tersimpan' : '${items.length} kata dibuka', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.secondary, fontWeight: FontWeight.w800))),
          if (_view == 'riwayat' && items.isNotEmpty)
            TextButton(onPressed: () async => state.clearHistory(), child: const Text('Hapus riwayat')),
        ]),
        const SizedBox(height: 8),
        if (items.isEmpty)
          EmptyState(
            title: _view == 'favorit' ? 'Belum ada kata favorit' : 'Riwayat masih kosong',
            message: _view == 'favorit' ? 'Tekan ikon bookmark pada kartu kata untuk menyimpannya di sini.' : 'Buka detail kata dari kamus untuk membuat riwayat belajar.',
            icon: _view == 'favorit' ? Icons.bookmark_border_rounded : Icons.history_rounded,
          )
        else
          ...items.map((DictionaryEntry entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WordCard(entry: entry, state: state, onOpen: () => _openEntry(entry), showExample: false),
              )),
      ],
    );
  }
}
