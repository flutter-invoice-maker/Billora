import 'package:equatable/equatable.dart';
import 'chart_data_point.dart';
import 'tag_revenue.dart';

class DashboardStats extends Equatable {
  final int totalInvoices;
  final double totalRevenue;
  final double averageValue;
  final int newCustomers;
  final List<TagRevenue> topTags;
  final List<ChartDataPoint> revenueChartData;
  final List<ChartDataPoint> invoiceChartData;
  final Map<String, int> statusDistribution;
  final double paidPercentage;
  final double overduePercentage;
  final int overdueInvoices;
  final double totalPaidAmount;
  final double totalPendingAmount;

  const DashboardStats({
    required this.totalInvoices,
    required this.totalRevenue,
    required this.averageValue,
    required this.newCustomers,
    required this.topTags,
    required this.revenueChartData,
    required this.invoiceChartData,
    required this.statusDistribution,
    required this.paidPercentage,
    required this.overduePercentage,
    required this.overdueInvoices,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
  });

  @override
  List<Object?> get props => [
    totalInvoices,
    totalRevenue,
    averageValue,
    newCustomers,
    topTags,
    revenueChartData,
    invoiceChartData,
    statusDistribution,
    paidPercentage,
    overduePercentage,
    overdueInvoices,
    totalPaidAmount,
    totalPendingAmount,
  ];

  DashboardStats copyWith({
    int? totalInvoices,
    double? totalRevenue,
    double? averageValue,
    int? newCustomers,
    List<TagRevenue>? topTags,
    List<ChartDataPoint>? revenueChartData,
    List<ChartDataPoint>? invoiceChartData,
    Map<String, int>? statusDistribution,
    double? paidPercentage,
    double? overduePercentage,
    int? overdueInvoices,
    double? totalPaidAmount,
    double? totalPendingAmount,
  }) {
    return DashboardStats(
      totalInvoices: totalInvoices ?? this.totalInvoices,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageValue: averageValue ?? this.averageValue,
      newCustomers: newCustomers ?? this.newCustomers,
      topTags: topTags ?? this.topTags,
      revenueChartData: revenueChartData ?? this.revenueChartData,
      invoiceChartData: invoiceChartData ?? this.invoiceChartData,
      statusDistribution: statusDistribution ?? this.statusDistribution,
      paidPercentage: paidPercentage ?? this.paidPercentage,
      overduePercentage: overduePercentage ?? this.overduePercentage,
      overdueInvoices: overdueInvoices ?? this.overdueInvoices,
      totalPaidAmount: totalPaidAmount ?? this.totalPaidAmount,
      totalPendingAmount: totalPendingAmount ?? this.totalPendingAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInvoices': totalInvoices,
      'totalRevenue': totalRevenue,
      'averageValue': averageValue,
      'newCustomers': newCustomers,
      'topTags': topTags.map((tag) => tag.toJson()).toList(),
      'revenueChartData': revenueChartData.map((point) => point.toJson()).toList(),
      'invoiceChartData': invoiceChartData.map((point) => point.toJson()).toList(),
      'statusDistribution': statusDistribution,
      'paidPercentage': paidPercentage,
      'overduePercentage': overduePercentage,
      'overdueInvoices': overdueInvoices,
      'totalPaidAmount': totalPaidAmount,
      'totalPendingAmount': totalPendingAmount,
    };
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalInvoices: json['totalInvoices'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageValue: (json['averageValue'] as num).toDouble(),
      newCustomers: json['newCustomers'] as int,
      topTags: (json['topTags'] as List)
          .map((tag) => TagRevenue.fromJson(tag))
          .toList(),
      revenueChartData: (json['revenueChartData'] as List)
          .map((point) => ChartDataPoint.fromJson(point))
          .toList(),
      invoiceChartData: (json['invoiceChartData'] as List)
          .map((point) => ChartDataPoint.fromJson(point))
          .toList(),
      statusDistribution: Map<String, int>.from(json['statusDistribution']),
      paidPercentage: (json['paidPercentage'] as num).toDouble(),
      overduePercentage: (json['overduePercentage'] as num).toDouble(),
      overdueInvoices: json['overdueInvoices'] as int,
      totalPaidAmount: (json['totalPaidAmount'] as num).toDouble(),
      totalPendingAmount: (json['totalPendingAmount'] as num).toDouble(),
    );
  }

  // Empty stats for loading state
  factory DashboardStats.empty() {
    return const DashboardStats(
      totalInvoices: 0,
      totalRevenue: 0.0,
      averageValue: 0.0,
      newCustomers: 0,
      topTags: [],
      revenueChartData: [],
      invoiceChartData: [],
      statusDistribution: {},
      paidPercentage: 0.0,
      overduePercentage: 0.0,
      overdueInvoices: 0,
      totalPaidAmount: 0.0,
      totalPendingAmount: 0.0,
    );
  }
} 