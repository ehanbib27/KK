class DictionaryEntry {
  const DictionaryEntry({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.categoryId,
    required this.dialect,
    required this.meaning,
    required this.example,
    required this.translation,
    this.note = '',
  });

  final String id;
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String categoryId;
  final String dialect;
  final String meaning;
  final String example;
  final String translation;
  final String note;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      id: json['id'] as String? ?? '',
      word: json['kata'] as String? ?? '',
      pronunciation: json['pelafalan'] as String? ?? '',
      partOfSpeech: json['kelasKata'] as String? ?? '',
      categoryId: json['kategori'] as String? ?? '',
      dialect: json['dialek'] as String? ?? 'Kutai',
      meaning: json['arti'] as String? ?? '',
      example: json['contoh'] as String? ?? '',
      translation: json['terjemahan'] as String? ?? '',
      note: json['catatan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kata': word,
        'pelafalan': pronunciation,
        'kelasKata': partOfSpeech,
        'kategori': categoryId,
        'dialek': dialect,
        'arti': meaning,
        'contoh': example,
        'terjemahan': translation,
        'catatan': note,
      };

  bool matches(String query) {
    return matchesNormalized(query.trim().toLowerCase());
  }

  bool matchesNormalized(String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;
    return word.toLowerCase().contains(normalizedQuery) ||
        meaning.toLowerCase().contains(normalizedQuery) ||
        example.toLowerCase().contains(normalizedQuery) ||
        translation.toLowerCase().contains(normalizedQuery) ||
        dialect.toLowerCase().contains(normalizedQuery) ||
        partOfSpeech.toLowerCase().contains(normalizedQuery);
  }
}
