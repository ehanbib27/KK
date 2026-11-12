import 'package:flutter/material.dart';

import '../state/kamus_state.dart';
import '../widgets/common.dart';
import 'about_screen.dart';
import 'category_screen.dart';
import 'dictionary_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.state});
  final KamusState state;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  String _searchSeed = '';
  String? _categorySeed;

  void _search(String value) {
    widget.state.recordSearch(value);
    setState(() {
      _categorySeed = null;
      _searchSeed = value;
      _selectedIndex = 1;
    });
  }

  void _openCategory(String id) {
    setState(() {
      _categorySeed = id;
      _searchSeed = '';
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final screens = <Widget>[
      HomeScreen(state: state, onSearch: _search, onOpenDictionary: () => setState(() => _selectedIndex = 1), onOpenCategories: () => setState(() => _selectedIndex = 2), onOpenCategory: _openCategory),
      DictionaryScreen(state: state, initialQuery: _searchSeed, initialCategory: _categorySeed),
      CategoryScreen(state: state, onOpenCategory: _openCategory),
      FavoritesScreen(state: state),
      AboutScreen(state: state),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Kamus Kutai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Kata Punya Cerita', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: state.isDarkMode ? 'Tema terang' : 'Tema gelap',
            onPressed: () => state.setDarkMode(!state.isDarkMode),
            icon: Icon(state.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Profil',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProfileScreen(state: state))),
              icon: ProfileAvatar(state: state, radius: 18),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Kamus'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Kategori'),
          NavigationDestination(icon: Icon(Icons.bookmark_border_rounded), selectedIcon: Icon(Icons.bookmark_rounded), label: 'Favorit'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories_rounded), label: 'Tentang'),
        ],
      ),
    );
  }
}
