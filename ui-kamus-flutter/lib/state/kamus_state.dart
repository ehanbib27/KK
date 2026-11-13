import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_item.dart';
import '../models/dictionary_entry.dart';

class _ParsedDictionaryData {
  const _ParsedDictionaryData({
    required this.entries,
    required this.categories,
    required this.entriesById,
    required this.categoriesById,
    required this.categoryCounts,
    required this.availableLetters,
    required this.searchHaystacks,
    required this.firstLetters,
  });

  final List<DictionaryEntry> entries;
  final List<CategoryItem> categories;
  final Map<String, DictionaryEntry> entriesById;
  final Map<String, CategoryItem> categoriesById;
  final Map<String, int> categoryCounts;
  final List<String> availableLetters;
  final List<String> searchHaystacks;
  final List<String> firstLetters;
}

_ParsedDictionaryData _parseDictionaryData((String, String) raw) {
  final wordsJson = jsonDecode(raw.$1) as List<dynamic>;
  final categoriesJson = jsonDecode(raw.$2) as List<dynamic>;

  final entries = wordsJson
      .whereType<Map<String, dynamic>>()
      .map(DictionaryEntry.fromJson)
      .toList()
    ..sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
  final categories = categoriesJson
      .whereType<Map<String, dynamic>>()
      .map(CategoryItem.fromJson)
      .toList();

  final entriesById = <String, DictionaryEntry>{};
  final categoryCounts = <String, int>{};
  final letterSet = <String>{};
  final searchHaystacks = List<String>.filled(entries.length, '');
  final firstLetters = List<String>.filled(entries.length, '');

  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    entriesById[entry.id] = entry;
    categoryCounts[entry.categoryId] = (categoryCounts[entry.categoryId] ?? 0) + 1;
    final letter = entry.word.isEmpty ? '' : entry.word[0].toUpperCase();
    if (letter.isNotEmpty) letterSet.add(letter);
    firstLetters[i] = letter;
    searchHaystacks[i] =
        '${entry.word}\n${entry.meaning}\n${entry.example}\n${entry.translation}\n${entry.dialect}\n${entry.partOfSpeech}'
            .toLowerCase();
  }

  final categoriesById = <String, CategoryItem>{
    for (final category in categories) category.id: category,
  };
  final availableLetters = letterSet.toList()..sort();

  return _ParsedDictionaryData(
    entries: entries,
    categories: categories,
    entriesById: entriesById,
    categoriesById: categoriesById,
    categoryCounts: categoryCounts,
    availableLetters: availableLetters,
    searchHaystacks: searchHaystacks,
    firstLetters: firstLetters,
  );
}

class KamusState extends ChangeNotifier {
  List<DictionaryEntry> entries = [];
  List<CategoryItem> categories = [];
  List<String> availableLetters = const [];
  Set<String> favoriteIds = {};
  List<String> historyIds = [];
  List<String> recentSearchIds = [];
  List<String> suggestions = [];

  final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
  bool get isDarkMode => darkModeNotifier.value;
  String displayName = 'Penutur Kutai';
  String? profileImageBase64;

  Map<String, DictionaryEntry> _entriesById = const {};
  Map<String, CategoryItem> _categoriesById = const {};
  Map<String, int> _categoryCounts = const {};
  List<String> _searchHaystacks = const [];
  List<String> _firstLetters = const [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    final rawWords = await rootBundle.loadString('assets/data/kosakata_lengkap.json');
    final rawCategories = await rootBundle.loadString('assets/data/kategori.json');
    final parsed = await compute(_parseDictionaryData, (rawWords, rawCategories));

    entries = parsed.entries;
    categories = parsed.categories;
    availableLetters = parsed.availableLetters;
    _entriesById = parsed.entriesById;
    _categoriesById = parsed.categoriesById;
    _categoryCounts = parsed.categoryCounts;
    _searchHaystacks = parsed.searchHaystacks;
    _firstLetters = parsed.firstLetters;

    _prefs = await SharedPreferences.getInstance();
    darkModeNotifier.value = _prefs?.getBool('dark_mode') ?? false;
    displayName = _prefs?.getString('display_name') ?? 'Penutur Kutai';
    profileImageBase64 = _prefs?.getString('profile_image_base64');
    favoriteIds = (_prefs?.getStringList('favorite_ids') ?? <String>[]).toSet();
    historyIds = _prefs?.getStringList('history_ids') ?? <String>[];
    recentSearchIds = _prefs?.getStringList('recent_search_ids') ?? <String>[];
    suggestions = _prefs?.getStringList('word_suggestions') ?? <String>[];
  }

  DictionaryEntry? entryById(String id) => _entriesById[id];

  CategoryItem? categoryById(String id) => _categoriesById[id];

  int countForCategory(String categoryId) => _categoryCounts[categoryId] ?? 0;

  List<DictionaryEntry> filterEntries({
    String query = '',
    String? categoryId,
    String? letter,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final hasQuery = normalizedQuery.isNotEmpty;
    final hasCategory = categoryId != null && categoryId.isNotEmpty;
    final hasLetter = letter != null && letter.isNotEmpty;

    if (!hasQuery && !hasCategory && !hasLetter) {
      return entries;
    }

    final result = <DictionaryEntry>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (hasCategory && entry.categoryId != categoryId) continue;
      if (hasLetter && _firstLetters[i] != letter) continue;
      if (hasQuery && !_searchHaystacks[i].contains(normalizedQuery)) continue;
      result.add(entry);
    }
    return result;
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
    darkModeNotifier.value = value;
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
