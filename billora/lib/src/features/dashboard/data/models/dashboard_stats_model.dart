import 'package:billora/src/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:billora/src/features/dashboard/domain/entities/chart_data_point.dart';
import 'package:billora/src/features/dashboard/domain/entities/tag_revenue.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalInvoices,
    required super.totalRevenue,
    required super.averageValue,
    required super.newCustomers,
    required super.topTags,
    required super.revenueChartData,
    required super.invoiceChartData,
    required super.statusDistribution,
    required super.paidPercentage,
    required super.overduePercentage,
    required super.overdueInvoices,
    required super.totalPaidAmount,
    required super.totalPendingAmount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalInvoices: json['totalInvoices'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageValue: (json['averageValue'] as num?)?.toDouble() ?? 0.0,
      newCustomers: json['newCustomers'] as int? ?? 0,
      topTags: (json['topTags'] as List<dynamic>?)
          ?.map((tag) => TagRevenue.fromJson(tag))
          .toList() ?? [],
      revenueChartData: (json['revenueChartData'] as List<dynamic>?)
          ?.map((point) => ChartDataPoint.fromJson(point))
          .toList() ?? [],
      invoiceChartData: (json['invoiceChartData'] as List<dynamic>?)
          ?.map((point) => ChartDataPoint.fromJson(point))
          .toList() ?? [],
      statusDistribution: Map<String, int>.from(json['statusDistribution'] ?? {}),
      paidPercentage: (json['paidPercentage'] as num?)?.toDouble() ?? 0.0,
      overduePercentage: (json['overduePercentage'] as num?)?.toDouble() ?? 0.0,
      overdueInvoices: json['overdueInvoices'] as int? ?? 0,
      totalPaidAmount: (json['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      totalPendingAmount: (json['totalPendingAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory DashboardStatsModel.fromFirestore(Map<String, dynamic> data) {
    return DashboardStatsModel(
      totalInvoices: data['totalInvoices'] as int? ?? 0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageValue: (data['averageValue'] as num?)?.toDouble() ?? 0.0,
      newCustomers: data['newCustomers'] as int? ?? 0,
      topTags: (data['topTags'] as List<dynamic>?)
          ?.map((tag) => TagRevenue.fromJson(tag))
          .toList() ?? [],
      revenueChartData: (data['revenueChartData'] as List<dynamic>?)
          ?.map((point) => ChartDataPoint.fromJson(point))
          .toList() ?? [],
      invoiceChartData: (data['invoiceChartData'] as List<dynamic>?)
          ?.map((point) => ChartDataPoint.fromJson(point))
          .toList() ?? [],
      statusDistribution: Map<String, int>.from(data['statusDistribution'] ?? {}),
      paidPercentage: (data['paidPercentage'] as num?)?.toDouble() ?? 0.0,
      overduePercentage: (data['overduePercentage'] as num?)?.toDouble() ?? 0.0,
      overdueInvoices: data['overdueInvoices'] as int? ?? 0,
      totalPaidAmount: (data['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      totalPendingAmount: (data['totalPendingAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
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

  DashboardStats toEntity() {
    return DashboardStats(
      totalInvoices: totalInvoices,
      totalRevenue: totalRevenue,
      averageValue: averageValue,
      newCustomers: newCustomers,
      topTags: topTags,
      revenueChartData: revenueChartData,
      invoiceChartData: invoiceChartData,
      statusDistribution: statusDistribution,
      paidPercentage: paidPercentage,
      overduePercentage: overduePercentage,
      overdueInvoices: overdueInvoices,
      totalPaidAmount: totalPaidAmount,
      totalPendingAmount: totalPendingAmount,
    );
  }
} 