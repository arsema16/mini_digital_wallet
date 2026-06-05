// lib/domain/usecases/add_transaction.dart

import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call(
      TransactionEntity transaction) {
    return repository.addTransaction(transaction);
  }
}
