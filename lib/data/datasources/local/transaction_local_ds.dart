import 'package:sqflite/sqflite.dart';
import '../../models/transaction_model.dart';
import 'app_database.dart';

class TransactionLocalDataSource {
  final AppDatabase appDatabase;

  TransactionLocalDataSource(this.appDatabase);

  Future<Database> get _db async => await appDatabase.database;

  Future<List<TransactionModel>> getTransactions() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await _db;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTransactions(List<TransactionModel> transactions) async {
    final db = await _db;
    final batch = db.batch();
    for (var transaction in transactions) {
      batch.insert('transactions', transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await _db;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.delete('transactions');
  }
}