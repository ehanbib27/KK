import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../state/kamus_state.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({
    super.key,
    required this.state,
    required this.initialQuery,
    required this.initialCategory,
  });

  final KamusState state;
  final String initialQuery;
  final String? initialCategory;

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late final TextEditingController _controller;
  String _query = '';
  String? _categoryId;
  String? _letter;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _categoryId = widget.initialCategory;
    _controller = TextEditingController(text: _query);
  }

  @override
  void didUpdateWidget(covariant DictionaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _query = widget.initialQuery;
      _controller.value = TextEditingValue(
        text: _query,
        selection: TextSelection.collapsed(offset: _query.length),
      );
      _letter = null;
    }
    if (oldWidget.initialCategory != widget.initialCategory) {
      _categoryId = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openEntry(DictionaryEntry entry) {
    widget.state.recordOpen(entry.id);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => DetailScreen(state: widget.state, entry: entry),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colors = Theme.of(context).colorScheme;
    final filtered = state.entries.where((entry) {
      final queryMatches = entry.matches(_query);
      final categoryMatches = _categoryId == null || _categoryId!.isEmpty || entry.categoryId == _categoryId;
      final letterMatches = _letter == null || entry.word.toUpperCase().startsWith(_letter!);
      return queryMatches && categoryMatches && letterMatches;
    }).toList();
    final availableLetters = state.entries.map((entry) => entry.word[0].toUpperCase()).toSet().toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      children: [
        const PageIntro(
          eyebrow: 'Khazanah bahasa benua',
          title: 'Kamus Kutai',
          subtitle: 'Jelajahi kosakata, makna, contoh pemakaian, dan ragam dialek.',
        ),
        TextField(
          controller: _controller,
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari lema, arti, contoh, atau dialek...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Bersihkan pencarian',
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Kategori', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Semua'),
                  selected: _categoryId == null || _categoryId!.isEmpty,
                  onSelected: (_) => setState(() => _categoryId = null),
                ),
              ),
              ...state.categories.map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _categoryId == category.id,
                      onSelected: (_) => setState(() => _categoryId = category.id),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('Huruf awal', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ChoiceChip(label: const Text('A–Z'), selected: _letter == null, onSelected: (_) => setState(() => _letter = null)),
            ...availableLetters.map((letter) => ChoiceChip(
                  label: Text(letter),
                  selected: _letter == letter,
                  onSelected: (_) => setState(() => _letter = _letter == letter ? null : letter),
                )),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text('Hasil pencarian', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(30)),
              child: Text('${filtered.length} kata', style: TextStyle(color: colors.onSecondaryContainer, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          const EmptyState(title: 'Kata tidak ditemukan', message: 'Coba kata lain atau ubah filter kategori dan huruf.', icon: Icons.search_off_rounded)
        else
          ...filtered.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WordCard(entry: entry, state: state, onOpen: () => _openEntry(entry)),
              )),
      ],
    );
  }
}
