DateTime? dateTimeFromValue(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  try {
    final dynamic dynamicValue = value;
    final dynamic date = dynamicValue?.toDate();
    if (date is DateTime) {
      return date;
    }
  } on Object {
    return null;
  }
  return null;
}
