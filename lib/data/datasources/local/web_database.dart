import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/transaction_model.dart';
import 'local_database.dart';

class WebDatabase implements LocalDatabase {
  static SharedPreferences? _prefs;
  static const String _transactionsKey = 'transactions';
  
  List<TransactionModel> _transactions = [];

  @override
  String get databaseType => 'Web Storage (SharedPreferences)';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final String? data = _prefs?.getString(_transactionsKey);
    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = json.decode(data);
      _transactions = decoded
          .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      _transactions = [];
    }
  }

  Future<void> _saveToPrefs() async {
    final List<Map<String, dynamic>> data = 
        _transactions.map((t) => t.toMap()).toList();
    await _prefs?.setString(_transactionsKey, json.encode(data));
  }

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    _transactions.insert(0, transaction);
    await _saveToPrefs();
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return _transactions;
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _saveToPrefs();
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveToPrefs();
  }

  @override
  Future<void> clearAll() async {
    _transactions.clear();
    await _saveToPrefs();
  }

  @override
  Future<double> getTotalBalance() async {
    double balance = 0;
    for (var t in _transactions) {
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
    return _transactions.where((t) => !t.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index].isSynced = true;
      await _saveToPrefs();
    }
  }
}