import 'package:equatable/equatable.dart';
import 'date_range.dart';

class ReportParams extends Equatable {
  final DateRange dateRange;
  final List<String> tagFilters;
  final String? customerFilter;
  final String? statusFilter;
  final bool includeDetails;
  final String currency;
  final String locale;

  const ReportParams({
    required this.dateRange,
    this.tagFilters = const [],
    this.customerFilter,
    this.statusFilter,
    this.includeDetails = true,
    this.currency = 'USD',
    this.locale = 'en_US',
  });

  @override
  List<Object?> get props => [
    dateRange,
    tagFilters,
    customerFilter,
    statusFilter,
    includeDetails,
    currency,
    locale,
  ];

  ReportParams copyWith({
    DateRange? dateRange,
    List<String>? tagFilters,
    String? customerFilter,
    String? statusFilter,
    bool? includeDetails,
    String? currency,
    String? locale,
  }) {
    return ReportParams(
      dateRange: dateRange ?? this.dateRange,
      tagFilters: tagFilters ?? this.tagFilters,
      customerFilter: customerFilter ?? this.customerFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      includeDetails: includeDetails ?? this.includeDetails,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateRange': dateRange.toJson(),
      'tagFilters': tagFilters,
      'customerFilter': customerFilter,
      'statusFilter': statusFilter,
      'includeDetails': includeDetails,
      'currency': currency,
      'locale': locale,
    };
  }

  factory ReportParams.fromJson(Map<String, dynamic> json) {
    return ReportParams(
      dateRange: DateRange.fromJson(json['dateRange']),
      tagFilters: List<String>.from(json['tagFilters'] ?? []),
      customerFilter: json['customerFilter'],
      statusFilter: json['statusFilter'],
      includeDetails: json['includeDetails'] ?? true,
      currency: json['currency'] ?? 'USD',
      locale: json['locale'] ?? 'en_US',
    );
  }
} 