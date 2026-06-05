import '../../models/transaction_model.dart';
import 'local_database.dart';

class TransactionLocalDataSource {
  final LocalDatabase _db;

  TransactionLocalDataSource(this._db);

  Future<List<TransactionModel>> getTransactions() => _db.getTransactions();

  Future<void> insertTransaction(TransactionModel tx) => _db.insertTransaction(tx);

  Future<void> insertTransactions(List<TransactionModel> txs) async {
    for (final tx in txs) {
      await _db.insertTransaction(tx);
    }
  }

  Future<void> deleteTransaction(String id) => _db.deleteTransaction(id);
}
