// lib/domain/usecases/sync_transactions.dart

import 'package:dartz/dartz.dart';
import '../repositories/transaction_repository.dart';

class SyncTransactionsUseCase {
  final TransactionRepository repository;

  SyncTransactionsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.syncWithRemote();
  }
}
