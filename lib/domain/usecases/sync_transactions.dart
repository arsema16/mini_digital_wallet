import 'package:dartz/dartz.dart';
import '../../core/failures/failure.dart';
import '../repositories/transaction_repository.dart';

class SyncTransactionsUseCase {
  final TransactionRepository repository;
  SyncTransactionsUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.syncWithRemote();
}
