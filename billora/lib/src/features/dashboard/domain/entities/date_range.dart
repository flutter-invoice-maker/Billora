import 'package:equatable/equatable.dart';

enum DateRangeType {
  day,
  week,
  month,
  quarter,
  year,
  custom,
}

class DateRange extends Equatable {
  final DateRangeType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? label;

  const DateRange({
    required this.type,
    required this.startDate,
    required this.endDate,
    this.label,
  });

  @override
  List<Object?> get props => [type, startDate, endDate, label];

  // Predefined date ranges
  static DateRange get today {
    final now = DateTime.now();
    return DateRange(
      type: DateRangeType.day,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      label: 'Today',
    );
  }

  static DateRange get yesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateRange(
      type: DateRangeType.day,
      startDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
      endDate: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
      label: 'Yesterday',
    );
  }

  static DateRange get last7Days {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    return DateRange(
      type: DateRangeType.week,
      startDate: DateTime(start.year, start.month, start.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      label: 'Last 7 Days',
    );
  }

  static DateRange get last30Days {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 29));
    return DateRange(
      type: DateRangeType.month,
      startDate: DateTime(start.year, start.month, start.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      label: 'Last 30 Days',
    );
  }

  static DateRange get thisMonth {
    final now = DateTime.now();
    return DateRange(
      type: DateRangeType.month,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      label: 'This Month',
    );
  }

  static DateRange get lastMonth {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    return DateRange(
      type: DateRangeType.month,
      startDate: lastMonth,
      endDate: DateTime(now.year, now.month, 0, 23, 59, 59),
      label: 'Last Month',
    );
  }

  static DateRange get thisQuarter {
    final now = DateTime.now();
    final quarter = ((now.month - 1) / 3).floor();
    final startMonth = quarter * 3 + 1;
    final endMonth = startMonth + 2;
    
    return DateRange(
      type: DateRangeType.quarter,
      startDate: DateTime(now.year, startMonth, 1),
      endDate: DateTime(now.year, endMonth + 1, 0, 23, 59, 59),
      label: 'This Quarter',
    );
  }

  static DateRange get thisYear {
    final now = DateTime.now();
    return DateRange(
      type: DateRangeType.year,
      startDate: DateTime(now.year, 1, 1),
      endDate: DateTime(now.year, 12, 31, 23, 59, 59),
      label: 'This Year',
    );
  }

  static List<DateRange> get predefinedRanges => [
    today,
    yesterday,
    last7Days,
    last30Days,
    thisMonth,
    lastMonth,
    thisQuarter,
    thisYear,
  ];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'label': label,
    };
  }

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      type: DateRangeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DateRangeType.custom,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate']),
      label: json['label'],
    );
  }
} 