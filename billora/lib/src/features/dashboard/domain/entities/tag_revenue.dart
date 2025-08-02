import 'package:equatable/equatable.dart';

class TagRevenue extends Equatable {
  final String tagName;
  final String tagColor;
  final double revenue;
  final int invoiceCount;
  final double percentage;

  const TagRevenue({
    required this.tagName,
    required this.tagColor,
    required this.revenue,
    required this.invoiceCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [tagName, tagColor, revenue, invoiceCount, percentage];

  TagRevenue copyWith({
    String? tagName,
    String? tagColor,
    double? revenue,
    int? invoiceCount,
    double? percentage,
  }) {
    return TagRevenue(
      tagName: tagName ?? this.tagName,
      tagColor: tagColor ?? this.tagColor,
      revenue: revenue ?? this.revenue,
      invoiceCount: invoiceCount ?? this.invoiceCount,
      percentage: percentage ?? this.percentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagName': tagName,
      'tagColor': tagColor,
      'revenue': revenue,
      'invoiceCount': invoiceCount,
      'percentage': percentage,
    };
  }

  factory TagRevenue.fromJson(Map<String, dynamic> json) {
    return TagRevenue(
      tagName: json['tagName'] as String,
      tagColor: json['tagColor'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      invoiceCount: json['invoiceCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
} 