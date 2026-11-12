import 'package:flutter/material.dart';

import '../models/category_item.dart';
import '../state/kamus_state.dart';
import '../widgets/common.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.state, required this.onOpenCategory});
  final KamusState state;
  final ValueChanged<String> onOpenCategory;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _sortByCount = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _count(CategoryItem category) => widget.state.entries.where((entry) => entry.categoryId == category.id).length;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final filtered = state.categories.where((category) {
      final q = _query.toLowerCase();
      return category.name.toLowerCase().contains(q) || category.description.toLowerCase().contains(q);
    }).toList();
    if (_sortByCount) filtered.sort((a, b) => _count(b).compareTo(_count(a)));
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
      children: [
        const PageIntro(
          eyebrow: 'Khazanah bahasa',
          title: 'Jelajahi kategori',
          subtitle: 'Pelajari kosakata berdasarkan rumpun kehidupan sehari-hari dan warisan tradisi.',
        ),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari rumpun tema kata...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () { _searchController.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.close_rounded)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: _sortByCount ? 'Urutkan berdasarkan nama' : 'Urutkan berdasarkan jumlah kata',
            onPressed: () => setState(() => _sortByCount = !_sortByCount),
            icon: const Icon(Icons.swap_vert_rounded),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Text('${filtered.length} rumpun tematik', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.secondary, letterSpacing: 1, fontWeight: FontWeight.w800))),
          Text('${state.entries.length} lema', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const EmptyState(title: 'Kategori tidak ditemukan', message: 'Coba kata pencarian lain.', icon: Icons.search_off_rounded)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final category = filtered[index];
              return CategoryCard(
                category: category,
                count: _count(category),
                onTap: () => widget.onOpenCategory(category.id),
              );
            },
          ),
      ],
    );
  }
}
