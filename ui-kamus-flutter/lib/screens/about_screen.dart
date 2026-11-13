import 'package:flutter/material.dart';

import '../state/kamus_state.dart';
import '../widgets/common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.state});
  final KamusState state;

  Future<void> _showSuggestionDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final dialectController = TextEditingController(text: 'Kutai Umum');
    final colors = Theme.of(context).colorScheme;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usulkan kosakata'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: wordController, decoration: const InputDecoration(labelText: 'Kata'), validator: (value) => value == null || value.trim().isEmpty ? 'Kata wajib diisi' : null),
              const SizedBox(height: 10),
              TextFormField(controller: meaningController, decoration: const InputDecoration(labelText: 'Arti'), minLines: 2, maxLines: 4, validator: (value) => value == null || value.trim().isEmpty ? 'Arti wajib diisi' : null),
              const SizedBox(height: 10),
              TextFormField(controller: dialectController, decoration: const InputDecoration(labelText: 'Dialek')),
              const SizedBox(height: 10),
              Text('Usulan disimpan secara lokal di perangkat ini, belum dikirim ke pengelola.', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              await state.submitSuggestion(word: wordController.text, meaning: meaningController.text, dialect: dialectController.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usulan tersimpan di perangkat ini.')));
            },
            child: const Text('Simpan usulan'),
          ),
        ],
      ),
    );
    wordController.dispose();
    meaningController.dispose();
    dialectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: [
        Container(
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.auto_stories_rounded, size: 42, color: colors.onPrimary),
            const SizedBox(height: 10),
            Text('Kata Punya Cerita', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Arsip leksikon Kalimantan Timur', style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.8))),
          ]),
        ),
        const SizedBox(height: 20),
        const PageIntro(eyebrow: 'Dokumentasi terbuka', title: 'Tentang Kamus Kutai', subtitle: 'Ruang digital untuk mengenal, merawat, dan mempelajari kosakata bahasa Kutai.'),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.history_edu_rounded, color: colors.primary), const SizedBox(width: 10), Expanded(child: Text('Bahasa menyimpan cerita', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))]),
          const SizedBox(height: 10),
          const Text('Kamus Kutai adalah prototipe dokumentasi digital untuk memperkenalkan kosakata, ungkapan, contoh pemakaian, dan ragam dialek Kutai. Data awal disimpan terpisah dari tampilan agar mudah dikembangkan dan diperiksa kembali.' , style: TextStyle(height: 1.6)),
          const SizedBox(height: 12),
          Text('Catatan: makna serta contoh kata perlu diverifikasi bersama penutur lokal sebelum dijadikan rujukan resmi.', style: TextStyle(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic, height: 1.5)),
        ]))),
        const SizedBox(height: 14),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bantu perkaya kamus', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Punya kata atau ungkapan lain? Simpan usulan kosakata di perangkat untuk ditinjau kemudian.', style: TextStyle(color: colors.onSurfaceVariant, height: 1.5)),
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: () => _showSuggestionDialog(context), icon: const Icon(Icons.add_comment_rounded), label: const Text('Usulkan kosakata')),
          ListenableBuilder(
            listenable: state,
            builder: (context, _) {
              if (state.suggestions.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('${state.suggestions.length} usulan tersimpan secara lokal', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.secondary)),
              );
            },
          ),
        ]))),
        const SizedBox(height: 16),
        Center(child: Text('Kamus Kutai · Versi Flutter', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant))),
      ],
    );
  }
}
