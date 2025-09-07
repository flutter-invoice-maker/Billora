import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final List<Activity> _activities = [];
  final List<VoidCallback> _listeners = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Activity> get activities => List.unmodifiable(_activities);

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

  void addActivity(Activity activity) {
    _activities.insert(0, activity); // Add to beginning
    if (_activities.length > 100) {
      _activities.removeRange(100, _activities.length); // Keep only last 100
    }
    _notifyListeners();
  }

  // Load activities from Firestore
  Future<void> loadActivities() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Load recent invoices and convert to activities
      final invoiceSnapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .get();
      
      _activities.clear();

      for (final doc in invoiceSnapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        final status = data['status'] as String?;
        
        if (status != null) {
          DateTime? parsedCreatedAt;
          
          // Handle different date formats
          if (createdAt is Timestamp) {
            parsedCreatedAt = createdAt.toDate();
          } else if (createdAt is String) {
            parsedCreatedAt = DateTime.tryParse(createdAt);
          }
          
          if (parsedCreatedAt != null) {
            // Create activity based on invoice status
            ActivityType activityType;
            String title;
            String description;
            
            switch (status) {
              case 'draft':
                activityType = ActivityType.invoiceCreated;
                title = 'Invoice Created';
                description = 'Invoice #${doc.id} created for ${data['customerName'] ?? 'Unknown Customer'}';
                break;
              case 'sent':
                activityType = ActivityType.invoiceSent;
                title = 'Invoice Sent';
                description = 'Invoice #${doc.id} sent to ${data['customerName'] ?? 'Unknown Customer'}';
                break;
              case 'paid':
                activityType = ActivityType.invoicePaid;
                title = 'Invoice Paid';
                description = 'Invoice #${doc.id} has been paid by ${data['customerName'] ?? 'Unknown Customer'}';
                break;
              case 'overdue':
                activityType = ActivityType.invoiceOverdue;
                title = 'Invoice Overdue';
                description = 'Invoice #${doc.id} is overdue for ${data['customerName'] ?? 'Unknown Customer'}';
                break;
              default:
                activityType = ActivityType.invoiceCreated;
                title = 'Invoice Updated';
                description = 'Invoice #${doc.id} updated for ${data['customerName'] ?? 'Unknown Customer'}';
            }

            final activity = Activity(
              id: 'invoice_${doc.id}',
              type: activityType,
              title: title,
              description: description,
              amount: (data['total'] ?? 0).toDouble(),
              timestamp: parsedCreatedAt,
              metadata: {
                'invoiceId': doc.id,
                'customerName': data['customerName'] ?? 'Unknown Customer',
                'status': status,
              },
            );

            _activities.add(activity);
          }
        }
      }

      // Sort by timestamp (newest first)
      _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading activities: $e');
    }
  }

  void addInvoiceCreatedActivity(Invoice invoice) {
    addActivity(Activity(
      id: 'invoice_created_${invoice.id}',
      type: ActivityType.invoiceCreated,
      title: 'Invoice Created',
      description: 'Invoice #${invoice.id} created for ${invoice.customerName}',
      amount: invoice.total,
      timestamp: invoice.createdAt,
      metadata: {
        'invoiceId': invoice.id,
        'customerName': invoice.customerName,
        'status': invoice.status.name,
      },
    ));
  }

  void addCustomerAddedActivity(String customerName) {
    addActivity(Activity(
      id: 'customer_added_${DateTime.now().millisecondsSinceEpoch}',
      type: ActivityType.customerAdded,
      title: 'New Customer Added',
      description: 'New customer added: $customerName',
      timestamp: DateTime.now(),
      metadata: {
        'customerName': customerName,
      },
    ));
  }

  void addProductStockUpdatedActivity(String productName, int quantity) {
    addActivity(Activity(
      id: 'stock_updated_${DateTime.now().millisecondsSinceEpoch}',
      type: ActivityType.stockUpdated,
      title: 'Product Stock Updated',
      description: 'Product stock updated: $productName (${quantity > 0 ? '+' : ''}$quantity units)',
      timestamp: DateTime.now(),
      metadata: {
        'productName': productName,
        'quantity': quantity.toString(),
      },
    ));
  }

  void addInvoiceStatusChangedActivity(Invoice invoice, InvoiceStatus oldStatus, InvoiceStatus newStatus) {
    addActivity(Activity(
      id: 'status_changed_${invoice.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: ActivityType.statusChanged,
      title: 'Invoice Status Changed',
      description: 'Invoice #${invoice.id} status changed from ${oldStatus.name} to ${newStatus.name}',
      amount: invoice.total,
      timestamp: DateTime.now(),
      metadata: {
        'invoiceId': invoice.id,
        'customerName': invoice.customerName,
        'oldStatus': oldStatus.name,
        'newStatus': newStatus.name,
      },
    ));
  }

  void addInvoicePaidActivity(Invoice invoice) {
    addActivity(Activity(
      id: 'invoice_paid_${invoice.id}',
      type: ActivityType.invoicePaid,
      title: 'Invoice Paid',
      description: 'Invoice #${invoice.id} has been paid by ${invoice.customerName}',
      amount: invoice.total,
      timestamp: DateTime.now(),
      metadata: {
        'invoiceId': invoice.id,
        'customerName': invoice.customerName,
      },
    ));
  }

  List<Activity> searchActivities(String query) {
    if (query.isEmpty) return _activities;
    
    final lowerQuery = query.toLowerCase();
    return _activities.where((activity) {
      return activity.title.toLowerCase().contains(lowerQuery) ||
             activity.description.toLowerCase().contains(lowerQuery) ||
             activity.metadata.values.any((value) => 
               value.toString().toLowerCase().contains(lowerQuery));
    }).toList();
  }

  void clearActivities() {
    _activities.clear();
    _notifyListeners();
  }
}

enum ActivityType {
  invoiceCreated,
  customerAdded,
  stockUpdated,
  statusChanged,
  invoicePaid,
  invoiceSent,
  invoiceOverdue,
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final double? amount;
  final DateTime timestamp;
  final Map<String, String> metadata;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.amount,
    required this.timestamp,
    this.metadata = const {},
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  IconData get icon {
    switch (type) {
      case ActivityType.invoiceCreated:
        return Icons.receipt_long;
      case ActivityType.customerAdded:
        return Icons.people;
      case ActivityType.stockUpdated:
        return Icons.inventory_2;
      case ActivityType.statusChanged:
        return Icons.swap_horiz;
      case ActivityType.invoicePaid:
        return Icons.check_circle;
      case ActivityType.invoiceSent:
        return Icons.send;
      case ActivityType.invoiceOverdue:
        return Icons.warning;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.invoiceCreated:
        return const Color(0xFFE53E3E);
      case ActivityType.customerAdded:
        return const Color(0xFFBF33F3);
      case ActivityType.stockUpdated:
        return const Color(0xFF60D219);
      case ActivityType.statusChanged:
        return const Color(0xFF3182CE);
      case ActivityType.invoicePaid:
        return const Color(0xFF38A169);
      case ActivityType.invoiceSent:
        return const Color(0xFF3182CE);
      case ActivityType.invoiceOverdue:
        return const Color(0xFFE53E3E);
    }
  }
}
