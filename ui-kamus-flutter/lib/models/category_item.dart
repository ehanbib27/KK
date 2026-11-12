class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
  });

  final String id;
  final String name;
  final String description;
  final String iconName;

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
        id: json['id'] as String? ?? '',
        name: json['nama'] as String? ?? '',
        description: json['deskripsi'] as String? ?? '',
        iconName: json['ikon'] as String? ?? 'menu_book',
      );
}
