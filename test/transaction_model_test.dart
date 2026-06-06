// test/transaction_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_digital_wallet/data/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    final now = DateTime(2025, 6, 1, 12, 0);

    final model = TransactionModel(
      id: '123',
      title: 'Groceries',
      amount: 500.0,
      type: 'expense',
      category: 'Food',
      paymentMethod: 'Telebirr',
      refId: 'ABCD1234',
      createdAt: now,
      updatedAt: now,
      isSynced: true,
    );

    test('toMap() produces correct SQLite map', () {
      final map = model.toMap();
      expect(map['id'], '123');
      expect(map['title'], 'Groceries');
      expect(map['amount'], 500.0);
      expect(map['type'], 'expense');
      expect(map['category'], 'Food');
      expect(map['payment_method'], 'Telebirr');
      expect(map['ref_id'], 'ABCD1234');
      expect(map['is_synced'], 1);
    });

    test('fromMap() reconstructs model correctly', () {
      final map = model.toMap();
      final restored = TransactionModel.fromMap(map);
      expect(restored.id, model.id);
      expect(restored.title, model.title);
      expect(restored.amount, model.amount);
      expect(restored.type, model.type);
      expect(restored.isSynced, true);
    });

    test('toEntity() preserves isSynced', () {
      final entity = model.toEntity();
      expect(entity.isSynced, true);

      final unsyncedModel = model.copyWith(isSynced: false);
      expect(unsyncedModel.toEntity().isSynced, false);
    });

    test('toFirestore() map contains required fields', () {
      final map = model.toFirestore();
      expect(map.containsKey('title'), true);
      expect(map.containsKey('amount'), true);
      expect(map.containsKey('type'), true);
      expect(map.containsKey('category'), true);
      expect(map.containsKey('paymentMethod'), true);
      expect(map.containsKey('refId'), true);
    });

    test('copyWith() updates only specified fields', () {
      final updated = model.copyWith(amount: 750.0, isSynced: false);
      expect(updated.amount, 750.0);
      expect(updated.isSynced, false);
      expect(updated.title, model.title); // unchanged
      expect(updated.category, model.category); // unchanged
    });

    test('fromMap() roundtrip preserves all fields', () {
      final map = model.toMap();
      final restored = TransactionModel.fromMap(map);
      expect(restored.id, model.id);
      expect(restored.title, model.title);
      expect(restored.amount, model.amount);
      expect(restored.type, model.type);
      expect(restored.category, model.category);
      expect(restored.paymentMethod, model.paymentMethod);
      expect(restored.refId, model.refId);
      expect(restored.createdAt.millisecondsSinceEpoch,
          model.createdAt.millisecondsSinceEpoch);
    });
  });
}
