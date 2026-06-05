import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/datasources/local/database_factory.dart';
import '../../../data/datasources/local/local_database.dart';
import '../../../data/models/transaction_model.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  late LocalDatabase _localDb;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransaction>(_onAdd);
    on<UpdateTransaction>(_onUpdate);
    on<DeleteTransaction>(_onDelete);
    on<SyncTransactions>(_onSync);
    on<FilterTransactions>(_onFilter);
    _initDb();
  }

  Future<void> _initDb() async {
    _localDb = DatabaseFactory.create();
    await _localDb.init();
    add(LoadTransactions());
  }

  Future<void> _onLoad(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final all = await _localDb.getTransactions();
      final income = all.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
      final expense = all.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);
      final balance = income - expense;
      emit(TransactionLoaded(
        allTransactions: all,
        filteredTransactions: all,
        totalBalance: balance,
        totalIncome: income,
        totalExpense: expense,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAdd(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _localDb.insertTransaction(event.transaction);
      // Try sync with Firestore if user logged in
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(event.transaction.id)
            .set(event.transaction.toFirestore());
        await _localDb.markAsSynced(event.transaction.id);
      }
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _localDb.updateTransaction(event.transaction);
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(event.transaction.id)
            .update(event.transaction.toFirestore());
      }
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _localDb.deleteTransaction(event.id);
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(event.id)
            .delete();
      }
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onSync(SyncTransactions event, Emitter<TransactionState> emit) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      // Upload unsynced local
      final unsynced = await _localDb.getUnsyncedTransactions();
      for (var tx in unsynced) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(tx.id)
            .set(tx.toFirestore());
        await _localDb.markAsSynced(tx.id);
      }
      // Download remote
      final remoteSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .get();
      for (var doc in remoteSnapshot.docs) {
        final remoteTx = TransactionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        final exists = (await _localDb.getTransactions()).any((t) => t.id == remoteTx.id);
        if (!exists) {
          await _localDb.insertTransaction(remoteTx);
        }
      }
      emit(TransactionSyncSuccess());
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onFilter(FilterTransactions event, Emitter<TransactionState> emit) {
    final state = this.state;
    if (state is TransactionLoaded) {
      var filtered = List<TransactionModel>.from(state.allTransactions);
      if (event.type != null && event.type != 'All') {
        filtered = filtered.where((t) => t.type == event.type).toList();
      }
      if (event.category != null && event.category != 'All') {
        filtered = filtered.where((t) => t.category == event.category).toList();
      }
      if (event.dateRange != null) {
        filtered = filtered.where((t) {
          final date = t.createdAt;
          return date.isAfter(event.dateRange!.start) &&
              date.isBefore(event.dateRange!.end.add(const Duration(days: 1)));
        }).toList();
      }
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final q = event.searchQuery!.toLowerCase();
        filtered = filtered.where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q)).toList();
      }
      emit(state.copyWith(filteredTransactions: filtered));
    }
  }
}

// Extension to copy state
extension _CopyLoaded on TransactionLoaded {
  TransactionLoaded copyWith({List<TransactionModel>? filteredTransactions}) {
    return TransactionLoaded(
      allTransactions: allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }
}