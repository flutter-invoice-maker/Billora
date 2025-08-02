class ChartDataPoint {
  final DateTime date;
  final double value;
  final String label;

  const ChartDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });

  ChartDataPoint copyWith({
    DateTime? date,
    double? value,
    String? label,
  }) {
    return ChartDataPoint(
      date: date ?? this.date,
      value: value ?? this.value,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
    };
  }

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    // Handle both String and DateTime for date field
    DateTime date;
    final dateValue = json['date'];
    if (dateValue is DateTime) {
      date = dateValue;
    } else if (dateValue is String) {
      date = DateTime.parse(dateValue);
    } else {
      throw FormatException('Invalid date format: $dateValue');
    }
    
    return ChartDataPoint(
      date: date,
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartDataPoint &&
        other.date == date &&
        other.value == value &&
        other.label == label;
  }

  @override
  int get hashCode => date.hashCode ^ value.hashCode ^ label.hashCode;

  @override
  String toString() {
    return 'ChartDataPoint(date: $date, value: $value, label: $label)';
  }
} 