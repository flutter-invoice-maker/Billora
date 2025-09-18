import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:billora/src/core/services/image_upload_service.dart';
import 'dart:io';

@LazySingleton()
class UserService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageUploadService _imageUploadService;

  // Simple in-memory cache to avoid flicker from repeated loads
  UserProfile? _cachedProfile;
  DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(minutes: 5);

  UserService(this._imageUploadService);

  User? get currentUser => _auth.currentUser;

  bool _isCacheValid() {
    if (_cachedProfile == null || _cachedAt == null) return false;
    return DateTime.now().difference(_cachedAt!) < _cacheTtl;
  }

  Future<UserProfile?> getUserProfileCached() async {
    if (_isCacheValid()) return _cachedProfile;
    final profile = await getUserProfile();
    _cachedProfile = profile;
    _cachedAt = DateTime.now();
    return profile;
  }

  // Get user profile data from Firestore
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Create default profile if doesn't exist
        final defaultProfile = _createDefaultProfile(user);
        await _createProfileInFirestore(defaultProfile);
        return defaultProfile;
      }

      final data = doc.data()!;
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: data['displayName'] ?? user.displayName ?? 'User',
        photoURL: data['photoURL'] ?? user.photoURL,
        plan: data['plan'] ?? 'Free',
        createdAt: data['createdAt'] != null 
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        lastLoginAt: data['lastLoginAt'] != null 
            ? (data['lastLoginAt'] as Timestamp).toDate()
            : DateTime.now(),
        phone: data['phone'],
        company: data['company'],
        address: data['address'],
        avatarUrl: data['avatarUrl'],
      );
      _cachedProfile = profile;
      _cachedAt = DateTime.now();
      return profile;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Get user statistics
  Future<UserStats> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return UserStats.empty();

      // Get invoice count
      final invoiceSnapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Get customer count
      final customerSnapshot = await _firestore
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Calculate statistics by status
      int draftCount = 0;
      int sentCount = 0;
      int paidCount = 0;
      double totalRevenue = 0;

      for (final doc in invoiceSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final total = (data['total'] ?? 0).toDouble();

        switch (status) {
          case 'draft':
            draftCount++;
            break;
          case 'sent':
            sentCount++;
            break;
          case 'paid':
            paidCount++;
            totalRevenue += total;
            break;
        }
      }

      return UserStats(
        invoiceCount: invoiceSnapshot.docs.length,
        customerCount: customerSnapshot.docs.length,
        totalRevenue: totalRevenue,
        draftCount: draftCount,
        sentCount: sentCount,
        paidCount: paidCount,
      );
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return UserStats.empty();
    }
  }

  // Create default profile for new users
  UserProfile _createDefaultProfile(User user) {
    return UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoURL: user.photoURL,
      plan: 'Free',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      phone: null,
      company: null,
      address: null,
      avatarUrl: null,
    );
  }

  // Create profile in Firestore
  Future<void> _createProfileInFirestore(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set({
        'displayName': profile.displayName,
        'photoURL': profile.photoURL,
        'plan': profile.plan,
        'createdAt': Timestamp.fromDate(profile.createdAt),
        'lastLoginAt': Timestamp.fromDate(profile.lastLoginAt),
        'phone': profile.phone,
        'company': profile.company,
        'address': profile.address,
        'avatarUrl': profile.avatarUrl,
      });
    } catch (e) {
      debugPrint('Error creating profile in Firestore: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updateData = <String, dynamic>{
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) updateData['photoURL'] = photoURL;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  // Update user profile with additional fields
  Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    String? company,
    String? address,
    String? avatarUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updateData = <String, dynamic>{
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (phone != null) updateData['phone'] = phone;
      if (company != null) updateData['company'] = company;
      if (address != null) updateData['address'] = address;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));
      // update cache
      if (_cachedProfile != null) {
        _cachedProfile = UserProfile(
          uid: _cachedProfile!.uid,
          email: _cachedProfile!.email,
          displayName: displayName ?? _cachedProfile!.displayName,
          photoURL: _cachedProfile!.photoURL,
          plan: _cachedProfile!.plan,
          createdAt: _cachedProfile!.createdAt,
          lastLoginAt: DateTime.now(),
          phone: phone ?? _cachedProfile!.phone,
          company: company ?? _cachedProfile!.company,
          address: address ?? _cachedProfile!.address,
          avatarUrl: avatarUrl ?? _cachedProfile!.avatarUrl,
        );
        _cachedAt = DateTime.now();
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  // Upload avatar image
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final avatarUrl = await _imageUploadService.uploadProfileImage(imageFile);
      
      // Update user profile with new avatar URL
      await updateUserProfile(avatarUrl: avatarUrl);
      
      return avatarUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  // Clear user cache and data (called during logout)
  Future<void> clearUserCache() async {
    try {
      // Clear any cached data if needed
      // Currently UserService doesn't cache data, but this method
      // can be extended in the future if caching is implemented
      debugPrint('User cache cleared');
    } catch (e) {
      debugPrint('Error clearing user cache: $e');
    }
  }
}

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String plan;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String? phone;
  final String? company;
  final String? address;
  final String? avatarUrl;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.plan,
    required this.createdAt,
    required this.lastLoginAt,
    this.phone,
    this.company,
    this.address,
    this.avatarUrl,
  });
}

class UserStats {
  final int invoiceCount;
  final int customerCount;
  final double totalRevenue;
  final int draftCount;
  final int sentCount;
  final int paidCount;

  UserStats({
    required this.invoiceCount,
    required this.customerCount,
    required this.totalRevenue,
    required this.draftCount,
    required this.sentCount,
    required this.paidCount,
  });

  factory UserStats.empty() {
    return UserStats(
      invoiceCount: 0,
      customerCount: 0,
      totalRevenue: 0,
      draftCount: 0,
      sentCount: 0,
      paidCount: 0,
    );
  }
}


