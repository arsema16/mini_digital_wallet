import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';
import 'local_database.dart';

class SQLiteDatabase implements LocalDatabase {
  static Database? _database;

  @override
  String get databaseType => 'SQLite';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mini_wallet.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        payment_method TEXT,
        ref_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(created_at DESC)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_transactions_category ON transactions(category)');
  }

  @override
  Future<void> init() async {
    await database;
  }

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert(
      'transactions', 
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
  }

  @override
  Future<double> getTotalBalance() async {
    final transactions = await getTransactions();
    double balance = 0;
    for (var t in transactions) {
      if (t.type == 'income') {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }

  @override
  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'transactions',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}