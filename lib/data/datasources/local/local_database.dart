import '../../models/transaction_model.dart';

abstract class LocalDatabase {
  Future<void> init();
  Future<void> insertTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getTransactions();
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> clearAll();
  Future<double> getTotalBalance();
  Future<List<TransactionModel>> getUnsyncedTransactions();
  Future<void> markAsSynced(String id);
  String get databaseType;
}