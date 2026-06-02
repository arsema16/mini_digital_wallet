import '../../domain/entities/transaction.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String? paymentMethod;
  final String? refId;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isSynced;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.paymentMethod,
    this.refId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // Factory for creating a new transaction (unsynced)
  factory TransactionModel.newTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    String? paymentMethod,
    String? refId,
  }) {
    final now = DateTime.now();
    return TransactionModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      paymentMethod: paymentMethod,
      refId: refId,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
  }

  // From SQLite Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      category: map['category'],
      paymentMethod: map['payment_method'],
      refId: map['ref_id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      isSynced: map['is_synced'] == 1,
    );
  }

  // To SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'payment_method': paymentMethod,
      'ref_id': refId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // From Firestore
  factory TransactionModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return TransactionModel(
      id: docId,
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'expense',
      category: json['category'] ?? 'Other',
      paymentMethod: json['paymentMethod'],
      refId: json['refId'],
      createdAt: (json['createdAt'] as dynamic).toDate(),
      updatedAt: (json['updatedAt'] as dynamic).toDate(),
      isSynced: true,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'paymentMethod': paymentMethod,
      'refId': refId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // To Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      title: title,
      amount: amount,
      type: type,
      category: category,
      paymentMethod: paymentMethod,
      refId: refId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Copy with method for updating isSynced
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    String? paymentMethod,
    String? refId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      refId: refId ?? this.refId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // From Entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      paymentMethod: entity.paymentMethod,
      refId: entity.refId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: false,
    );
  }
}