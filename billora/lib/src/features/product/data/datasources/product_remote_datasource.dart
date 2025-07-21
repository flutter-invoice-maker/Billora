import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProductRemoteDatasource {
  Future<void> createProduct(ProductModel product);
  Future<List<ProductModel>> getProducts();
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<String>> getCategories();
}

class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  final FirebaseFirestore firestore;
  ProductRemoteDatasourceImpl(this.firestore);

  @override
  Future<void> createProduct(ProductModel product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final keywords = _generateKeywords(product.name, product.description, product.category);
    final data = product.toJson()
      ..['userId'] = userId
      ..['searchKeywords'] = keywords;
    if (product.id.isEmpty) {
      await firestore.collection('products').add(data);
    } else {
      await firestore.collection('products').doc(product.id).set(data);
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final keywords = _generateKeywords(product.name, product.description, product.category);
    final data = product.toJson()
      ..['userId'] = userId
      ..['searchKeywords'] = keywords;
    await firestore.collection('products').doc(product.id).update(data);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await firestore.collection('products').doc(id).delete();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .where('searchKeywords', arrayContains: query.toLowerCase())
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();
    final categories = snapshot.docs.map((doc) => doc['category'] as String).toSet().toList();
    return categories;
  }
}

List<String> _generateKeywords(String name, String? description, String category) {
  final List<String> keywords = [];
  final fullText =
      '${name.toLowerCase()} ${description?.toLowerCase() ?? ''} ${category.toLowerCase()}';
  // Regex để loại bỏ dấu câu nhưng giữ lại các ký tự Unicode (chữ/số)
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