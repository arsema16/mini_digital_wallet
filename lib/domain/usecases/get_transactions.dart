// lib/domain/usecases/get_transactions.dart

import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getTransactions(
      type: type,
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
