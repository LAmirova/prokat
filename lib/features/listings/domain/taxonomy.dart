// lib/features/listings/domain/taxonomy.dart
class Section {
  final int id;
  final String name;
  const Section({required this.id, required this.name});
  factory Section.fromJson(Map<String, dynamic> m) =>
      Section(id: (m['id'] as num).toInt(), name: m['name']?.toString() ?? '');
  @override
  String toString() => name;
}

class Category {
  final int id;
  final String name;
  final int sectionId;
  const Category(
      {required this.id, required this.name, required this.sectionId});
  factory Category.fromJson(Map<String, dynamic> m) => Category(
        id: (m['id'] as num).toInt(),
        name: m['name']?.toString() ?? '',
        sectionId: (m['section_id'] as num).toInt(),
      );
  @override
  String toString() => name;
}

class Subcategory {
  final int id;
  final String name;
  final int categoryId;
  const Subcategory(
      {required this.id, required this.name, required this.categoryId});
  factory Subcategory.fromJson(Map<String, dynamic> m) => Subcategory(
        id: (m['id'] as num).toInt(),
        name: m['name']?.toString() ?? '',
        categoryId: (m['category_id'] as num).toInt(),
      );
  @override
  String toString() => name;
}
