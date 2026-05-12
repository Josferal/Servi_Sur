class CurrencyFormatter {
  static String usd(num value) =>
      '\$${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';
}
