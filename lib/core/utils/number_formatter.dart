String formatNumber(double value, int precision) {
  if (!value.isFinite) {
    return '—';
  }
  final absolute = value.abs();
  if (absolute != 0 && (absolute >= 1e12 || absolute < 1e-6)) {
    return value.toStringAsExponential(precision.clamp(1, 10));
  }
  var text = value.toStringAsFixed(precision);
  if (text.contains('.')) {
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  return text == '-0' ? '0' : text;
}
