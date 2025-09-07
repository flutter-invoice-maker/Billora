import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/chat/domain/entities/chat_message.dart';
import 'package:billora/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:billora/src/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:billora/src/features/customer/domain/repositories/customer_repository.dart';
import 'package:billora/src/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:billora/src/core/errors/failures.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final InvoiceRepository _invoiceRepository;
  final CustomerRepository _customerRepository;
  final ProductRepository _productRepository;

  ChatRepositoryImpl(
    this._firestore,
    this._auth,
    this._invoiceRepository,
    this._customerRepository,
    this._productRepository,
  );

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      _firestore.collection('users').doc(_currentUserId).collection('chat_messages');

  @override
  ResultFuture<void> saveMessage(ChatMessage message) async {
    try {
      await _messagesCollection.doc(message.id).set(message.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save message: $e'));
    }
  }

  @override
  ResultFuture<void> updateMessageContent(String messageId, String content) async {
    try {
      await _messagesCollection.doc(messageId).update({
        'content': content,
        'isStreaming': false,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update message content: $e'));
    }
  }

  @override
  ResultFuture<ChatMessage?> getMessageById(String messageId) async {
    try {
      final doc = await _messagesCollection.doc(messageId).get();
      if (doc.exists) {
        return Right(ChatMessage.fromJson({
          'id': doc.id,
          ...doc.data()!,
        }));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to get message: $e'));
    }
  }

  @override
  ResultFuture<List<ChatMessage>> getUserMessages(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_messages')
          .orderBy('timestamp', descending: true)
          .get();

      final messages = querySnapshot.docs
          .map((doc) => ChatMessage.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      return Right(messages);
    } catch (e) {
      return Left(ServerFailure('Failed to get user messages: $e'));
    }
  }

  @override
  ResultFuture<List<ChatMessage>> getConversationMessages(String conversationId) async {
    try {
      final querySnapshot = await _messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .get();

      final messages = querySnapshot.docs
          .map((doc) => ChatMessage.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      return Right(messages);
    } catch (e) {
      return Left(ServerFailure('Failed to get conversation messages: $e'));
    }
  }

  @override
  ResultFuture<void> deleteMessage(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete message: $e'));
    }
  }

  @override
  ResultFuture<String> getUserData(String userId) async {
    try {
      final Map<String, dynamic> data = {};
      
      // Get invoices
      final invoiceResult = await _invoiceRepository.getInvoices();
      invoiceResult.fold(
        (failure) => data['invoices'] = [],
        (invoices) => data['invoices'] = invoices.map((i) => {
          'id': i.id,
          'customerName': i.customerName,
          'total': i.total,
          'status': i.status,
          'createdAt': i.createdAt.toIso8601String(),
          'items': i.items.map((item) => {
            'name': item.name,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'total': item.total,
          }).toList(),
        }).toList(),
      );
      
      // Get customers
      final customerResult = await _customerRepository.getCustomers();
      customerResult.fold(
        (failure) => data['customers'] = [],
        (customers) => data['customers'] = customers.map((c) => {
          'id': c.id,
          'name': c.name,
          'email': c.email,
          'phone': c.phone,
          'address': c.address,
        }).toList(),
      );
      
      // Get products
      final productResult = await _productRepository.getProducts();
      productResult.fold(
        (failure) => data['products'] = [],
        (products) => data['products'] = products.map((p) => {
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'price': p.price,
          'category': p.category,
          'inventory': p.inventory,
        }).toList(),
      );

      return Right(json.encode(data));
    } catch (e) {
      return Left(ServerFailure('Failed to get user data: $e'));
    }
  }
}
