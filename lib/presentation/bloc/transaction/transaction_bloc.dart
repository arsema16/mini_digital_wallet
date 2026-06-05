import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../core/network/network_info.dart';
import '../../../data/datasources/local/database_factory.dart';
import '../../../data/datasources/remote/transaction_remote_ds.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository_impl.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/delete_transaction.dart';
import '../../../domain/usecases/get_transactions.dart';
import '../../../domain/usecases/sync_transactions.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionRepositoryImpl? _repo;
  GetTransactions? _getTransactions;
  AddTransactionUseCase? _addTransaction;
  DeleteTransactionUseCase? _deleteTransaction;
  SyncTransactionsUseCase? _syncTransactions;
  bool _ready = false;

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransaction>(_onAdd);
    on<UpdateTransaction>(_onUpdate);
    on<DeleteTransaction>(_onDelete);
    on<SyncTransactions>(_onSync);
    on<FilterTransactions>(_onFilter);
    _init();
  }

  Future<void> _init() async {
    final db = DatabaseFactory.create();
    await db.init();

    _repo = TransactionRepositoryImpl(
      localDb: db,
      remoteDataSource: TransactionRemoteDataSource(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      ),
      networkInfo: NetworkInfoImpl(Connectivity()),
      auth: FirebaseAuth.instance,
    );

    _getTransactions = GetTransactions(_repo!);
    _addTransaction = AddTransactionUseCase(_repo!);
    _deleteTransaction = DeleteTransactionUseCase(_repo!);
    _syncTransactions = SyncTransactionsUseCase(_repo!);
    _ready = true;

    if (!isClosed) add(LoadTransactions());
  }

  Future<void> _onLoad(LoadTransactions event, Emitter<TransactionState> emit) async {
    if (!_ready) return;
    emit(TransactionLoading());

    final result = await _getTransactions!();
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) {
        final models = transactions.map((e) => TransactionModel(
          id: e.id,
          title: e.title,
          amount: e.amount,
          type: e.type,
          category: e.category,
          paymentMethod: e.paymentMethod,
          refId: e.refId,
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
          isSynced: e.isSynced,
        )).toList();

        final income = models.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
        final expense = models.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);

        final Map<String, double> byCategory = {};
        for (final tx in models.where((t) => t.type == 'expense')) {
          byCategory[tx.category] = (byCategory[tx.category] ?? 0) + tx.amount;
        }

        emit(TransactionLoaded(
          allTransactions: models,
          filteredTransactions: models,
          totalBalance: income - expense,
          totalIncome: income,
          totalExpense: expense,
          categorySpending: byCategory,
        ));
      },
    );
  }

  Future<void> _onAdd(AddTransaction event, Emitter<TransactionState> emit) async {
    if (!_ready) return;
    final tx = event.transaction;
    final result = await _addTransaction!(TransactionEntity(
      id: tx.id,
      title: tx.title,
      amount: tx.amount,
      type: tx.type,
      category: tx.category,
      paymentMethod: tx.paymentMethod,
      refId: tx.refId,
      createdAt: tx.createdAt,
      updatedAt: tx.updatedAt,
    ));
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onUpdate(UpdateTransaction event, Emitter<TransactionState> emit) async {
    if (!_ready) return;
    final tx = event.transaction;
    final result = await _repo!.updateTransaction(TransactionEntity(
      id: tx.id,
      title: tx.title,
      amount: tx.amount,
      type: tx.type,
      category: tx.category,
      paymentMethod: tx.paymentMethod,
      refId: tx.refId,
      createdAt: tx.createdAt,
      updatedAt: DateTime.now(),
    ));
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onDelete(DeleteTransaction event, Emitter<TransactionState> emit) async {
    if (!_ready) return;
    final result = await _deleteTransaction!(event.id);
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onSync(SyncTransactions event, Emitter<TransactionState> emit) async {
    if (!_ready) return;
    final result = await _syncTransactions!();
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) {
        emit(TransactionSyncSuccess());
        add(LoadTransactions());
      },
    );
  }

  void _onFilter(FilterTransactions event, Emitter<TransactionState> emit) {
    final current = state;
    if (current is! TransactionLoaded) return;

    var filtered = List<TransactionModel>.from(current.allTransactions);

    if (event.type != null && event.type != 'All') {
      filtered = filtered.where((t) => t.type == event.type).toList();
    }
    if (event.category != null && event.category != 'All') {
      filtered = filtered.where((t) => t.category == event.category).toList();
    }
    if (event.dateRange != null) {
      filtered = filtered.where((t) =>
        t.createdAt.isAfter(event.dateRange!.start) &&
        t.createdAt.isBefore(event.dateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }
    if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
      final q = event.searchQuery!.toLowerCase();
      filtered = filtered.where((t) =>
        t.title.toLowerCase().contains(q) ||
        t.category.toLowerCase().contains(q) ||
        (t.paymentMethod?.toLowerCase().contains(q) ?? false) ||
        (t.refId?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    emit(current.copyWith(filteredTransactions: filtered));
  }
}
