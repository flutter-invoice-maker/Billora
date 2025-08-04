import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class InvoiceRemoteDatasource {
  Future<void> createInvoice(InvoiceModel invoice);
  Future<List<InvoiceModel>> getInvoices();
  Future<void> deleteInvoice(String id);
}

class InvoiceRemoteDatasourceImpl implements InvoiceRemoteDatasource {
  final FirebaseFirestore firestore;
  InvoiceRemoteDatasourceImpl(this.firestore);

  @override
  Future<void> createInvoice(InvoiceModel invoice) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final data = invoice.toJson()..['userId'] = userId;
    
    // Debug logging
    debugPrint('🔍 Creating invoice with data: ${data.toString()}');
    debugPrint('🔍 User ID: $userId');
    debugPrint('🔍 Invoice ID: ${invoice.id}');
    
    try {
      if (invoice.id.isEmpty) {
        await firestore.collection('invoices').add(data);
        debugPrint('✅ Invoice created successfully with auto-generated ID');
      } else {
        await firestore.collection('invoices').doc(invoice.id).set(data);
        debugPrint('✅ Invoice created successfully with provided ID: ${invoice.id}');
      }
    } catch (e) {
      debugPrint('❌ Error creating invoice: $e');
      rethrow;
    }
  }

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await firestore
        .collection('invoices')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => InvoiceModel.fromJson({
      ...doc.data(),
      'id': doc.id,
    })).toList();
  }

  @override
  Future<void> deleteInvoice(String id) async {
    if (id.isEmpty) return;
    await firestore.collection('invoices').doc(id).delete();
  }
} 