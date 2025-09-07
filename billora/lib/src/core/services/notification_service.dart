import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<OverdueNotification> _notifications = [];
  final List<VoidCallback> _listeners = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<OverdueNotification> get notifications => List.unmodifiable(_notifications);

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void addOverdueInvoice(Invoice invoice) {
    final notification = OverdueNotification(
      id: 'overdue_${invoice.id}',
      invoiceId: invoice.id,
      customerName: invoice.customerName,
      amount: invoice.total,
      dueDate: invoice.dueDate!,
      daysOverdue: DateTime.now().difference(invoice.dueDate!).inDays,
    );
    
    // Check if notification already exists
    if (!_notifications.any((n) => n.invoiceId == invoice.id)) {
      _notifications.add(notification);
      _notifyListeners();
    }
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _notifyListeners();
  }

  void updateOverdueInvoices(List<Invoice> invoices) {
    _notifications.clear();
    
    final now = DateTime.now();
    for (final invoice in invoices) {
      if (invoice.status == InvoiceStatus.sent && 
          invoice.dueDate != null && 
          invoice.dueDate!.isBefore(now)) {
        addOverdueInvoice(invoice);
      }
    }
  }

  // Load overdue invoices directly from Firestore
  Future<void> loadOverdueInvoices() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final now = DateTime.now();
      
      // Get all invoices for the user first
      final snapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .get();
      
      _notifications.clear();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final dueDate = data['dueDate'];
        
        // Check if invoice is overdue
        if (status == 'sent' && dueDate != null) {
          DateTime? parsedDueDate;
          
          // Handle different date formats
          if (dueDate is Timestamp) {
            parsedDueDate = dueDate.toDate();
          } else if (dueDate is String) {
            parsedDueDate = DateTime.tryParse(dueDate);
          }
          
          if (parsedDueDate != null && parsedDueDate.isBefore(now)) {
            final daysOverdue = now.difference(parsedDueDate).inDays;
            
            final notification = OverdueNotification(
              id: 'overdue_${doc.id}',
              invoiceId: doc.id,
              customerName: data['customerName'] ?? 'Unknown Customer',
              amount: (data['total'] ?? 0).toDouble(),
              dueDate: parsedDueDate,
              daysOverdue: daysOverdue,
            );
            
            _notifications.add(notification);
          }
        }
      }
      _notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading overdue invoices: $e');
    }
  }
}

class OverdueNotification {
  final String id;
  final String invoiceId;
  final String customerName;
  final double amount;
  final DateTime dueDate;
  final int daysOverdue;

  OverdueNotification({
    required this.id,
    required this.invoiceId,
    required this.customerName,
    required this.amount,
    required this.dueDate,
    required this.daysOverdue,
  });
}