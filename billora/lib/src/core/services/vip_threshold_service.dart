import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class VipThresholdService {
  static final VipThresholdService _instance = VipThresholdService._internal();
  factory VipThresholdService() => _instance;
  VipThresholdService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Default VIP threshold (in USD)
  static const double _defaultThreshold = 1000.0;

  /// Get VIP threshold for current user
  Future<double> getVipThreshold() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _defaultThreshold;

      final doc = await _firestore
          .collection('user_settings')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return (data?['vip_threshold'] as num?)?.toDouble() ?? _defaultThreshold;
      }

      // Create default settings if not exists
      await setVipThreshold(_defaultThreshold);
      return _defaultThreshold;
    } catch (e) {
      debugPrint('Error getting VIP threshold: $e');
      return _defaultThreshold;
    }
  }

  /// Set VIP threshold for current user
  Future<void> setVipThreshold(double threshold) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('user_settings')
          .doc(user.uid)
          .set({
        'vip_threshold': threshold,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('VIP threshold set to: $threshold');
    } catch (e) {
      debugPrint('Error setting VIP threshold: $e');
      throw Exception('Failed to save VIP threshold');
    }
  }

  /// Check if customer should be VIP based on total revenue
  Future<bool> shouldBeVip(String customerId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get customer's total revenue from invoices
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: user.uid)
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'paid')
          .get();

      double totalRevenue = 0.0;
      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final total = (data['total'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += total;
      }

      // Get VIP threshold
      final threshold = await getVipThreshold();
      
      debugPrint('Customer $customerId total revenue: $totalRevenue, threshold: $threshold');
      return totalRevenue >= threshold;
    } catch (e) {
      debugPrint('Error checking VIP status: $e');
      return false;
    }
  }

  /// Update customer VIP status based on threshold
  Future<void> updateCustomerVipStatus(String customerId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if customer document exists first
      final customerDoc = await _firestore
          .collection('customers')
          .doc(customerId)
          .get();

      if (!customerDoc.exists) {
        debugPrint('Customer $customerId does not exist, skipping VIP status update');
        return;
      }

      final shouldBeVip = await this.shouldBeVip(customerId);
      
      // Update customer VIP status
      await _firestore
          .collection('customers')
          .doc(customerId)
          .update({
        'isVip': shouldBeVip,
        'vip_updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('Updated customer $customerId VIP status to: $shouldBeVip');
    } catch (e) {
      debugPrint('Error updating customer VIP status: $e');
    }
  }

  /// Update all customers VIP status based on current threshold
  Future<void> updateAllCustomersVipStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get all customers for current user
      final customersSnapshot = await _firestore
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Update each customer's VIP status
      for (final doc in customersSnapshot.docs) {
        await updateCustomerVipStatus(doc.id);
      }

      debugPrint('Updated VIP status for all customers');
    } catch (e) {
      debugPrint('Error updating all customers VIP status: $e');
    }
  }

  /// Get customer's total revenue
  Future<double> getCustomerTotalRevenue(String customerId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0.0;

      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: user.uid)
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'paid')
          .get();

      double totalRevenue = 0.0;
      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final total = (data['total'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += total;
      }

      return totalRevenue;
    } catch (e) {
      debugPrint('Error getting customer total revenue: $e');
      return 0.0;
    }
  }

  /// Get VIP statistics
  Future<Map<String, dynamic>> getVipStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final customersSnapshot = await _firestore
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .get();

      int totalCustomers = customersSnapshot.docs.length;
      int vipCustomers = 0;
      double totalVipRevenue = 0.0;

      for (final doc in customersSnapshot.docs) {
        final data = doc.data();
        if (data['isVip'] == true) {
          vipCustomers++;
          final revenue = await getCustomerTotalRevenue(doc.id);
          totalVipRevenue += revenue;
        }
      }

      return {
        'total_customers': totalCustomers,
        'vip_customers': vipCustomers,
        'vip_percentage': totalCustomers > 0 ? (vipCustomers / totalCustomers) * 100 : 0.0,
        'total_vip_revenue': totalVipRevenue,
      };
    } catch (e) {
      debugPrint('Error getting VIP statistics: $e');
      return {};
    }
  }
}
