import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/core/constants/app_constants.dart';
import 'package:billora/src/features/dashboard/domain/entities/date_range.dart';
import 'package:billora/src/features/dashboard/domain/entities/report_params.dart';

abstract class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> getInvoiceStats(DateRange dateRange, List<String> tagFilters);
  Future<Uint8List> exportExcelReport(ReportParams params);
  Future<List<Map<String, dynamic>>> getRevenueChartData(DateRange dateRange, List<String> tagFilters);
  Future<List<Map<String, dynamic>>> getInvoiceChartData(DateRange dateRange, List<String> tagFilters);
  Future<List<Map<String, dynamic>>> getTopTags(DateRange dateRange, int limit);
  Future<Map<String, int>> getStatusDistribution(DateRange dateRange, List<String> tagFilters);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRemoteDataSourceImpl(this._firestore, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<Map<String, dynamic>> getInvoiceStats(DateRange dateRange, List<String> tagFilters) async {
    try {
      // Check if user is authenticated
      if (_userId.isEmpty) {
        developer.log('Dashboard: User not authenticated, returning empty stats', name: 'DashboardDataSource');
        return _getEmptyStats();
      }
      
      developer.log('Dashboard: Fetching stats for user: $_userId', name: 'DashboardDataSource');
      
      final query = _buildInvoicesQuery(dateRange, tagFilters);
      final invoicesSnapshot = await query.get();
      
      developer.log('Dashboard: Found ${invoicesSnapshot.docs.length} invoices in Firestore', name: 'DashboardDataSource');

      // Filter results in memory
      final filteredInvoices = invoicesSnapshot.docs.where((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];
        
        // Check date range - handle both String and Timestamp
        DateTime? invoiceDate;
        if (createdAt is Timestamp) {
          invoiceDate = createdAt.toDate();
        } else if (createdAt is String) {
          try {
            invoiceDate = DateTime.parse(createdAt);
          } catch (e) {
            return false; // Skip invalid date strings
          }
        } else {
          return false; // Skip documents without valid date
        }
        
        if (invoiceDate.isBefore(dateRange.startDate) || invoiceDate.isAfter(dateRange.endDate)) {
          return false;
        }
        
        // Check tag filters
        if (tagFilters.isNotEmpty) {
          final hasMatchingTag = tagFilters.any((tag) => tags.contains(tag));
          if (!hasMatchingTag) return false;
        }
        
        return true;
      }).map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        final total = data['total'] as num?;
        
        // Parse date - handle both String and Timestamp
        DateTime? date;
        if (createdAt is Timestamp) {
          date = createdAt.toDate();
        } else if (createdAt is String) {
          try {
            date = DateTime.parse(createdAt);
          } catch (e) {
            return null; // Skip invalid date strings
          }
        }
        
        if (date == null || total == null) return null;
        
        return {
          'date': date,
          'total': total.toDouble(),
        };
      }).where((invoice) => invoice != null).toList();

      // Calculate statistics
      final validInvoices = filteredInvoices.where((invoice) => invoice != null).cast<Map<String, dynamic>>().toList();
      final totalInvoices = validInvoices.length;
      final totalRevenue = validInvoices.fold<double>(0.0, (total, invoice) => total + (invoice['total'] as double));
      final averageValue = totalInvoices > 0 ? totalRevenue / totalInvoices : 0.0;
      
      developer.log('Dashboard: Calculated stats - Invoices: $totalInvoices, Revenue: $totalRevenue, Average: $averageValue', name: 'DashboardDataSource');

      // Get chart data
      final revenueChartData = await getRevenueChartData(dateRange, tagFilters);
      final invoiceChartData = await getInvoiceChartData(dateRange, tagFilters);
      final topTags = await getTopTags(dateRange, AppConstants.maxTopTags);
      final statusDistribution = await getStatusDistribution(dateRange, tagFilters);

      // Calculate additional metrics
      final paidCount = statusDistribution['paid'] ?? 0;
      final overdueCount = statusDistribution['overdue'] ?? 0;
      final paidPercentage = totalInvoices > 0 ? (paidCount / totalInvoices) * 100 : 0.0;
      final overduePercentage = totalInvoices > 0 ? (overdueCount / totalInvoices) * 100 : 0.0;

      return {
        'totalInvoices': totalInvoices,
        'totalRevenue': totalRevenue,
        'averageValue': averageValue,
        'newCustomers': 0, // Would need to calculate from customer data
        'topTags': topTags,
        'revenueChartData': revenueChartData,
        'invoiceChartData': invoiceChartData,
        'statusDistribution': statusDistribution,
        'paidPercentage': paidPercentage,
        'overduePercentage': overduePercentage,
        'overdueInvoices': overdueCount,
        'totalPaidAmount': totalRevenue * (paidPercentage / 100),
        'totalPendingAmount': totalRevenue * ((100 - paidPercentage) / 100),
      };
    } catch (e) {
      // Return empty stats instead of rethrowing to prevent UI crashes
      return _getEmptyStats();
    }
  }

  @override
  Future<Uint8List> exportExcelReport(ReportParams params) async {
    try {
      // This would need to fetch actual data from Firestore
      // For now, return empty data
      return Uint8List(0);
    } catch (e) {
      throw Exception('Failed to export Excel report: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueChartData(DateRange dateRange, List<String> tagFilters) async {
    try {
      // Check if user is authenticated
      if (_userId.isEmpty) {
        return [];
      }
      
      final query = _buildInvoicesQuery(dateRange, tagFilters);
      final invoicesSnapshot = await query.get();

      final invoices = invoicesSnapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        final total = data['total'] as num?;
        
        // Parse date - handle both String and Timestamp
        DateTime? date;
        if (createdAt is Timestamp) {
          date = createdAt.toDate();
        } else if (createdAt is String) {
          try {
            date = DateTime.parse(createdAt);
          } catch (e) {
            return null; // Skip invalid date strings
          }
        }
        
        if (date == null || total == null) return null;
        
        return {
          'date': date,
          'total': total.toDouble(),
        };
      }).where((invoice) => invoice != null).toList();

      // Group by date and sum revenue
      final dailyRevenue = <DateTime, double>{};
      final validInvoices = invoices.where((invoice) => invoice != null).cast<Map<String, dynamic>>().toList();
      for (final invoice in validInvoices) {
        final date = invoice['date'] as DateTime;
        final total = invoice['total'] as double;
        final dayStart = DateTime(date.year, date.month, date.day);
        dailyRevenue[dayStart] = (dailyRevenue[dayStart] ?? 0.0) + total;
      }

      // Convert to chart data points
      final chartData = dailyRevenue.entries.map((entry) {
        try {
          return {
            'date': entry.key,
            'value': entry.value,
            'label': '${entry.key.day}/${entry.key.month}',
          };
        } catch (e) {
          return null;
        }
      }).where((item) => item != null).cast<Map<String, dynamic>>().toList();

      // Sort by date
      chartData.sort((a, b) {
        try {
          return (a['date'] as DateTime).compareTo(b['date'] as DateTime);
        } catch (e) {
          return 0;
        }
      });
      
      return chartData;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvoiceChartData(DateRange dateRange, List<String> tagFilters) async {
    try {
      // Check if user is authenticated
      if (_userId.isEmpty) {
        return [];
      }
      
      final query = _buildInvoicesQuery(dateRange, tagFilters);
      final invoicesSnapshot = await query.get();

      final invoices = invoicesSnapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        
        // Parse date - handle both String and Timestamp
        DateTime? date;
        if (createdAt is Timestamp) {
          date = createdAt.toDate();
        } else if (createdAt is String) {
          try {
            date = DateTime.parse(createdAt);
          } catch (e) {
            return null; // Skip invalid date strings
          }
        }
        
        if (date == null) return null;
        
        return {
          'date': date,
          'count': 1,
        };
      }).where((invoice) => invoice != null).toList();

      // Group by date and count invoices
      final dailyInvoices = <DateTime, int>{};
      final validInvoices = invoices.where((invoice) => invoice != null).cast<Map<String, dynamic>>().toList();
      for (final invoice in validInvoices) {
        final date = invoice['date'] as DateTime;
        final dayStart = DateTime(date.year, date.month, date.day);
        dailyInvoices[dayStart] = (dailyInvoices[dayStart] ?? 0) + 1;
      }

      // Convert to chart data points
      final chartData = dailyInvoices.entries.map((entry) {
        try {
          return {
            'date': entry.key,
            'value': entry.value.toDouble(),
            'label': '${entry.key.day}/${entry.key.month}',
          };
        } catch (e) {
          return null;
        }
      }).where((item) => item != null).cast<Map<String, dynamic>>().toList();

      // Sort by date
      chartData.sort((a, b) {
        try {
          return (a['date'] as DateTime).compareTo(b['date'] as DateTime);
        } catch (e) {
          return 0;
        }
      });
      
      return chartData;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopTags(DateRange dateRange, int limit) async {
    try {
      // Check if user is authenticated
      if (_userId.isEmpty) {
        return [];
      }
      
      final query = _buildInvoicesQuery(dateRange, []);
      final invoicesSnapshot = await query.get();

      final tagRevenue = <String, double>{};
      final tagCount = <String, int>{};

      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];
        final total = (data['total'] as num?)?.toDouble() ?? 0.0;

        for (final tag in tags) {
          tagRevenue[tag] = (tagRevenue[tag] ?? 0.0) + total;
          tagCount[tag] = (tagCount[tag] ?? 0) + 1;
        }
      }

      // Sort by revenue and take top tags
      final sortedTags = tagRevenue.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topTags = sortedTags.take(limit).map((entry) {
        final tagName = entry.key;
        final revenue = entry.value;
        final count = tagCount[tagName] ?? 0;
        final totalRevenue = tagRevenue.values.fold<double>(0.0, (total, value) => total + value);
        final percentage = totalRevenue > 0 ? (revenue / totalRevenue) * 100 : 0.0;

        return {
          'tagName': tagName,
          'tagColor': '#FF6B6B', // Default color
          'revenue': revenue,
          'invoiceCount': count,
          'percentage': percentage,
        };
      }).toList();

      return topTags;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, int>> getStatusDistribution(DateRange dateRange, List<String> tagFilters) async {
    try {
      // Check if user is authenticated
      if (_userId.isEmpty) {
        return {};
      }
      
      final query = _buildInvoicesQuery(dateRange, tagFilters);
      final invoicesSnapshot = await query.get();

      final statusCount = <String, int>{};

      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final status = _parseInvoiceStatus(data['status']);
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }

      return statusCount;
    } catch (e) {
      return {};
    }
  }

  Query<Map<String, dynamic>> _buildInvoicesQuery(DateRange dateRange, List<String> tagFilters) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.invoicesCollection)
        .where('userId', isEqualTo: _userId);

    // Filter by date range in memory to avoid composite index
    // We'll filter the results after fetching
    
    return query;
  }

  String _parseInvoiceStatus(dynamic status) {
    if (status == null) return 'pending';
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('paid')) return 'paid';
    if (statusStr.contains('overdue')) return 'overdue';
    if (statusStr.contains('cancelled')) return 'cancelled';
    return 'pending';
  }

  Map<String, dynamic> _getEmptyStats() {
    return {
      'totalInvoices': 0,
      'totalRevenue': 0.0,
      'averageValue': 0.0,
      'newCustomers': 0,
      'revenueChartData': <Map<String, dynamic>>[],
      'invoiceChartData': <Map<String, dynamic>>[],
      'topTags': <Map<String, dynamic>>[],
      'statusDistribution': <String, int>{},
    };
  }
} 