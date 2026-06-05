class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String? paymentMethod;
  final String? refId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  TransactionEntity({
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
}
