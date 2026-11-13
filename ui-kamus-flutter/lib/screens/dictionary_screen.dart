import 'dart:async';

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
  Timer? _debounce;
  String _query = '';
  String? _categoryId;
  String? _letter;
  List<DictionaryEntry> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _categoryId = widget.initialCategory;
    _controller = TextEditingController(text: _query);
    _recomputeFiltered();
  }

  @override
  void didUpdateWidget(covariant DictionaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    var changed = false;
    if (oldWidget.initialQuery != widget.initialQuery) {
      _debounce?.cancel();
      _query = widget.initialQuery;
      _controller.value = TextEditingValue(
        text: _query,
        selection: TextSelection.collapsed(offset: _query.length),
      );
      _letter = null;
      changed = true;
    }
    if (oldWidget.initialCategory != widget.initialCategory) {
      _categoryId = widget.initialCategory;
      changed = true;
    }
    if (changed) {
      _recomputeFiltered();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _recomputeFiltered() {
    _filtered = widget.state.filterEntries(
      query: _query,
      categoryId: _categoryId,
      letter: _letter,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        _query = '';
        _recomputeFiltered();
      });
      return;
    }
    // Keep the clear button responsive while debouncing the list filter.
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _query = value;
        _recomputeFiltered();
      });
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _query = '';
      _recomputeFiltered();
    });
  }

  void _selectCategory(String? categoryId) {
    _debounce?.cancel();
    setState(() {
      _query = _controller.text;
      _categoryId = categoryId;
      _recomputeFiltered();
    });
  }

  void _selectLetter(String? letter) {
    _debounce?.cancel();
    setState(() {
      _query = _controller.text;
      _letter = letter;
      _recomputeFiltered();
    });
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
    final availableLetters = state.availableLetters;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageIntro(
                  eyebrow: 'Khazanah bahasa benua',
                  title: 'Kamus Kutai',
                  subtitle: 'Jelajahi kosakata, makna, contoh pemakaian, dan ragam dialek.',
                ),
                TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari lema, arti, contoh, atau dialek...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Bersihkan pencarian',
                            onPressed: _clearSearch,
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
                          onSelected: (_) => _selectCategory(null),
                        ),
                      ),
                      ...state.categories.map((category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category.name),
                              selected: _categoryId == category.id,
                              onSelected: (_) => _selectCategory(category.id),
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
                    ChoiceChip(label: const Text('A–Z'), selected: _letter == null, onSelected: (_) => _selectLetter(null)),
                    ...availableLetters.map((letter) => ChoiceChip(
                          label: Text(letter),
                          selected: _letter == letter,
                          onSelected: (_) => _selectLetter(_letter == letter ? null : letter),
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
                      child: Text('${_filtered.length} kata', style: TextStyle(color: colors.onSecondaryContainer, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        if (_filtered.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 28),
            sliver: SliverToBoxAdapter(
              child: EmptyState(
                title: 'Kata tidak ditemukan',
                message: 'Coba kata lain atau ubah filter kategori dan huruf.',
                icon: Icons.search_off_rounded,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
            sliver: SliverList.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final entry = _filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WordCard(entry: entry, state: state, onOpen: () => _openEntry(entry)),
                );
              },
            ),
          ),
      ],
    );
  }
}
