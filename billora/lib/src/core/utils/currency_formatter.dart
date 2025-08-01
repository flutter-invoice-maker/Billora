class CurrencyFormatter {
  static String format(double amount) {
    return formatVND(amount, null);
  }
  
  static String formatVND(double amount, dynamic loc) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B ₫';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else {
      return '${amount.toStringAsFixed(0)} ₫';
    }
  }

  static String formatVNDCompact(double amount, dynamic loc) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B ₫';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ₫';
    } else {
      return '${amount.toStringAsFixed(0)} ₫';
    }
  }

  static String formatVNDWithCommas(double amount, dynamic loc) {
    final parts = amount.toStringAsFixed(0).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    final formattedInteger = _addCommas(integerPart);
    final result = decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
    
    return '$result ₫';
  }

  static String _addCommas(String number) {
    final buffer = StringBuffer();
    for (int i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(number[i]);
    }
    return buffer.toString();
  }
} 