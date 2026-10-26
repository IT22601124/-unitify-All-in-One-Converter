enum MeasurementSystem { metric, imperial, usCustomary, binary, universal }

class ConversionUnit {
  const ConversionUnit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.toBaseFactor,
    this.system = MeasurementSystem.universal,
  });

  final String id;
  final String name;
  final String symbol;
  final double toBaseFactor;
  final MeasurementSystem system;
}
