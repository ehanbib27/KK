import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kamus_aplikasi/models/dictionary_entry.dart';

void main() {
  test('kosakata JSON bisa dibaca sebagai entri kamus', () {
    final jsonFile = File('assets/data/kosakata_lengkap.json');
    final decoded = jsonDecode(jsonFile.readAsStringSync()) as List<dynamic>;
    final entries = decoded
        .whereType<Map<String, dynamic>>()
        .map(DictionaryEntry.fromJson)
        .toList();

    expect(entries, isNotEmpty);
    expect(entries.any((entry) => entry.id == 'etam'), isTrue);
    expect(entries.first.word, isNotEmpty);
  });

  test('pencarian menelusuri lema dan makna', () {
    const entry = DictionaryEntry(
      id: 'etam',
      word: 'Etam',
      pronunciation: 'e·tam',
      partOfSpeech: 'pronomina',
      categoryId: 'ungkapan',
      dialect: 'Kutai',
      meaning: 'Kita atau kami semua.',
      example: 'Etam begoyong.',
      translation: 'Kita bekerja bersama.',
    );

    expect(entry.matches('etam'), isTrue);
    expect(entry.matches('kami semua'), isTrue);
    expect(entry.matches('tidak ada kata ini'), isFalse);
  });
}
