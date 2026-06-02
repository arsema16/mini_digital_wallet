import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction_model.dart';

class TransactionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TransactionRemoteDataSource({required this.firestore, required this.auth});

  String? get _userId => auth.currentUser?.uid;

  CollectionReference get _transactionsCollection {
    if (_userId == null) throw Exception('User not logged in');
    return firestore.collection('users').doc(_userId!).collection('transactions');
  }

  Future<List<TransactionModel>> getTransactions() async {
    final snapshot = await _transactionsCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) =>
        TransactionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)
    ).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsCollection.doc(transaction.id).set(transaction.toFirestore());
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }
}