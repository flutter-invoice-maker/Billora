import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'activity_service.dart';
import 'customer_ranking_service.dart';
import 'package:billora/src/core/di/injection_container.dart';
import 'package:billora/src/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class DataRefreshService {
  static final DataRefreshService _instance = DataRefreshService._internal();
  factory DataRefreshService() => _instance;
  DataRefreshService._internal();

  final NotificationService _notificationService = NotificationService();
  final ActivityService _activityService = ActivityService();
  final CustomerRankingService _customerRankingService = CustomerRankingService();

  // Refresh all data from Firestore
  Future<void> refreshAllData() async {
    try {
      // Load all data in parallel for better performance
      await Future.wait([
        _notificationService.loadOverdueInvoices(),
        _activityService.loadActivities(),
        _customerRankingService.loadCustomerRankings(),
        _refreshDashboard(),
      ]);
    } catch (e) {
      debugPrint('❌ Error refreshing data: $e');
    }
  }

  // Refresh dashboard data
  Future<void> _refreshDashboard() async {
    try {
      final dashboardCubit = sl<DashboardCubit>();
      await dashboardCubit.loadDashboardStats();
    } catch (e) {
      debugPrint('❌ Error refreshing dashboard: $e');
    }
  }

  // Refresh specific data
  Future<void> refreshNotifications() async {
    await _notificationService.loadOverdueInvoices();
  }

  Future<void> refreshActivities() async {
    await _activityService.loadActivities();
  }

  Future<void> refreshCustomerRankings() async {
    await _customerRankingService.loadCustomerRankings();
  }

  Future<void> refreshDashboard() async {
    await _refreshDashboard();
  }

}
