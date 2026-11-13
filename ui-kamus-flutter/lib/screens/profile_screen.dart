import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../state/kamus_state.dart';
import '../widgets/common.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.state});
  final KamusState state;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 88,
      );
      if (file == null) return;
      setState(() => _busy = true);
      await widget.state.setProfileImage(await file.readAsBytes());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil disimpan.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto gagal disimpan: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveProfile() async {
    await widget.state.setDisplayName(_nameController.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan di perangkat.')));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        children: [
          const PageIntro(eyebrow: 'Ruang pribadi', title: 'Profil', subtitle: 'Preferensi lokal untuk pengalaman belajar Kamus Kutai.'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Stack(children: [
                    ProfileAvatar(state: state, radius: 38),
                    if (_busy)
                      const Positioned.fill(child: CircularProgressIndicator()),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(state.displayName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Profil lokal · data tidak dikirim ke server', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic)),
                  ])),
                ]),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pickPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Pilih foto dari perangkat'),
                ),
                if (state.profileImageBase64 != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _busy ? null : () => state.removeProfileImage(),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Hapus foto'),
                    ),
                  ),
                const SizedBox(height: 12),
                Text('Nama tampilan', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Nama tampilan')),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _saveProfile, icon: const Icon(Icons.save_outlined), label: const Text('Simpan profil'))),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeading('Jejak penjelajahan', action: 'Lihat riwayat →', onAction: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => HistoryScreen(state: state)))),
          Row(children: [
            Expanded(child: _MetricCard(number: '${state.favoriteIds.length}', label: 'Kata favorit', icon: Icons.bookmark_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(number: '${state.historyIds.length}', label: 'Dibuka', icon: Icons.menu_book_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(number: '${state.suggestions.length}', label: 'Usulan lokal', icon: Icons.lightbulb_outline_rounded)),
          ]),
          const SizedBox(height: 16),
          Card(child: ListTile(
            leading: Icon(Icons.dark_mode_outlined, color: colors.primary),
            title: const Text('Tema gelap'),
            subtitle: const Text('Simpan preferensi tampilan di perangkat ini'),
            trailing: Switch(value: state.isDarkMode, onChanged: state.setDarkMode),
          )),
          const SizedBox(height: 10),
          Text('Foto profil disimpan lokal pada perangkat/browser ini. Foto tidak diunggah ke server dan tidak otomatis tersinkron ke perangkat lain.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, height: 1.5)),
        ],
      ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.number, required this.label, required this.icon});
  final String number;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(children: [
          Icon(icon, color: colors.secondary, size: 20),
          const SizedBox(height: 7),
          Text(number, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
