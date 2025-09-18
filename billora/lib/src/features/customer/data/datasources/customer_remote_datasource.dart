import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billora/src/features/customer/data/models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class CustomerRemoteDatasource {
  Future<void> createCustomer(CustomerModel customer);
  Future<List<CustomerModel>> getCustomers();
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<List<CustomerModel>> searchCustomers(String query);
}

class CustomerRemoteDatasourceImpl implements CustomerRemoteDatasource {
  final FirebaseFirestore firestore;
  CustomerRemoteDatasourceImpl(this.firestore);

  @override
  Future<void> createCustomer(CustomerModel customer) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final keywords = _generateKeywords(customer.name, customer.email, customer.phone);
    final data = customer.copyWith(
      searchKeywords: keywords,
    ).toJson()..['userId'] = userId..['createdAt'] = DateTime.now().toIso8601String();

    // Always use the provided customer ID to ensure consistency
    await firestore.collection('customers').doc(customer.id).set(data);
  }

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await firestore
        .collection('customers')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => CustomerModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final keywords = _generateKeywords(customer.name, customer.email, customer.phone);
    final data = customer.copyWith(searchKeywords: keywords).toJson()..['userId'] = userId;
    // Ensure createdAt is a string if it exists
    if (data['createdAt'] is DateTime) {
      data['createdAt'] = (data['createdAt'] as DateTime).toIso8601String();
    }
    await firestore.collection('customers').doc(customer.id).update(data);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await firestore.collection('customers').doc(id).delete();
  }
  
  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await firestore
        .collection('customers')
        .where('userId', isEqualTo: userId)
        .where('searchKeywords', arrayContains: query.toLowerCase())
        .get();
    return snapshot.docs.map((doc) => CustomerModel.fromJson(doc.data())).toList();
  }
}

List<String> _generateKeywords(String name, String? email, String? phone) {
  final List<String> keywords = [];
  final fullText =
      '${name.toLowerCase()} ${email?.toLowerCase() ?? ''} ${phone?.toLowerCase() ?? ''}';
  final cleanedText = fullText.replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ');
  final words = cleanedText.trim().split(RegExp(r'\s+'));

  for (final word in words) {
    if (word.isNotEmpty) {
      for (var i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i));
      }
    }
  }
  return keywords.toSet().toList();
} 
