/// Tolerant readers for Firestore data. The admin app stores several
/// numeric fields as strings ("12.50"), so models accept both.
double asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

int asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    return int.tryParse(trimmed) ??
        double.tryParse(trimmed)?.toInt() ??
        fallback;
  }
  return fallback;
}

String asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value is String ? value : value.toString();
}

bool asBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

List<String> asStringList(Object? value) {
  if (value is Iterable) {
    return value.whereType<Object>().map((e) => e.toString()).toList();
  }
  return const [];
}

/// Firestore `Timestamp` (or anything with `toDate()`), `DateTime`,
/// ISO string or epoch millis.
DateTime? asDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return null;
  }
}
