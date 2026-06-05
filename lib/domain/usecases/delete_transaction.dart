// lib/domain/usecases/delete_transaction.dart

import 'package:dartz/dartz.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTransaction(id);
  }
}
