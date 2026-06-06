// test/transaction_filter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_digital_wallet/data/models/transaction_model.dart';

void main() {
  final now = DateTime.now();

  TransactionModel make({
    required String id,
    required String type,
    required String category,
    required double amount,
    required String title,
    DateTime? createdAt,
  }) =>
      TransactionModel(
        id: id,
        title: title,
        amount: amount,
        type: type,
        category: category,
        createdAt: createdAt ?? now,
        updatedAt: createdAt ?? now,
      );

  final transactions = [
    make(id: '1', type: 'income', category: 'Salary', amount: 5000, title: 'Monthly Salary'),
    make(id: '2', type: 'expense', category: 'Food', amount: 200, title: 'Groceries'),
    make(id: '3', type: 'expense', category: 'Transport', amount: 50, title: 'Bus fare'),
    make(id: '4', type: 'income', category: 'Freelance', amount: 1000, title: 'Design work'),
  ];

  group('Transaction filtering logic', () {
    test('filter by type=income returns only income', () {
      final result = transactions.where((t) => t.type == 'income').toList();
      expect(result.length, 2);
      expect(result.every((t) => t.type == 'income'), true);
    });

    test('filter by type=expense returns only expenses', () {
      final result = transactions.where((t) => t.type == 'expense').toList();
      expect(result.length, 2);
      expect(result.every((t) => t.type == 'expense'), true);
    });

    test('filter by category=Food returns only Food transactions', () {
      final result = transactions.where((t) => t.category == 'Food').toList();
      expect(result.length, 1);
      expect(result.first.title, 'Groceries');
    });

    test('search by title finds correct transaction', () {
      const query = 'bus';
      final result = transactions
          .where((t) => t.title.toLowerCase().contains(query))
          .toList();
      expect(result.length, 1);
      expect(result.first.id, '3');
    });

    test('balance calculation is income minus expense', () {
      final income = transactions
          .where((t) => t.type == 'income')
          .fold(0.0, (s, t) => s + t.amount);
      final expense = transactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (s, t) => s + t.amount);
      expect(income - expense, 5750.0); // 6000 - 250
    });

    test('spending by category groups correctly', () {
      final Map<String, double> byCategory = {};
      for (final tx in transactions.where((t) => t.type == 'expense')) {
        byCategory[tx.category] = (byCategory[tx.category] ?? 0) + tx.amount;
      }
      expect(byCategory['Food'], 200.0);
      expect(byCategory['Transport'], 50.0);
      expect(byCategory.containsKey('Salary'), false);
    });
  });
}
