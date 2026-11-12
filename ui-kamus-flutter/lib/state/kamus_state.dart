import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_item.dart';
import '../models/dictionary_entry.dart';

class KamusState extends ChangeNotifier {
  List<DictionaryEntry> entries = [];
  List<CategoryItem> categories = [];
  Set<String> favoriteIds = {};
  List<String> historyIds = [];
  List<String> recentSearchIds = [];
  List<String> suggestions = [];

  bool isDarkMode = false;
  String displayName = 'Penutur Kutai';
  String? profileImageBase64;

  SharedPreferences? _prefs;

  Future<void> load() async {
    final wordsJson = jsonDecode(
      await rootBundle.loadString('assets/data/kosakata_lengkap.json'),
    ) as List<dynamic>;
    final categoriesJson = jsonDecode(
      await rootBundle.loadString('assets/data/kategori.json'),
    ) as List<dynamic>;

    entries = wordsJson
        .whereType<Map<String, dynamic>>()
        .map(DictionaryEntry.fromJson)
        .toList()
      ..sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
    categories = categoriesJson
        .whereType<Map<String, dynamic>>()
        .map(CategoryItem.fromJson)
        .toList();

    _prefs = await SharedPreferences.getInstance();
    isDarkMode = _prefs?.getBool('dark_mode') ?? false;
    displayName = _prefs?.getString('display_name') ?? 'Penutur Kutai';
    profileImageBase64 = _prefs?.getString('profile_image_base64');
    favoriteIds = (_prefs?.getStringList('favorite_ids') ?? <String>[]).toSet();
    historyIds = _prefs?.getStringList('history_ids') ?? <String>[];
    recentSearchIds = _prefs?.getStringList('recent_search_ids') ?? <String>[];
    suggestions = _prefs?.getStringList('word_suggestions') ?? <String>[];
  }

  DictionaryEntry? entryById(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  CategoryItem? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<DictionaryEntry> get favorites =>
      entries.where((entry) => favoriteIds.contains(entry.id)).toList();

  List<DictionaryEntry> get history => historyIds
      .map(entryById)
      .whereType<DictionaryEntry>()
      .toList();

  List<DictionaryEntry> get recentSearches => recentSearchIds
      .map(entryById)
      .whereType<DictionaryEntry>()
      .toList();

  Future<void> toggleFavorite(String id) async {
    if (!favoriteIds.add(id)) favoriteIds.remove(id);
    await _prefs?.setStringList('favorite_ids', favoriteIds.toList());
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    await _prefs?.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> setDisplayName(String value) async {
    final next = value.trim();
    displayName = next.isEmpty ? 'Penutur Kutai' : next;
    await _prefs?.setString('display_name', displayName);
    notifyListeners();
  }

  Future<void> setProfileImage(Uint8List bytes) async {
    // Resize before persistence so the image remains small enough for local prefs.
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('File gambar tidak valid.');
    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 512 : null,
      height: decoded.height > decoded.width ? 512 : null,
      interpolation: img.Interpolation.average,
    );
    final encoded = img.encodeJpg(resized, quality: 78);
    profileImageBase64 = base64Encode(encoded);
    final saved = await _prefs?.setString('profile_image_base64', profileImageBase64!);
    if (saved == false) {
      throw StateError('Penyimpanan foto penuh. Coba gunakan foto yang lebih kecil.');
    }
    notifyListeners();
  }

  Future<void> removeProfileImage() async {
    profileImageBase64 = null;
    await _prefs?.remove('profile_image_base64');
    notifyListeners();
  }

  Future<void> recordOpen(String id) async {
    historyIds.remove(id);
    historyIds.insert(0, id);
    if (historyIds.length > 100) historyIds = historyIds.take(100).toList();
    await _prefs?.setStringList('history_ids', historyIds);
    notifyListeners();
  }

  Future<void> recordSearch(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final matches = entries.where((entry) => entry.word.toLowerCase() == normalized);
    if (matches.isEmpty) return;
    final id = matches.first.id;
    recentSearchIds.remove(id);
    recentSearchIds.insert(0, id);
    if (recentSearchIds.length > 10) {
      recentSearchIds = recentSearchIds.take(10).toList();
    }
    await _prefs?.setStringList('recent_search_ids', recentSearchIds);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    historyIds.clear();
    await _prefs?.setStringList('history_ids', historyIds);
    notifyListeners();
  }

  Future<void> submitSuggestion({
    required String word,
    required String meaning,
    required String dialect,
  }) async {
    final suggestion = jsonEncode({
      'kata': word.trim(),
      'arti': meaning.trim(),
      'dialek': dialect.trim(),
      'waktu': DateTime.now().toIso8601String(),
    });
    suggestions.insert(0, suggestion);
    await _prefs?.setStringList('word_suggestions', suggestions);
    notifyListeners();
  }
}
