class FavoriteConversion {
  const FavoriteConversion({
    required this.categoryId,
    required this.fromUnitId,
    required this.toUnitId,
  });

  final String categoryId;
  final String fromUnitId;
  final String toUnitId;

  String get id => '$categoryId|$fromUnitId|$toUnitId';

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'fromUnitId': fromUnitId,
    'toUnitId': toUnitId,
  };

  factory FavoriteConversion.fromJson(Map<String, dynamic> json) =>
      FavoriteConversion(
        categoryId: json['categoryId'] as String,
        fromUnitId: json['fromUnitId'] as String,
        toUnitId: json['toUnitId'] as String,
      );
}
