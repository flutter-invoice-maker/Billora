import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billora/src/features/customer/data/models/customer_model.dart';

abstract class CustomerRemoteDatasource {
  Future<void> createCustomer(CustomerModel customer);
  Future<List<CustomerModel>> getCustomers();
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDatasourceImpl implements CustomerRemoteDatasource {
  final FirebaseFirestore firestore;
  CustomerRemoteDatasourceImpl(this.firestore);

  @override
  Future<void> createCustomer(CustomerModel customer) async {
    if (customer.id.isEmpty) {
      await firestore.collection('customers').add(customer.toJson());
    } else {
      await firestore.collection('customers').doc(customer.id).set(customer.toJson());
    }
  }

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final snapshot = await firestore.collection('customers').get();
    return snapshot.docs.map((doc) => CustomerModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await firestore.collection('customers').doc(customer.id).update(customer.toJson());
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await firestore.collection('customers').doc(id).delete();
  }
} 
