// lib/features/listings/domain/listing.dart
enum ItemCondition { used, new_ }

extension ItemConditionX on ItemCondition {
  String toApi() => this == ItemCondition.new_ ? 'new' : 'used';

  static ItemCondition fromApi(String? s) {
    return (s == 'new') ? ItemCondition.new_ : ItemCondition.used;
  }
}

class Photo {
  final int id;
  final String path;
  final bool isMain;
  const Photo({required this.id, required this.path, required this.isMain});
}

class Listing {
  final int id;
  final String title;
  final String address;
  final double? priceHour;
  final double? priceDay;
  final double? priceMonth;
  final ItemCondition condition;
  final bool deposit;
  final List<String> tags;
  final int viewsCount;
  final List<Photo> photos;

  const Listing({
    required this.id,
    required this.title,
    required this.address,
    required this.condition,
    required this.deposit,
    required this.viewsCount,
    this.priceHour,
    this.priceDay,
    this.priceMonth,
    this.tags = const [],
    this.photos = const [],
  });
}
