class ConversionHistory {
  const ConversionHistory({
    required this.id,
    required this.categoryId,
    required this.input,
    required this.result,
    required this.fromUnitId,
    required this.toUnitId,
    required this.createdAt,
  });

  final String id;
  final double input;
  final double result;
  final String categoryId;
  final String fromUnitId;
  final String toUnitId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'input': input,
    'result': result,
    'categoryId': categoryId,
    'fromUnitId': fromUnitId,
    'toUnitId': toUnitId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ConversionHistory.fromJson(Map<String, dynamic> json) =>
      ConversionHistory(
        id: json['id'] as String,
        input: (json['input'] as num).toDouble(),
        result: (json['result'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        fromUnitId: json['fromUnitId'] as String,
        toUnitId: json['toUnitId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
