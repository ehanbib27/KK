import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../state/kamus_state.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.onSearch,
    required this.onOpenDictionary,
    required this.onOpenCategories,
    required this.onOpenCategory,
  });

  final KamusState state;
  final ValueChanged<String> onSearch;
  final VoidCallback onOpenDictionary;
  final VoidCallback onOpenCategories;
  final ValueChanged<String> onOpenCategory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openWord(DictionaryEntry entry) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => DetailScreen(state: widget.state, entry: entry),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colors = Theme.of(context).colorScheme;
    final featured = <DictionaryEntry?>[
      state.entryById('awang'),
      state.entryById('kula'),
      state.entryById('hanyut'),
    ].whereType<DictionaryEntry>().toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(30)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.history_edu_rounded, size: 16, color: colors.onSecondaryContainer),
                  const SizedBox(width: 6),
                  Text('ARSIP LISAN KUTAI', style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w800, color: colors.onSecondaryContainer)),
                ]),
              ),
              const SizedBox(height: 18),
              Text('Kenali Bahasa,\nKenali Budaya', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w800, height: 1.06)),
              const SizedBox(height: 10),
              Text('Temukan makna kata, ungkapan, dan cerita dari bahasa Kutai di tepian Sungai Mahakam.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSearch,
                decoration: InputDecoration(
                  hintText: 'Cari kata bahasa Kutai...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Cari',
                    onPressed: () => widget.onSearch(_searchController.text),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionHeading('Terakhir dicari', action: 'Buka kamus', onAction: widget.onOpenDictionary),
        ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final recent = state.recentSearches;
            if (recent.isEmpty) {
              return Text('Kata yang kamu cari akan muncul di sini.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant));
            }
            return SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final entry = recent[index];
                  return ActionChip(
                    avatar: const Icon(Icons.history_rounded, size: 16),
                    label: Text(entry.word),
                    onPressed: () => _openWord(entry),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        SectionHeading('Jelajahi kategori', action: 'Lihat semua', onAction: widget.onOpenCategories),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final count = state.countForCategory(category.id);
              return SizedBox(
                width: 150,
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => widget.onOpenCategory(category.id),
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(categoryIcon(category.iconName), color: colors.primary, size: 24),
                        const Spacer(),
                        Text(category.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('$count kosakata', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        SectionHeading('Kata punya cerita', action: 'Lihat semua', onAction: widget.onOpenDictionary),
        if (featured.isEmpty)
          const EmptyState(title: 'Belum ada kosakata', message: 'Tambahkan kata ke data JSON untuk mulai mengisi kamus.')
        else
          ...featured.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WordCard(entry: entry, state: state, onOpen: () => _openWord(entry)),
              )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NARASI MAHAKAM', style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.75), fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Bahasa Menyimpan Cerita', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Bahasa Kutai bukan sekadar jembatan percakapan. Setiap kata menyimpan cerita, ingatan, dan kearifan yang layak dirawat bersama.', style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.9), height: 1.55)),
          ]),
        ),
      ],
    );
  }
}
