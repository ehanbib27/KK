import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/category_item.dart';
import '../models/dictionary_entry.dart';
import '../state/kamus_state.dart';

IconData categoryIcon(String name) {
  switch (name) {
    case 'groups':
    case 'diversity_3':
      return Icons.groups_rounded;
    case 'water':
      return Icons.water_drop_outlined;
    case 'directions_run':
      return Icons.directions_run_rounded;
    case 'temple_buddhist':
      return Icons.temple_buddhist_outlined;
    case 'restaurant':
    case 'skillet':
      return Icons.restaurant_outlined;
    case 'pets':
      return Icons.pets_outlined;
    case 'landscape':
      return Icons.landscape_outlined;
    case 'chat_bubble':
      return Icons.chat_bubble_outline_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                eyebrow.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.secondary,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.state, this.radius = 20});

  final KamusState state;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final data = state.profileImageBase64;
    ImageProvider? provider;
    if (data != null && data.isNotEmpty) {
      try {
        provider = MemoryImage(base64Decode(data));
      } catch (_) {
        provider = null;
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.secondaryContainer,
      foregroundImage: provider,
      child: provider == null
          ? Text(
              state.displayName.trim().isEmpty
                  ? 'K'
                  : state.displayName.trim()[0].toUpperCase(),
              style: TextStyle(
                color: colors.onSecondaryContainer,
                fontSize: radius,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.entry,
    required this.state,
    required this.onOpen,
    this.showExample = true,
  });

  final DictionaryEntry entry;
  final KamusState state;
  final VoidCallback onOpen;
  final bool showExample;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final category = state.categoryById(entry.categoryId)?.name ?? entry.categoryId;
    final favorite = state.favoriteIds.contains(entry.id);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Tag(label: category, filled: true),
                            _Tag(label: entry.dialect),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          entry.word,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (entry.pronunciation.isNotEmpty)
                          Text(
                            '/${entry.pronunciation}/ · ${entry.partOfSpeech}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: favorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                    onPressed: () => state.toggleFavorite(entry.id),
                    icon: Icon(
                      favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: favorite ? colors.primary : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(entry.meaning, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
              if (showExample && entry.example.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: colors.secondary, width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('“${entry.example}”', style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4)),
                      if (entry.translation.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(entry.translation, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, height: 1.4)),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text('Lihat makna'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.count,
    required this.onTap,
  });

  final CategoryItem category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(categoryIcon(category.iconName), color: colors.onSecondaryContainer),
              ),
              const SizedBox(height: 12),
              Text('$count kata', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.secondary)),
              const SizedBox(height: 5),
              Text(category.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Expanded(
                child: Text(
                  category.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, height: 1.35),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Buka rumpun', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.secondary, fontWeight: FontWeight.w700))),
                  Icon(Icons.arrow_forward_rounded, size: 17, color: colors.secondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message, this.icon = Icons.menu_book_outlined});

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 42, color: colors.secondary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: colors.onSurfaceVariant, height: 1.45)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.filled = false});
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? colors.secondaryContainer : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: filled ? colors.onSecondaryContainer : colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
