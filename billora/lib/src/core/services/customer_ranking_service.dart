import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/invoice/domain/entities/invoice.dart';

class CustomerRankingService {
  static final CustomerRankingService _instance = CustomerRankingService._internal();
  factory CustomerRankingService() => _instance;
  CustomerRankingService._internal();

  List<CustomerRanking> _rankings = [];
  final List<VoidCallback> _listeners = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CustomerRanking> get rankings => List.unmodifiable(_rankings);

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

  void updateRankings(List<Invoice> invoices) {
    final customerStats = <String, CustomerStats>{};
    
    // Calculate stats for each customer
    for (final invoice in invoices) {
      if (invoice.status == InvoiceStatus.paid) {
        final customerId = invoice.customerId;
        final customerName = invoice.customerName;
        
        if (!customerStats.containsKey(customerId)) {
          customerStats[customerId] = CustomerStats(
            customerId: customerId,
            customerName: customerName,
            totalAmount: 0,
            invoiceCount: 0,
            lastPurchaseDate: invoice.paidAt ?? invoice.createdAt,
          );
        }
        
        final stats = customerStats[customerId]!;
        stats.totalAmount += invoice.total;
        stats.invoiceCount += 1;
        
        if (invoice.paidAt != null && 
            invoice.paidAt!.isAfter(stats.lastPurchaseDate)) {
          stats.lastPurchaseDate = invoice.paidAt!;
        }
      }
    }
    
    // Convert to rankings and sort by total amount
    _rankings = customerStats.values
        .map((stats) => CustomerRanking(
              customerId: stats.customerId,
              customerName: stats.customerName,
              avatarUrl: stats.avatarUrl,
              totalAmount: stats.totalAmount,
              invoiceCount: stats.invoiceCount,
              lastPurchaseDate: stats.lastPurchaseDate,
              level: _calculateLevel(stats.totalAmount),
              score: _calculateScore(stats),
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    
    _notifyListeners();
  }

  // Load customer rankings directly from Firestore
  Future<void> loadCustomerRankings() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Load all customers first
      final customersSnapshot = await _firestore
          .collection('customers')
          .where('userId', isEqualTo: userId)
          .get();
      
      final customerStats = <String, CustomerStats>{};
      
      // Initialize all customers with zero stats and capture avatarUrl
      for (final doc in customersSnapshot.docs) {
        final data = doc.data();
        final customerId = doc.id;
        final customerName = data['name'] as String? ?? 'Unknown';
        final avatarUrl = data['avatarUrl'] as String?;
        
        customerStats[customerId] = CustomerStats(
          customerId: customerId,
          customerName: customerName,
          avatarUrl: avatarUrl,
          totalAmount: 0,
          invoiceCount: 0,
          lastPurchaseDate: DateTime.now(),
        );
      }
      
      // Load all invoices and update stats
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        
        // Process all invoices for ranking (including draft)
        if (status == 'draft' || status == 'sent' || status == 'paid') {
          final customerId = data['customerId'] as String?;
          final customerName = data['customerName'] as String?;
          final total = (data['total'] ?? 0).toDouble();
          final createdAt = data['createdAt'];
          final paidAt = data['paidAt'];
          
          if (customerId != null && customerName != null) {
            DateTime? parsedCreatedAt;
            DateTime? parsedPaidAt;
            
            // Handle different date formats
            if (createdAt is Timestamp) {
              parsedCreatedAt = createdAt.toDate();
            } else if (createdAt is String) {
              parsedCreatedAt = DateTime.tryParse(createdAt);
            }
            
            if (paidAt is Timestamp) {
              parsedPaidAt = paidAt.toDate();
            } else if (paidAt is String) {
              parsedPaidAt = DateTime.tryParse(paidAt);
            }
            
            final finalCreatedAt = parsedCreatedAt ?? DateTime.now();
            // Use createdAt as lastPurchaseDate if no paidAt
            final finalPaidAt = parsedPaidAt ?? finalCreatedAt;
            
            // Create customer if not exists
            if (!customerStats.containsKey(customerId)) {
              customerStats[customerId] = CustomerStats(
                customerId: customerId,
                customerName: customerName,
                totalAmount: 0,
                invoiceCount: 0,
                lastPurchaseDate: finalPaidAt,
              );
            }
            
            final stats = customerStats[customerId]!;
            stats.totalAmount += total;
            stats.invoiceCount += 1;
            
            if (finalPaidAt.isAfter(stats.lastPurchaseDate)) {
              stats.lastPurchaseDate = finalPaidAt;
            }
          }
        }
      }
      
      // Convert to rankings and sort by score
      _rankings = customerStats.values
          .map((stats) => CustomerRanking(
                customerId: stats.customerId,
                customerName: stats.customerName,
                avatarUrl: stats.avatarUrl,
                totalAmount: stats.totalAmount,
                invoiceCount: stats.invoiceCount,
                lastPurchaseDate: stats.lastPurchaseDate,
                level: _calculateLevel(stats.totalAmount),
                score: _calculateScore(stats),
              ))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      _notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading customer rankings: $e');
    }
  }

  int _calculateLevel(double totalAmount) {
    if (totalAmount >= 1000000) return 40; // Level 40 for $1M+
    if (totalAmount >= 500000) return 33;  // Level 33 for $500K+
    if (totalAmount >= 100000) return 18;  // Level 18 for $100K+
    if (totalAmount >= 50000) return 6;    // Level 6 for $50K+
    return 1; // Level 1 for others
  }

  int _calculateScore(CustomerStats stats) {
    // Score based on total amount, invoice count, and recency
    final amountScore = (stats.totalAmount / 1000).round();
    final countScore = stats.invoiceCount * 10;
    final recencyScore = _calculateRecencyScore(stats.lastPurchaseDate);
    
    return amountScore + countScore + recencyScore;
  }

  int _calculateRecencyScore(DateTime lastPurchase) {
    final daysSinceLastPurchase = DateTime.now().difference(lastPurchase).inDays;
    
    if (daysSinceLastPurchase <= 7) return 100;
    if (daysSinceLastPurchase <= 30) return 50;
    if (daysSinceLastPurchase <= 90) return 25;
    return 0;
  }

  String getRankingBadge(int position) {
    switch (position) {
      case 1:
        return 'NO.1';
      case 2:
        return 'NO.2';
      case 3:
        return 'NO.3';
      default:
        return 'NO.$position';
    }
  }

  Color getRankingColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey[400]!;
    }
  }

  Color getLevelColor(int level) {
    if (level >= 30) return const Color(0xFF9C27B0); // Purple
    if (level >= 20) return const Color(0xFF2196F3); // Blue
    if (level >= 10) return const Color(0xFF4CAF50); // Green
    if (level >= 5) return const Color(0xFFFF9800); // Orange
    return const Color(0xFF607D8B); // Blue Grey
  }
}

