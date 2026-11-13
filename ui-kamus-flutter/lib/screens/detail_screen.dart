import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/dictionary_entry.dart';
import '../state/kamus_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.state, required this.entry});
  final KamusState state;
  final DictionaryEntry entry;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.state.recordOpen(widget.entry.id);
    });
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final state = widget.state;
    final colors = Theme.of(context).colorScheme;
    final category = state.categoryById(entry.categoryId)?.name ?? entry.categoryId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail kata', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Salin detail kata',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: '${entry.word}\n${entry.meaning}\n${entry.example}\n${entry.translation}'));
              if (context.mounted) _message('Detail kata disalin.');
            },
            icon: const Icon(Icons.copy_all_rounded),
          ),
          ListenableBuilder(
            listenable: state,
            builder: (context, _) {
              final isFavorite = state.favoriteIds.contains(entry.id);
              return IconButton(
                tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                onPressed: () => state.toggleFavorite(entry.id),
                icon: Icon(isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: colors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24), border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 7, runSpacing: 7, children: [
                _Pill(category),
                _Pill(entry.dialect, pale: true),
              ]),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry.word, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('/${entry.pronunciation}/', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic)),
                ])),
                IconButton.filledTonal(
                  tooltip: 'Pelafalan audio belum tersedia',
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click);
                    _message('Audio pelafalan belum tersedia untuk kata ini.');
                  },
                  icon: const Icon(Icons.volume_up_rounded),
                  iconSize: 25,
                ),
              ]),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              Text('KELAS KATA', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.secondary, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(entry.partOfSpeech, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              Text('Makna', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              Text(entry.meaning, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
            ]),
          ),
          const SizedBox(height: 14),
          _ContentCard(
            title: 'Contoh penggunaan',
            icon: Icons.format_quote_rounded,
            child: Text('“${entry.example}”', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, height: 1.55)),
          ),
          const SizedBox(height: 14),
          _ContentCard(
            title: 'Terjemahan bahasa Indonesia',
            icon: Icons.translate_rounded,
            child: Text(entry.translation, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55)),
          ),
          const SizedBox(height: 14),
          _ContentCard(
            title: 'Catatan leksikon',
            icon: Icons.history_edu_rounded,
            child: Text(
              entry.note.isNotEmpty ? entry.note : 'Belum ada catatan tambahan untuk lema ini.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: state,
            builder: (context, _) {
              final isFavorite = state.favoriteIds.contains(entry.id);
              return FilledButton.icon(
                onPressed: () => state.toggleFavorite(entry.id),
                icon: Icon(isFavorite ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded),
                label: Text(isFavorite ? 'Hapus dari kata favorit' : 'Simpan ke kata favorit'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.pale = false});
  final String text;
  final bool pale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: pale ? colors.surfaceContainerHigh : colors.secondaryContainer, borderRadius: BorderRadius.circular(30)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: pale ? colors.onSurfaceVariant : colors.onSecondaryContainer, fontWeight: FontWeight.w700)),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: colors.secondary), const SizedBox(width: 9), Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)))]),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}
