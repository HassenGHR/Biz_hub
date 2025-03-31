import 'dart:convert';

import 'package:biz_hub/models/company.dart';
import 'package:biz_hub/models/comment.dart'; // Make sure to import the Comment model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';

class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Get companies with pagination

  Future<List<String>> getCategories() async {
    // Load JSON from local assets
    String jsonString =
        await rootBundle.loadString('assets/json/companies.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    // Extract category keys and return as a list
    return jsonData.keys.toList();
  }

  Future<List<Company>> getCompanies({
    String? category,
    String? searchQuery,
  }) async {
    // Load JSON from local assets
    String jsonString =
        await rootBundle.loadString('assets/json/companies.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    // Flatten JSON into a list of companies
    List<Company> companies = [];

    jsonData.forEach((categoryKey, companyList) {
      for (var companyData in companyList) {
        companies.add(
          Company(
            id: companyData['id'] ?? '',
            name: companyData['companyName'] ?? '',
            category: categoryKey,
            address: companyData['address'] ?? '',
            phone: companyData['phone'] ?? '',
            ratings: 0.0, // Default rating if not provided
            imageUrl: companyData['imageUrl'] ?? '',
            thumbsUp: 0,
            thumbsDown: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: "system",
            lastUpdatedBy: "system",
          ),
        );
      }
    });

    // Apply category filter
    if (category != null && category.isNotEmpty) {
      companies =
          companies.where((company) => company.category == category).toList();
    }

    // Apply search query filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      companies = companies.where((company) {
        return company.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return companies;
  }

  // Get company by ID
  Future<Company?> getCompanyById(String id) async {
    final doc = await _firestore.collection('companies').doc(id).get();
    if (doc.exists) {
      return Company.fromFirestore(doc);
    }
    return null;
  }

  // Add new company
  Future<String> addCompany(Company company) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final companyData = company.toFirestore();
    companyData['createdBy'] = user.uid;
    companyData['lastUpdatedBy'] = user.uid;
    companyData['createdAt'] = FieldValue.serverTimestamp();
    companyData['updatedAt'] = FieldValue.serverTimestamp();

    // Create keywords for better search
    List<String> keywords = [
      company.name.toLowerCase(),
      company.category.toLowerCase(),
      ...company.address.toLowerCase().split(' ')
    ];
    companyData['keywords'] = keywords;

    final docRef = await _firestore.collection('companies').add(companyData);

    // Update user's contributions
    await _firestore.collection('users').doc(user.uid).update({
      'contributions': FieldValue.arrayUnion([docRef.id]),
      'reputation':
          FieldValue.increment(10), // Award points for adding a company
    });

    return docRef.id;
  }

  // Edit an existing company
  Future<void> editCompany(String companyId, Company updatedCompany) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Get current company data to preserve unchanged fields
    final currentCompanyDoc =
        await _firestore.collection('companies').doc(companyId).get();
    if (!currentCompanyDoc.exists) {
      throw Exception('Company not found');
    }

    // Prepare updated data
    final updatedData = updatedCompany.toFirestore();

    // Update metadata
    updatedData['lastUpdatedBy'] = user.uid;
    updatedData['updatedAt'] = FieldValue.serverTimestamp();

    // Regenerate keywords for search
    List<String> keywords = [
      updatedCompany.name.toLowerCase(),
      updatedCompany.category.toLowerCase(),
      ...updatedCompany.address.toLowerCase().split(' ')
    ];
    updatedData['keywords'] = keywords;

    // Keep track of what was changed for audit purposes
    final List<String> changedFields = [];
    final currentData = currentCompanyDoc.data() as Map<String, dynamic>;

    updatedData.forEach((key, value) {
      if (currentData[key] != value &&
          key != 'updatedAt' &&
          key != 'lastUpdatedBy' &&
          key != 'keywords') {
        changedFields.add(key);
      }
    });

    // Store edit history
    await _firestore.collection('companyEdits').add({
      'companyId': companyId,
      'editedBy': user.uid,
      'editedAt': FieldValue.serverTimestamp(),
      'changedFields': changedFields,
      'previousValues': currentData,
    });

    // Update the company document
    await _firestore.collection('companies').doc(companyId).update(updatedData);

    // Award reputation points for the edit if substantial changes were made
    if (changedFields.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update({
        'edits': FieldValue.arrayUnion([companyId]),
        'reputation': FieldValue.increment(5), // Award points for editing
      });
    }
  }

  // Submit edit for review
  Future<void> submitEdit(String companyId, Map<String, dynamic> edits) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('editRequests').add({
      'companyId': companyId,
      'edits': edits,
      'requestedBy': user.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add rating (thumbs up/down)
  Future<void> rateCompany(
      String companyId, bool isThumbsUp, double rating) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final field = isThumbsUp ? 'thumbsUp' : 'thumbsDown';

    // Check if user already rated
    final ratingDoc = await _firestore
        .collection('ratings')
        .where('companyId', isEqualTo: companyId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (ratingDoc.docs.isNotEmpty) {
      // Update existing rating
      await _firestore.collection('ratings').doc(ratingDoc.docs[0].id).update({
        'isThumbsUp': isThumbsUp,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Create new rating
      await _firestore.collection('ratings').add({
        'companyId': companyId,
        'userId': user.uid,
        'isThumbsUp': isThumbsUp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment company rating count
      await _firestore.collection('companies').doc(companyId).update({
        field: FieldValue.increment(1),
      });
    }
  }

  // Add a comment to a company
  Future<String> addComment(String companyId, Comment comment) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Set the current user information
    comment.userId = user.uid;
    comment.companyId = companyId;
    comment.createdAt = DateTime.now();

    // Get user profile information
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      comment.userName = userDoc.data()?['displayName'] ?? 'Anonymous';
      comment.userProfileUrl = userDoc.data()?['profilePictureUrl'] ?? '';
    }

    // Prepare comment data for Firestore
    final commentData = {
      'userId': comment.userId,
      'userName': comment.userName,
      'content': comment.content,
      'companyId': companyId,
      'userProfileUrl': comment.userProfileUrl,
      'isPositive': comment.isPositive,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add the comment to Firestore
    final docRef = await _firestore.collection('comments').add(commentData);

    // Update comment count on the company document
    await _firestore.collection('companies').doc(companyId).update({
      'commentCount': FieldValue.increment(1),
    });

    // Award points to the user for contributing
    await _firestore.collection('users').doc(user.uid).update({
      'reputation':
          FieldValue.increment(2), // Award points for adding a comment
    });

    return docRef.id;
  }

  // Get all comments for a company
  Future<List<Comment>> getCompanyComments(String companyId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Comment(
        id: doc.id,
        userId: data['userId'] ?? '',
        userName: data['userName'] ?? 'Anonymous',
        content: data['content'] ?? '',
        companyId: data['companyId'] ?? '',
        userProfileUrl: data['userProfileUrl'] ?? '',
        isPositive: data['isPositive'] ?? true,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }
}