class CustomerStats {
  final String customerId;
  final String customerName;
  String? avatarUrl;
  double totalAmount;
  int invoiceCount;
  DateTime lastPurchaseDate;

  CustomerStats({
    required this.customerId,
    required this.customerName,
    this.avatarUrl,
    required this.totalAmount,
    required this.invoiceCount,
    required this.lastPurchaseDate,
  });
}

class CustomerRanking {
  final String customerId;
  final String customerName;
  final String? avatarUrl;
  final double totalAmount;
  final int invoiceCount;
  final DateTime lastPurchaseDate;
  final int level;
  final int score;

  CustomerRanking({
    required this.customerId,
    required this.customerName,
    this.avatarUrl,
    required this.totalAmount,
    required this.invoiceCount,
    required this.lastPurchaseDate,
    required this.level,
    required this.score,
  });

  String get formattedAmount {
    if (totalAmount >= 1000000) {
      return '${(totalAmount / 1000000).toStringAsFixed(1)}M+';
    } else if (totalAmount >= 1000) {
      return '${(totalAmount / 1000).toStringAsFixed(0)}K+';
    } else {
      return totalAmount.toStringAsFixed(0);
    }
  }

  String get formattedScore {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M+';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(0)}K+';
    } else {
      return score.toString();
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastPurchaseDate);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()} weeks ago';
    } else {
      return '${(difference.inDays / 30).round()} months ago';
    }
  }
}
